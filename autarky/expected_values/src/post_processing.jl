module PostProcessing

using JuMP, CSV, DataFrames, Dates, Statistics
include(joinpath(@__DIR__, "utils.jl"))
using .Utils: import_time_series 

"""
Write the sizing results (capacity variables) to a CSV file,
including the installed units AND total installed capacity (units × nominal capacity).

# Arguments:
- `model::Model`: The optimization model containing the sizing variables.
- `parameters::Dict`: Dictionary loaded from the parameters.yaml file.
"""
function write_sizing_to_csv(model::Model, parameters::Dict)

    # Initialize sizing dictionary
    sizing = Dict(
        "Technology" => String[], 
        "Installed Units" => Float64[],
        "Total Installed Capacity" => Float64[])

    # Extract parameters settings
    has_solar = parameters["solar_pv"]["enabled"]
    has_wind = parameters["wind_turbine"]["enabled"]
    has_battery = parameters["battery"]["enabled"]
    has_generator = parameters["generator"]["enabled"]

    # Extract and save sizing variables conditionally
    if has_solar && haskey(model, :solar_units)
        units = value(model[:solar_units])
        push!(sizing["Technology"], "Solar PV")
        push!(sizing["Installed Units"], units)
        push!(sizing["Total Installed Capacity"], units * parameters["solar_pv"]["technical"]["nominal_capacity"])
    end
    
    if has_wind && haskey(model, :wind_units)
        units = value(model[:wind_units])
        push!(sizing["Technology"], "Wind Turbine")
        push!(sizing["Installed Units"], units)
        push!(sizing["Total Installed Capacity"], units * parameters["wind_turbine"]["technical"]["nominal_capacity"])
    end
    
    if has_battery && haskey(model, :battery_units)
        units = value(model[:battery_units])
        push!(sizing["Technology"], "Battery Storage")
        push!(sizing["Installed Units"], units)
        push!(sizing["Total Installed Capacity"], units * parameters["battery"]["nominal_capacity"])
    end
    
    if has_generator && haskey(model, :generator_units)
        units = value(model[:generator_units])
        push!(sizing["Technology"], "Diesel Generator")
        push!(sizing["Installed Units"], units)
        push!(sizing["Total Installed Capacity"], units * parameters["generator"]["nominal_capacity"])
    end

    # Convert to DataFrame
    sizing_table = DataFrame(sizing)

    # Write to CSV
    sizing_path = joinpath(@__DIR__, "..", "results", "sizing_summary.csv")
    CSV.write(sizing_path, sizing_table)
    println("Sizing results written to $sizing_path")
end


"""
Write the cost results to a CSV file.
# Arguments:
- `model::Model`: The optimization model containing the cost variables.
- `parameters::Dict`: Dictionary loaded from the parameters.yaml file.
"""
function write_costs_to_csv(model::Model, parameters::Dict)

    # Extract currency from parameters
    currency = parameters["project_settings"]["currency"]

    # Initialize cost results dictionary
    costs = Dict(
    "Cost Component" => [],
    "Value (k$currency)" => [])
    
    # Extract and store key costs
    push!(costs["Cost Component"], "Net Present Cost")
    push!(costs["Value (k$currency)"], round(value(model[:NPC]) / 1000, digits=2))
    
    push!(costs["Cost Component"], "Total Investment Cost (CAPEX)")
    push!(costs["Value (k$currency)"], round(value(model[:CAPEX]) / 1000, digits=2))
    
    push!(costs["Cost Component"], "Total Discounted Replacement Cost")
    push!(costs["Value (k$currency)"], round(value(model[:Replacement_Cost_npv]) / 1000, digits=2))
    
    push!(costs["Cost Component"], "Total Subsidies (share of CAPEX)")
    push!(costs["Value (k$currency)"], round(value(model[:Subsidies]) / 1000, digits=2))
    
    push!(costs["Cost Component"], "Total Discounted Operation Cost")
    push!(costs["Value (k$currency)"], round(value(model[:OPEX_npv]) / 1000, digits=2))
    
    push!(costs["Cost Component"], "Total Discounted Salvage Value")
    push!(costs["Value (k$currency)"], round(value(model[:Salvage_npv]) / 1000, digits=2))
    
    # Convert to DataFrame
    costs_table = DataFrame(costs)
    
    # Write to CSV
    cost_path = joinpath(@__DIR__,"..", "results", "costs_summary.csv")
    CSV.write(cost_path, costs_table)
    println("Cost results written to $cost_path")
