using YAML, CSV, DataFrames, LinearAlgebra, Statistics, Distributions
include(joinpath(@__DIR__, "utils.jl"))
using .Utils: import_time_series, 
              compute_average_typical_period, 
              cluster_representative_periods, 
              sample_efficiency_curve,
              ensure_positive_semidefinite

# ------------------------------
# EXTRACT PARAMETERS FROM YAML
# ------------------------------

# Construct the path to the YAML file dynamically relative to this script's location
parameters_path = joinpath(@__DIR__,"..", "inputs", "parameters.yaml")
# Load project settings and parameters
parameters = YAML.load_file(parameters_path)

# Extract project settings
start_date = parameters["project_settings"]["start_date"] # string
project_lifetime = parameters["project_settings"]["project_lifetime"]
time_step_duration = parameters["project_settings"]["time_step_duration"]
discount_rate = parameters["project_settings"]["discount_rate"] 
currency = parameters["project_settings"]["currency"] # string
latitude = parameters["project_settings"]["latitude"]
longitude = parameters["project_settings"]["longitude"]

# Extract time series settings
data_type = parameters["time_series_settings"]["data_type"]  # string
if data_type == "day"
    operation_time_steps = 24  # Number of time steps in a day
elseif data_type == "week"
    operation_time_steps = 24 * 7  # Number of time steps in a week
elseif data_type == "year"
    operation_time_steps = 8760  # Number of time steps in a year
else
    error("Invalid data type: $data_type. Supported types are 'day', 'week', and 'year'.")
end
# Calculate the scale factor for the time series data
year_scale_factor =  8760 / operation_time_steps

seasonality = parameters["time_series_settings"]["seasonality"]  # bool
num_seasons = parameters["time_series_settings"]["num_seasons"]  

# Initialize seasonal definition if seasonality is enabled
seasonal_definition = Dict()
if seasonality
    if num_seasons == 1
        error("Seasonality is enabled but `num_seasons` is set to 1. Please define multiple seasons.")
    end
    
    # Extract seasonal definition
    seasonal_definition = parameters["time_series_settings"]["seasonal_definition"]

    # Validate that all months (1-12) are accounted for
    assigned_months = reduce(vcat, values(seasonal_definition))  # Flatten month lists
    unique_months = sort(unique(assigned_months))

    if unique_months != collect(1:12)
        error("Invalid seasonal definition: All months (1-12) must be assigned to a season exactly once.")
    end

    # Validate consistency of num_seasons with user-defined seasons
    if length(seasonal_definition) != num_seasons
        error("Mismatch between `num_seasons` and the number of defined seasonal groups in `seasonal_definition`.")
    end
    # Calculate seasonal scale factors (weights sum to `year_scale_factor`)
    season_weights = Dict(s => (length(seasonal_definition[s]) / 12) * year_scale_factor for s in 1:num_seasons)
else
    # If seasonality is not enabled, set a single season with the full year scale factor
    seasonal_definition = Dict(1 => collect(1:12))  # Single season covering all months
    season_weights = Dict(1 => year_scale_factor)   # Full year scale factor for the single season
end



# Extract optimization settings
max_capex = parameters["optimization_settings"]["max_capex"]
min_res_share = parameters["optimization_settings"]["min_res_share"]
allow_grid_connection = parameters["optimization_settings"]["on_grid"]["allow_grid_connection"] # bool
allow_grid_export = parameters["optimization_settings"]["on_grid"]["allow_grid_export"] # bool
max_line_capacity = parameters["optimization_settings"]["on_grid"]["max_capacity"]
grid_exchange_cost = parameters["optimization_settings"]["on_grid"]["grid_exchange_cost"] # bool

# Extract uncertainty settings
outage_duration = parameters["uncertainty_settings"]["outage_duration"]
outage_probability = parameters["uncertainty_settings"]["outage_probability"]
islanding_probability = parameters["uncertainty_settings"]["islanding_probability"]


# Extract Solar PV params
has_solar = parameters["solar_pv"]["enabled"] # bool
allow_solar_units = parameters["solar_pv"]["allow_units"] # bool
download_solar_data = parameters["solar_pv"]["download_data"] # bool
solar_capex = parameters["solar_pv"]["economics"]["capex"]                  
solar_opex = parameters["solar_pv"]["economics"]["opex"]                    
solar_subsidy_share = parameters["solar_pv"]["economics"]["subsidy"]        
solar_lifetime = parameters["solar_pv"]["economics"]["lifetime"]   
solar_nominal_capacity = parameters["solar_pv"]["technical"]["nominal_capacity"]
solar_inverter_efficiency = parameters["solar_pv"]["technical"]["inverter_efficiency"]
solar_technical = parameters["solar_pv"]["technical"] # dict

