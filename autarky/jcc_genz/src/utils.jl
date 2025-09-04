module Utils

using JuMP, CSV, DataFrames, YAML
using Statistics, Clustering, Dates, Interpolations
using Distributions, LinearAlgebra
using HypothesisTests  # For Shapiro-Wilk test

"""
Load time series data from a CSV file and validate its structure based on seasonality settings.
"""
function import_time_series(csv_file_path::String, num_seasons::Int, seasonality::Bool; delimiter::Char=',', decimal::Char='.')::DataFrame
    if !isfile(csv_file_path)
        error("The CSV file at path '$csv_file_path' does not exist.")
    end

    try
        data = CSV.read(csv_file_path, DataFrame; delim=delimiter, decimal=decimal)

        # Validation for seasonality
        if seasonality
            if size(data, 2) != num_seasons
                error("Invalid CSV format: Expected $num_seasons columns for seasonality, but found $(size(data, 2)).")
            end
        else
            if size(data, 2) != 1
                # Report a warning and truncate to the first column
                println("Warning: Seasonality is disabled, but the CSV file has multiple columns. Using only the first column.")
                data = data[:, 1]  # Keep only the first column
                # Convert to DataFrame with a single column
                data = DataFrame(:Time_Series => data)
            end
        end

        return data
    catch e
        error("Error loading CSV file: $(e.msg)")
    end
end

"""
Compute the average typical period from full-year hourly time-series data.

# Arguments:
- `full_year_data::Vector{Float64}`: A vector containing hourly time-series data for a full year (8760 values).
- `operation_time_steps::Int`: The number of time steps per representative period (e.g., 24 for daily, 168 for weekly).

# Returns:
- A DataFrame containing the average typical period.
"""
function compute_average_typical_period(full_year_data::Vector{Float64}, operation_time_steps::Int)::DataFrame
    # Validate input length
    if length(full_year_data) != 8760
        error("The input time series must contain exactly 8760 values (one year of hourly data).")
    end

    # Ensure operation_time_steps is a valid divisor of 8760
    if 8760 % operation_time_steps != 0
        error("operation_time_steps ($operation_time_steps) must be a divisor of 8760.")
    end

    # Calculate the number of periods in a year
    num_periods = 8760 ÷ operation_time_steps

    # Reshape data into (num_periods × operation_time_steps) matrix
    reshaped_data = reshape(full_year_data, operation_time_steps, num_periods)'

    # Compute the average period by averaging across all occurrences
    avg_typical_period = mean(reshaped_data, dims=1)

    # Convert to DataFrame
    df = DataFrame(:Average_Typical_Period => vec(avg_typical_period))

    println("Computed average typical period successfully.")
    return df
end

"""
Extract a single representative period from hourly time-series data for each user-defined season.

# Arguments:
- `full_year_data::Vector{Float64}`: A vector containing hourly time-series data for a full year (8760 values).
- `operation_time_steps::Int`: The number of time steps in each operation period (e.g., 24 for daily periods).
- `seasonal_definition::Dict{Any, Any}`: A user-defined mapping of seasons to months.

# Returns:
- A DataFrame containing a single representative period for each season.
"""
function cluster_representative_periods(
    full_year_data::Vector{Float64}, 
    operation_time_steps::Int, 
    seasonal_definition::Dict{Any, Any})::DataFrame
    
    # Validate input
    if length(full_year_data) != 8760
        error("Input time series must have exactly 8760 values.")
    end

    # Create hourly timestamps for a full year
    timestamps = [DateTime(2025,1,1,0):Hour(1):DateTime(2025,12,31,23);]
    months = [month(ts) for ts in timestamps]

    rep_data = DataFrame()  # Will eventually be 24×(num_seasons)

    for (season, months_in_season) in seasonal_definition

        # Extract hours belonging to the season
        season_indices = findall(m -> m in months_in_season, months)
        season_data = full_year_data[season_indices]

        # Number of full "days/weeks" in this season
        num_periods = length(season_data) ÷ operation_time_steps
        if num_periods < 1
            continue
        end

        # Reshape into (num_periods, operation_time_steps)
        reshaped_data = reshape(
            season_data[1:num_periods * operation_time_steps],
            operation_time_steps, num_periods
        )'

        # Mean period
        mean_period = mean(reshaped_data, dims=1)

        # Row that is closest to mean_period
        representative_index = argmin(sum((reshaped_data .- mean_period).^2, dims=2))
        # Convert from CartesianIndex(...) to an integer
        rep_idx = representative_index[1]

        # Flatten the chosen row to a 24-element vector
        representative_vector = vec(reshaped_data[rep_idx, :])

        # Add as a column to the DataFrame
        # Turn season into a string for column name
        col_name = string(season)
        rep_data[!, col_name] = representative_vector
    end
    return rep_data