end


"""
Write the operational performance indicators to a CSV file.
# Arguments:
- `model::Model`: The optimization model containing the operation variables.
- `parameters::Dict`: Dictionary loaded from the parameters.yaml file.
- `season_weights::Vector{Float64}`: Vector of weights for each season, used to aggregate seasonal data.
"""
function write_operation_indicators_to_csv(model::Model, parameters::Dict, season_weights::Dict{Int64, Float64})
    # Define paths
    results_dir = joinpath(@__DIR__, "..", "results")
    inputs_dir = joinpath(@__DIR__, "..", "inputs")

    # Extract parameters settings
    has_solar = parameters["solar_pv"]["enabled"]
    has_wind = parameters["wind_turbine"]["enabled"]
    has_battery = parameters["battery"]["enabled"]
    has_generator = parameters["generator"]["enabled"]
    allow_grid_connection = parameters["optimization_settings"]["on_grid"]["allow_grid_connection"]
    allow_grid_export = parameters["optimization_settings"]["on_grid"]["allow_grid_export"]
    allow_partial_load = parameters["generator"]["allow_partial_load"]
    num_seasons = parameters["time_series_settings"]["num_seasons"]
    seasonality = parameters["time_series_settings"]["seasonality"]
    fuel_lhv = parameters["generator"]["fuel"]["fuel_lhv"]
    generator_nominal_capacity = parameters["generator"]["nominal_capacity"]

    load = import_time_series(joinpath(inputs_dir, "load.csv"), num_seasons, seasonality)
    T, S = size(load)

    data = Dict("Indicator" => String[], "Value" => Float64[], "Unit" => String[])

    # Solar
    if has_solar
        solar_unit_production = import_time_series(joinpath(inputs_dir, "solar_production.csv"), num_seasons, seasonality)
        total_solar_production = sum(season_weights[s] * value(model[:solar_production][t,s]) for t in 1:T, s in 1:S)
        total_solar_max = sum(season_weights[s] * (solar_unit_production[t,s] * value(model[:solar_units])) for t in 1:T, s in 1:S)
        curtailment_share = 100 * (total_solar_max - total_solar_production) / total_solar_max

        push!(data["Indicator"], "Total Annual Solar Production"); push!(data["Value"], total_solar_production / 1000); push!(data["Unit"], "MWh/year")
        push!(data["Indicator"], "Solar Curtailment Share"); push!(data["Value"], curtailment_share); push!(data["Unit"], "%")
    end

    # Wind
    if has_wind
        wind_power = import_time_series(joinpath(inputs_dir, "wind_production.csv"), num_seasons, seasonality)
        total_wind_production = sum(season_weights[s] * value(model[:wind_production][t,s]) for t in 1:T, s in 1:S)
        total_wind_max = sum(season_weights[s] * (wind_power[t,s] * value(model[:wind_units])) for t in 1:T, s in 1:S)
        wind_curtailment_share = 100 * (total_wind_max - total_wind_production) / total_wind_max

        push!(data["Indicator"], "Total Annual Wind Production"); push!(data["Value"], total_wind_production / 1000); push!(data["Unit"], "MWh/year")
        push!(data["Indicator"], "Wind Curtailment Share"); push!(data["Value"], wind_curtailment_share); push!(data["Unit"], "%")
    end

    # Battery
    if has_battery
        total_discharge = sum(season_weights[s] * value(model[:battery_discharge][t,s]) for t in 1:T, s in 1:S)
        total_charge = sum(season_weights[s] * value(model[:battery_charge][t,s]) for t in 1:T, s in 1:S)
        avg_battery_reserve = sum(season_weights[s] * sum(value(model[:battery_reserve][t,s]) for t in 1:T) for s in 1:S)

        push!(data["Indicator"], "Battery Discharge"); push!(data["Value"], total_discharge / 1000); push!(data["Unit"], "MWh/year")
        push!(data["Indicator"], "Battery Charge"); push!(data["Value"], total_charge / 1000); push!(data["Unit"], "MWh/year")
        push!(data["Indicator"], "Average Yearly Battery Reserve"); push!(data["Value"], avg_battery_reserve / 1000); push!(data["Unit"], "MWh")
    end

    # Generator
    if has_generator
        total_gen = sum(season_weights[s] * value(model[:generator_production][t,s]) for t in 1:T, s in 1:S)
        total_fuel = sum(season_weights[s] * (value(model[:generator_production][t,s]) / fuel_lhv) for t in 1:T, s in 1:S)
        avg_generator_reserve = sum(season_weights[s] * sum(value(model[:generator_reserve][t,s]) for t in 1:T) for s in 1:S)

        push!(data["Indicator"], "Generator Production"); push!(data["Value"], total_gen / 1000); push!(data["Unit"], "MWh/year")
        push!(data["Indicator"], "Fuel Consumption"); push!(data["Value"], total_fuel); push!(data["Unit"], "liters/year")
        push!(data["Indicator"], "Average Yearly Generator Reserve"); push!(data["Value"], avg_generator_reserve / 1000); push!(data["Unit"], "MWh")

        if allow_partial_load && value(model[:generator_units]) > 0
            gen_capacity_total = value(model[:generator_units]) * generator_nominal_capacity
            avg_eff = total_gen / total_fuel
            avg_load = total_gen / (gen_capacity_total * 8760)

            push!(data["Indicator"], "Avg Generator Efficiency"); push!(data["Value"], avg_eff); push!(data["Unit"], "kWh/liter")
            push!(data["Indicator"], "Avg Generator Load Factor"); push!(data["Value"], avg_load * 100); push!(data["Unit"], "%")
        end
    end

    # Grid
    if allow_grid_connection
        grid_availability = import_time_series(joinpath(inputs_dir, "grid_availability.csv"), num_seasons, seasonality)
        total_import = sum(season_weights[s] * value(model[:grid_import][t,s]) for t in 1:T, s in 1:S)
        push!(data["Indicator"], "Grid Import"); push!(data["Value"], total_import / 1000); push!(data["Unit"], "MWh/year")

        if allow_grid_export
            total_export = sum(season_weights[s] * value(model[:grid_export][t,s]) for t in 1:T, s in 1:S)
            push!(data["Indicator"], "Grid Export"); push!(data["Value"], total_export / 1000); push!(data["Unit"], "MWh/year")
        end

        avg_grid_avail = sum(season_weights[s] * grid_availability[t,s] for t in 1:T, s in 1:S)
        push!(data["Indicator"], "Avg Grid Availability"); push!(data["Value"], avg_grid_avail / 8760 * 100); push!(data["Unit"], "%")
    end

    # Renewable penetration
    if has_solar || has_wind
        total_res = 0.0
        total_gen = 0.0
        if has_solar
            total_res += sum(season_weights[s] * value(model[:solar_production][t,s]) for t in 1:T, s in 1:S)
        end
        if has_wind
            total_res += sum(season_weights[s] * value(model[:wind_production][t,s]) for t in 1:T, s in 1:S)
        end
        if has_generator
            total_gen += sum(season_weights[s] * value(model[:generator_production][t,s]) for t in 1:T, s in 1:S)
        end
        total_gen += total_res
        if total_gen > 0
            penetration = (total_res / total_gen) * 100
            push!(data["Indicator"], "Renewable Penetration"); push!(data["Value"], penetration); push!(data["Unit"], "%")
        end
    end

    # Expected Shortfall
    avg_expected_shortfall = sum(season_weights[s] * sum(value(model[:expected_shortfall][t,s]) for t in 1:T) for s in 1:S) / 1000
    push!(data["Indicator"], "Average Yearly Expected Shortfall"); push!(data["Value"], avg_expected_shortfall); push!(data["Unit"], "MWh")

    # Save to CSV
    df = DataFrame(data)
    output_path = joinpath(results_dir, "operation_indicators.csv")
    CSV.write(output_path, df)
    println("Operational indicators written to $output_path")