# Extract Wind Turbine params
has_wind = parameters["wind_turbine"]["enabled"] # bool
allow_wind_units = parameters["wind_turbine"]["allow_units"] # bool
download_wind_data = parameters["wind_turbine"]["download_data"] # bool
wind_capex = parameters["wind_turbine"]["economics"]["capex"]          
wind_opex = parameters["wind_turbine"]["economics"]["opex"] 
wind_subsidy_share = parameters["wind_turbine"]["economics"]["subsidy"]           
wind_nominal_capacity = parameters["wind_turbine"]["technical"]["nominal_capacity"]  
wind_lifetime = parameters["wind_turbine"]["economics"]["lifetime"]    
wind_inverter_efficiency = parameters["wind_turbine"]["technical"]["inverter_efficiency"]  
turbine_technical = parameters["wind_turbine"]["technical"]  # dict          

# Extract Battery params
has_battery = parameters["battery"]["enabled"] # bool  
allow_battery_units = parameters["battery"]["allow_units"] # bool
battery_nominal_capacity = parameters["battery"]["nominal_capacity"]  
battery_capex = parameters["battery"]["economics"]["capex"]                      
battery_opex = parameters["battery"]["economics"]["opex"]                        
battery_lifetime = parameters["battery"]["economics"]["lifetime"]               
η_charge = parameters["battery"]["efficiency"]["charge"]            
η_discharge = parameters["battery"]["efficiency"]["discharge"]      
SOC_min = parameters["battery"]["SOC"]["min"]                       
SOC_max = parameters["battery"]["SOC"]["max"]                       
SOC_0 = parameters["battery"]["SOC"]["initial"]                     
t_charge = parameters["battery"]["operation"]["charge_time"]        
t_discharge = parameters["battery"]["operation"]["discharge_time"]  

# Extract Generator params
has_generator = parameters["generator"]["enabled"] # bool
allow_generator_units = parameters["generator"]["allow_units"] # bool
generator_nominal_capacity = parameters["generator"]["nominal_capacity"] 
generator_efficiency = parameters["generator"]["nominal_efficiency"] 
allow_partial_load = parameters["generator"]["allow_partial_load"] # bool
n_samples = parameters["generator"]["n_samples"]
generator_capex = parameters["generator"]["economics"]["capex"]                      
generator_opex = parameters["generator"]["economics"]["opex"]             
generator_lifetime = parameters["generator"]["economics"]["lifetime"]  
# Fuel parameters                      
fuel_lhv = parameters["generator"]["fuel"]["fuel_lhv"]                       
fuel_cost = parameters["generator"]["fuel"]["fuel_cost"]                          
fuel_consumption_limit = parameters["generator"]["fuel"]["fuel_consumption_limit"] # bool
max_fuel_consumption = parameters["generator"]["fuel"]["max_fuel_consumption"]       

# ------------------------------------
# LOAD AND INITIALIZE TIME SERIES DATA
# ------------------------------------

# Load demand data
load_path = joinpath(@__DIR__,"..", "inputs", "load.csv")
println("\nLoading load data from CSV file...")
load = import_time_series(load_path, num_seasons, seasonality)

# Load solar power data
if has_solar == true
    if download_solar_data == true
        # Load and estimate solar power output from PVGIS data
        include(joinpath(@__DIR__, "solar_pvgis.jl"))
        pvgis_url = build_pvgis_url(latitude, longitude)
        println("\nDownloading solar data from PVGIS API...")
        solar_pvgis_data = estimate_solar_power(pvgis_url, latitude, longitude, solar_technical) # Yearly data, hourly resolution
        if seasonality == true
            # Extract representative periods for each season based on clustering
            solar_unit_production = cluster_representative_periods(solar_pvgis_data, operation_time_steps, seasonal_definition) #TODO: adapt to the extra outage hours
            CSV.write(joinpath(@__DIR__,"..", "inputs", "solar_production.csv"), solar_unit_production)
            println("Cluster Solar data over-written to CSV file.")
        else
            # Compute the average typical period
            solar_unit_production = compute_average_typical_period(solar_pvgis_data, operation_time_steps) #TODO: adapt to the extra outage hours
            CSV.write(joinpath(@__DIR__,"..", "inputs", "solar_production.csv"), solar_unit_production)
            println("Average Solar data over-written to CSV file.")
        end
    else
        # Load solar power output data from a CSV file
        solar_production_path = joinpath(@__DIR__,"..", "inputs", "solar_production.csv")
        println("\nLoading solar data from CSV file...")
        solar_unit_production = import_time_series(solar_production_path, num_seasons, seasonality)
    end