end

"""
Sample the generator efficiency curve at `n_samples` equally spaced relative output points,
excluding points where efficiency is zero to avoid invalid divisions later.
Also plots and saves the sampled efficiency curve into the results folder.
"""
function sample_efficiency_curve(gen_efficiency_df, n_samples)
    # Extract columns (make sure your CSV header matches exactly)
    relative_output = gen_efficiency_df[:, 1] ./ 100  # Normalize from 0–100% → 0–1
    efficiency = gen_efficiency_df[:, 2] ./ 100       # Normalize efficiency % → 0–1

    # Build interpolation
    interpolation = LinearInterpolation(relative_output, efficiency, extrapolation_bc=Line())

    # Sampling points (equally spaced between 0 and 1)
    sampled_relative_output = range(0, 1, length=n_samples)

    # Interpolated efficiencies at sampled points
    sampled_efficiency = [interpolation(r) for r in sampled_relative_output]

    # Remove sampled points where efficiency is zero
    valid_indices = findall(e -> e > 0, sampled_efficiency)
    sampled_relative_output = sampled_relative_output[valid_indices]
    sampled_efficiency = sampled_efficiency[valid_indices]

    return sampled_relative_output, sampled_efficiency
end

"""
Performs a normality test (Shapiro-Wilk) on the columns of a given matrix.
"""
function test_normality(errors::DataFrame, label::String)
    errors = Matrix(errors)
    p_values = []
    for col in eachcol(errors)
        test = ShapiroWilkTest(col)
        push!(p_values, pvalue(test))
    end

    # Log warnings if normality is not satisfied
    if any(p -> p < 0.05, p_values)
        println("\nWarning: Some $(label) error distributions are not normal. Proceeding under normality assumption.")
    else
        println("All $(label) error distributions passed the Shapiro-Wilk normality test.")
    end

end

"""
Checks if a covariance matrix is positive semi-definite (PSD) and regularizes it if necessary.
# Positional Arguments:
- `covariance_matrix::Matrix{Float64}`: The covariance matrix to check.

# Keyword Arguments:
- `epsilon::Float64 = 1e-6`: Small value to add to the diagonal for regularization.

# Returns:
- `covariance_matrix::Matrix{Float64}`: A positive semi-definite covariance matrix.
"""
function ensure_positive_semidefinite(covariance_matrix::Matrix{Float64}, label::String; epsilon::Float64 = 1e-6)
    eigenvalues = eigvals(covariance_matrix)
    if all(eigenvalues .>= 0)
        println("\n$(label) covariance matrix is positive semi-definite.")
    elseif -minimum(eigenvalues) < epsilon
        println("\n$(label) covariance matrix is not positive semi-definite but the minimum negative eigenvalue ($(minimum(eigenvalues))) is less than the defined epsilon ($(epsilon)). Regularizing...")
        covariance_matrix += epsilon * I(size(covariance_matrix, 1))
        eigenvalues = eigvals(covariance_matrix)
        
        if all(eigenvalues .>= 0)
            println("\n$(label) covariance matrix is now positive semi-definite after regularization.")
        else
            error("$(label) covariance matrix could not be regularized to positive semi-definiteness.")
        end
    else
        error("\n$(label) covariance matrix is not positive semi-definite and the minimum negative eigenvalue ($(minimum(eigenvalues))) is greater than the defined epsilon ($(epsilon)).")
    end

    return covariance_matrix
end