end


"""
Write the optimization results to CSV files for each season.

# Arguments:
- `model::Model`: The optimization model containing the results to be written.
- `parameters::Dict`: Dictionary loaded from the parameters.yaml file.
"""
function write_dispatch_to_csv(model::Model, parameters::Dict)

    # Extract parameters settings
    has_solar = parameters["solar_pv"]["enabled"]
    has_wind = parameters["wind_turbine"]["enabled"]
    has_battery = parameters["battery"]["enabled"]
    has_generator = parameters["generator"]["enabled"]
    allow_grid_connection = parameters["optimization_settings"]["on_grid"]["allow_grid_connection"]
    allow_grid_export = parameters["optimization_settings"]["on_grid"]["allow_grid_export"]
    num_seasons = parameters["time_series_settings"]["num_seasons"]
    seasonality = parameters["time_series_settings"]["seasonality"]

    # Load the demand data
    load_path = joinpath(@__DIR__, "..", "inputs", "load.csv")
    load = import_time_series(load_path, num_seasons, seasonality)  # Ensure this function properly splits seasons

    # Define base output path
    results_dir = joinpath(@__DIR__, "..", "results")
    if !isdir(results_dir)
        mkpath(results_dir)  # Create results directory if it does not exist
    end

    # Process each season separately if seasonality is enabled
    for s in 1:num_seasons
        results = Dict(
            "Time Step" => 1:size(load, 1),
            "Load Demand (kWh)" => load[:, s])

        # Extract operation variables conditionally
        if has_solar
            solar_units = value(model[:solar_units])
            solar_production = value.(model[:solar_production])[:, s]
            solar_production_path = joinpath(@__DIR__, "..", "inputs", "solar_production.csv")
            solar_unit_production = import_time_series(solar_production_path, num_seasons, seasonality)[:, s]  
            solar_max_production = solar_unit_production .* solar_units
            curtailment = solar_max_production .- solar_production
            results["Solar Production (kWh)"] = solar_production
            results["Solar Curtailment (kWh)"] = curtailment
        end

        if has_wind
            wind_units = value(model[:wind_units])
            wind_production = value.(model[:wind_production])[:, s]
            wind_production_path = joinpath(@__DIR__, "..", "inputs", "wind_production.csv")
            wind_power = import_time_series(wind_production_path, num_seasons, seasonality)[:, s]  
            wind_max_production = wind_power .* wind_units
            curtailment = wind_max_production .- wind_production
            results["Wind Production (kWh)"] = wind_production
            results["Wind Curtailment (kWh)"] = curtailment
        end

        if has_battery
            results["Battery Charge (kWh)"] = value.(model[:battery_charge])[:, s]
            results["Battery Discharge (kWh)"] = value.(model[:battery_discharge])[:, s]
            results["Battery Reserve (kWh)"] = value.(model[:battery_reserve])[:, s]
            results["State of Charge (kWh)"] = value.(model[:SOC])[:, s]
        end

        if has_generator
            results["Generator Production (kWh)"] = value.(model[:generator_production])[:, s]
            results["Generator Reserve (kWh)"] = value.(model[:generator_reserve])[:, s]
        end

        if allow_grid_connection
            results["Grid Import (kWh)"] = value.(model[:grid_import])[:, s]
            if allow_grid_export
                results["Grid Export (kWh)"] = value.(model[:grid_export])[:, s]
            end
        end

        # Expected Shortfall
        results["Expected Shortfall (kWh)"] = value.(model[:expected_shortfall])[:, s]

        # Convert results to DataFrame
        energy_balance_table = DataFrame(results)

        # Set appropriate filename based on seasonality
        if seasonality
            dispatch_path = joinpath(results_dir, "optimal_dispatch_season_$(s).csv")
        else
            dispatch_path = joinpath(results_dir, "optimal_dispatch.csv")
        end

        # Write to CSV
        CSV.write(dispatch_path, energy_balance_table)
        println("Dispatch results written to $dispatch_path")
    end
end

end