end

# Load wind power data
if has_wind == true
    if download_wind_data == true
        # Load and estimate wind power output from PVGIS data
        include(joinpath(@__DIR__, "wind_pvgis.jl"))
        pvgis_url = build_pvgis_url(latitude, longitude)
        println("\nDownloading wind data from PVGIS API...")
        wind_power_curve_path = joinpath(@__DIR__,"..", "inputs", "wind_power_curve.csv")
        wind_power, Cp = estimate_wind_power(pvgis_url, turbine_technical, wind_power_curve_path)
        if seasonality == true
            # Extract representative periods for each season based on clustering
            wind_power = cluster_representative_periods(wind_power, operation_time_steps, seasonal_definition)
            CSV.write(joinpath(@__DIR__,"..", "inputs", "wind_production.csv"), wind_power)
            println("Cluster Wind data over-written to CSV file.")
        else
            # Compute the average typical period
            wind_power = compute_average_typical_period(wind_power, operation_time_steps)
            CSV.write(joinpath(@__DIR__,"..", "inputs", "wind_production.csv"), wind_power)
            println("Average Wind data over-written to CSV file.")
        end
    else
        wind_production_path = joinpath(@__DIR__,"..", "inputs", "wind_production.csv")
        println("\nLoading wind data from CSV file...")
        wind_power = import_time_series(wind_production_path, num_seasons, seasonality)
    end
end

# Load generator efficiency curve if partial load is allowed
if has_generator == true && allow_partial_load == true
    generator_efficiency_curve_path = joinpath(@__DIR__,"..", "inputs", "generator_efficiency_curve.csv")
    println("\nLoading generator efficiency curve from CSV file...")
    generator_efficiency_curve = CSV.read(generator_efficiency_curve_path, DataFrame)
    # Sample the efficiency curve for piece-wise linear interpolation
    sampled_relative_output, sampled_efficiency = sample_efficiency_curve(generator_efficiency_curve, n_samples)
end

# Load grid cost and price data (if applicable)
if allow_grid_connection == true
    grid_cost_path = joinpath(@__DIR__,"..", "inputs", "grid_cost.csv")
    println("\nLoading grid cost data from CSV file...")
    grid_cost = import_time_series(grid_cost_path, num_seasons, seasonality)
    grid_availability_path = joinpath(@__DIR__,"..", "inputs", "grid_availability.csv")
    println("\nLoading grid availability data from CSV file...")
    grid_availability = import_time_series(grid_availability_path, num_seasons, seasonality)
    if allow_grid_export == true
        grid_price_path = joinpath(@__DIR__,"..", "inputs", "grid_price.csv")
        println("\nLoading grid price data from CSV file...")
        grid_price = import_time_series(grid_price_path, num_seasons, seasonality)
    end
else
    # If not connected to the grid, set grid data to zero
    grid_cost = zeros(operation_time_steps + outage_duration, num_seasons)
    grid_price = zeros(operation_time_steps + outage_duration, num_seasons)
end

# --------------------------------------------
# INITIALIZE ERRORS DATA AND COVARIANCE MATRIX
# --------------------------------------------

# Initialize containers
load_errors = Dict{Int, DataFrame}()
solar_errors = Dict{Int, DataFrame}()
load_cov_matrix = Dict{Int, Matrix}()
solar_cov_matrix = Dict{Int, Matrix}()
errors_cov_matrix = Dict{Int, Matrix}()
load_errors_stddev = Dict{Int, Vector}()

# Containers for JCC
outage_stddev = Dict{Int, Vector}()
outage_mean = Dict{Int, Vector}()
outage_covariance = Dict{Int, Matrix}()

if seasonality
    println("\nProcessing prediction errors with seasonality...")

    for s in 1:num_seasons
        # Load load prediction errors for season s
        local load_error_path = joinpath(@__DIR__, "..", "inputs", "errors", "load_errors_$s.csv")
        load_errors[s] = CSV.read(load_error_path, DataFrame)

        # Load solar prediction errors for season s
        local solar_error_path = joinpath(@__DIR__, "..", "inputs", "errors", "solar_errors_$s.csv")
        solar_errors[s] = CSV.read(solar_error_path, DataFrame)

        # Calculate covariance matrices
        load_cov_matrix[s] = ensure_positive_semidefinite(cov(Matrix(load_errors[s]); dims=2), "Load Season $s")
        solar_cov_matrix[s] = ensure_positive_semidefinite(cov(Matrix(solar_errors[s]); dims=2), "Solar Season $s")

        # Combine errors covariance assuming independence
        errors_cov_matrix[s] = ensure_positive_semidefinite(load_cov_matrix[s] + solar_cov_matrix[s], "Multi-variate Season $s")

        # Compute standard deviation vector
        local σ = diag(errors_cov_matrix[s]).^0.5 
        load_errors_stddev[s] = σ

        # Compute mean vector (assumed to be zero)
        local μ = zeros(length(σ))

        # Save for JCC
        outage_stddev[s] = σ
        outage_mean[s] = μ
        outage_covariance[s] = errors_cov_matrix[s]
    end

    println("\nFinished processing prediction errors for all seasons.")