"""
Initialize the JCC model variables using results from ICC optimization.

# Arguments:
- `model::Model`: JuMP model to initialize.
- `results_dir::String`: Directory where ICC dispatch and sizing CSV files are stored.
- `has_solar::Bool`
- `has_wind::Bool`
- `has_battery::Bool`
- `has_generator::Bool`
- `allow_grid_connection::Bool`
- `allow_grid_export::Bool`
- `seasonality::Bool`
- `num_seasons::Int`
"""
function initialize_start_values(model::Model, results_dir::String;
                                  has_solar::Bool=true, has_wind::Bool=false,
                                  has_battery::Bool=true, has_generator::Bool=true,
                                  allow_grid_connection::Bool=false, allow_grid_export::Bool=false,
                                  seasonality::Bool=true, num_seasons::Int=4)

    ### 1. Load and assign SIZING variables first
    sizing_file = joinpath(results_dir, "sizing_summary.csv")
    if isfile(sizing_file)
        sizing_df = CSV.read(sizing_file, DataFrame)

        for row in eachrow(sizing_df)
            tech = row."Technology"
            units = row."Installed Units"

            if has_solar && tech == "Solar PV" && haskey(model, :solar_units)
                set_start_value(model[:solar_units], units)
            elseif has_wind && tech == "Wind Turbine" && haskey(model, :wind_units)
                set_start_value(model[:wind_units], units)
            elseif has_battery && tech == "Battery Storage" && haskey(model, :battery_units)
                set_start_value(model[:battery_units], units)
            elseif has_generator && tech == "Diesel Generator" && haskey(model, :generator_units)
                set_start_value(model[:generator_units], units)
            else
                println("Warning: Sizing entry '$tech' not matched to model variables.")
            end
        end
    else
        println("Warning: sizing_summary.csv not found. Skipping sizing initialization.")
    end

    ### 2. Load and assign OPERATION variables for each season
    for s in 1:num_seasons
        # Load the dispatch file for season s
        dispatch_file = joinpath(results_dir, seasonality ? "optimal_dispatch_season_$(s).csv" : "optimal_dispatch.csv")
        
        if !isfile(dispatch_file)
            println(" Warning: Dispatch file for season $s not found. Skipping...")
            continue
        end

        dispatch_df = CSV.read(dispatch_file, DataFrame)
        T = nrow(dispatch_df)

        for t in 1:T
            # Solar production
            if has_solar && "Solar Production (kWh)" in names(dispatch_df)
                set_start_value(model[:solar_production][t, s], dispatch_df[t, "Solar Production (kWh)"])
            end
            # Wind production
            if has_wind && "Wind Production (kWh)" in names(dispatch_df)
                set_start_value(model[:wind_production][t, s], dispatch_df[t, "Wind Production (kWh)"])
            end
            # Battery
            if has_battery
                if "Battery Charge (kWh)" in names(dispatch_df)
                    set_start_value(model[:battery_charge][t, s], dispatch_df[t, "Battery Charge (kWh)"])
                end
                if "Battery Discharge (kWh)" in names(dispatch_df)
                    set_start_value(model[:battery_discharge][t, s], dispatch_df[t, "Battery Discharge (kWh)"])
                end
                if "State of Charge (kWh)" in names(dispatch_df)
                    set_start_value(model[:SOC][t, s], dispatch_df[t, "State of Charge (kWh)"])
                end
                if "Battery Reserve (kWh)" in names(dispatch_df)
                    set_start_value(model[:battery_reserve][t, s], dispatch_df[t, "Battery Reserve (kWh)"])
                end
            end
            # Generator
            if has_generator
                if "Generator Production (kWh)" in names(dispatch_df)
                    set_start_value(model[:generator_production][t, s], dispatch_df[t, "Generator Production (kWh)"])
                end
                if "Generator Reserve (kWh)" in names(dispatch_df)
                    set_start_value(model[:generator_reserve][t, s], dispatch_df[t, "Generator Reserve (kWh)"])
                end
            end
            # Grid import/export
            if allow_grid_connection
                if "Grid Import (kWh)" in names(dispatch_df)
                    set_start_value(model[:grid_import][t, s], dispatch_df[t, "Grid Import (kWh)"])
                end
                if allow_grid_export && "Grid Export (kWh)" in names(dispatch_df)
                    set_start_value(model[:grid_export][t, s], dispatch_df[t, "Grid Export (kWh)"])
                end
            end
            # Expected shortfall
            if "Expected Shortfall (kWh)" in names(dispatch_df)
                set_start_value(model[:expected_shortfall][t, s], dispatch_df[t, "Expected Shortfall (kWh)"])
            end
        end
    end
end


end # module Utils