else
    println("\nProcessing prediction errors without seasonality...")

    # Load load prediction errors
    local load_error_path = joinpath(@__DIR__, "..", "inputs", "errors", "load_errors_1.csv") # TODO: update file name if needed
    load_errors[1] = CSV.read(load_error_path, DataFrame)

    # Load solar prediction errors
    local solar_error_path = joinpath(@__DIR__, "..", "inputs", "errors", "solar_errors_1.csv") # TODO: update file name if needed
    solar_errors[1] = CSV.read(solar_error_path, DataFrame)

    # Calculate covariance matrices
    load_cov_matrix[1] = ensure_positive_semidefinite(cov(Matrix(load_errors[1]); dims=2), "Load")
    solar_cov_matrix[1] = ensure_positive_semidefinite(cov(Matrix(solar_errors[1]); dims=2), "Solar")

    # Combine errors covariance
    errors_cov_matrix[1] = ensure_positive_semidefinite(load_cov_matrix[1] + solar_cov_matrix[1], "Multi-variate")

    # Compute standard deviation vector
    local σ = diag(errors_cov_matrix[1]).^0.5
    load_errors_stddev[1] = σ
    # Compute mean vector (assumed to be zero)
    local μ = zeros(length(σ))

    # Save for JCC
    outage_stddev[1] = σ
    outage_mean[1] = μ
    outage_covariance[1] = errors_cov_matrix[1]

    println("\nFinished processing prediction errors (no seasonality).")
end

# ------------------------------------------------
# CALCULATE DISCOUNT FACTORS AND SALVAGE FRACTIONS
# ------------------------------------------------

# Calculate the yearly discount factor
discount_factor = [1 / ((1 + discount_rate) ^ y) for y in 1:project_lifetime]

# Calculate number of replacements for each component
solar_replacements = max(0, floor((project_lifetime - 1) / solar_lifetime))
wind_replacements = max(0, floor((project_lifetime - 1) / wind_lifetime))
battery_replacements = max(0, floor((project_lifetime - 1) / battery_lifetime))
generator_replacements = max(0, floor((project_lifetime - 1) / generator_lifetime))

# Build arrays of valid replacement times (in whole years), up to project_lifetime - 1 ensuring not to index discount_factor past the end.
solar_replacement_years = solar_lifetime : solar_lifetime : Int(floor((project_lifetime - 1) / solar_lifetime) * solar_lifetime)
wind_replacement_years = wind_lifetime : wind_lifetime : Int(floor((project_lifetime - 1) / wind_lifetime) * wind_lifetime)
battery_replacement_years = battery_lifetime : battery_lifetime : Int(floor((project_lifetime - 1) / battery_lifetime) * battery_lifetime)
generator_replacement_years = generator_lifetime : generator_lifetime : Int(floor((project_lifetime - 1) / generator_lifetime) * generator_lifetime)

# Calculate the salvage fractions for each component based on the last replacement year
last_install_solar = length(solar_replacement_years) == 0 ? 0 : maximum(solar_replacement_years)
unused_solar_life = solar_lifetime - (project_lifetime - last_install_solar)
salvage_solar_fraction = max(0, unused_solar_life / solar_lifetime)

last_install_wind = length(wind_replacement_years) == 0 ? 0 : maximum(wind_replacement_years)
unused_wind_life = wind_lifetime - (project_lifetime - last_install_wind)
salvage_wind_fraction = max(0, unused_wind_life / wind_lifetime)

last_install_battery = length(battery_replacement_years) == 0 ? 0 : maximum(battery_replacement_years)
unused_battery_life = battery_lifetime - (project_lifetime - last_install_battery)
salvage_battery_fraction = max(0, unused_battery_life / battery_lifetime)

last_install_generator = length(generator_replacement_years) == 0 ? 0 : maximum(generator_replacement_years)
unused_generator_life = generator_lifetime - (project_lifetime - last_install_generator)
salvage_generator_fraction = max(0, unused_generator_life / generator_lifetime)

# Define useful alias for readibility
Δt = time_step_duration
T = operation_time_steps + outage_duration
if seasonality == true
    S = num_seasons
else
    S = 1
end

