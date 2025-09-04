# Importing the required packages and functions
using JuMP, Gurobi
include(joinpath(@__DIR__, "utils.jl"))
using .Utils: import_time_series 
# Display and export results
include(joinpath(@__DIR__, "post_processing.jl"))
using .PostProcessing: write_dispatch_to_csv, write_costs_to_csv, write_sizing_to_csv, write_operation_indicators_to_csv

# MODEL INITIALIZATION
# --------------------

# Initialize parameters and time series data
include(joinpath(@__DIR__, "parameters_initialization.jl"))

# Initialize the optimization model
println("\nInitializing the optimization model...")
model = Model()

# ========================
# VARIABLES DEFINITION
# ========================

# Solar PV variables
if has_solar == true
    # Sizing
    if allow_solar_units == true
        @variable(model, solar_units >= 0, integer=true, base_name="Solar_Units") # [units of nominal capacity]
    else
        @variable(model, solar_units >= 0, base_name="Solar_Units") # [units of nominal capacity]
    end
    # Operation
    @variable(model, solar_production[t=1:T, s=1:S] >= 0, base_name="Solar_Production") # [kWh]
end
# Wind Turbine variables
if has_wind == true
    # Sizing
    if allow_wind_units == true
        @variable(model, wind_units >= 0, integer=true, base_name="Wind_Units") # [units of nominal capacity]
    else
        @variable(model, wind_units >= 0, base_name="Wind_Units") # [units of nominal capacity]
    end
    # Operation
    @variable(model, wind_production[t=1:T, s=1:S] >= 0, base_name="Wind_Production") # [kWh]
end
# Battery variables
if has_battery == true
    # Sizing
    if allow_battery_units == true
        @variable(model, battery_units >= 0, integer=true, base_name="Battery_Units") # [units of nominal capacity]
    else
        @variable(model, battery_units >= 0, base_name="Battery_Units") # [units of nominal capacity]
    end
    # Operation
    @variable(model, battery_charge[t=1:T, s=1:S] >= 0, base_name="Battery_Charge") # [kWh]
    @variable(model, battery_discharge[t=1:T, s=1:S] >= 0, base_name="Battery_Discharge") # [kWh]
    @variable(model, SOC[t=1:T, s=1:S], base_name="State_of_Charge") # [kWh]
end
# Backup Generator variables
if has_generator == true
    # Sizing
    if allow_generator_units == true
        @variable(model, generator_units >= 0, integer=true, base_name="Generator_Units") # [units of nominal capacity]
    else
        @variable(model, generator_units >= 0, base_name="Generator_Units") # [units of nominal capacity]
    end
    # Operation
    @variable(model, generator_production[t=1:T, s=1:S] >= 0, base_name="Generator_Production") # [kWh]
    if allow_partial_load
        @variable(model, generator_fuel_consumption[t=1:T, s=1:S] >= 0, base_name="Generator_Fuel_Consumption")  # [liters/hour]
    end
end
# Lost Load variable
if max_lost_load_share > 0
    @variable(model, lost_load[t=1:T, s=1:S] >= 0, base_name="Lost_Load") # [kWh]
end
# Grid Connection variables
if allow_grid_connection == true
    @variable(model, grid_import[t=1:T, s=1:S] >= 0, base_name="Grid_Import") # [kWh]
    if allow_grid_export == true 
        @variable(model, grid_export[t=1:T, s=1:S] >= 0, base_name="Grid_Export") # [kWh]
    end
end

println("Variables added successfully to the model.")

# ========================
# ENERGY BALANCE CONSTRAINT
# ========================

for s in 1:S
    for t in 1:T
        # Initialize the energy balance expression
        energy_balance_expr = AffExpr()

        # Add the energy production/consumption terms
        if has_solar
            energy_balance_expr += solar_production[t, s]
        end
        if has_wind
            energy_balance_expr += wind_production[t, s]
        end
        if has_battery
            energy_balance_expr += battery_discharge[t, s] - battery_charge[t, s]
        end
        if has_generator
            energy_balance_expr += generator_production[t, s]
        end
        if max_lost_load_share > 0
            energy_balance_expr += lost_load[t, s]
        end
        if allow_grid_connection
            energy_balance_expr += grid_import[t, s]
            if allow_grid_export
                energy_balance_expr -= grid_export[t, s]
            end
        end

        # Apply constraint for each time step and season
        @constraint(model, energy_balance_expr == load[t, s])
    end
end

println("Energy Balance Constraint added successfully.")

# ===============================
# OPERATION CONSTRAINTS
# ===============================

# Technology-specific constraints
if has_solar == true
    @constraint(model, [t=1:T, s=1:S], solar_production[t,s] <= solar_units * solar_unit_production[t,s])
end

if has_wind == true
    @constraint(model, [t=1:T, s=1:S], wind_production[t,s] <= wind_units * wind_power[t,s])
end

if has_battery == true
    @constraint(model, [t=1:T, s=1:S], battery_charge[t,s] <= ((battery_units * battery_nominal_capacity) / t_charge) * Δt)
    @constraint(model, [t=1:T, s=1:S], battery_discharge[t,s] <= ((battery_units * battery_nominal_capacity) / t_discharge) * Δt)
    
    # Battery SOC constraints
    @constraint(model, [t=1:T, s=1:S], SOC[t,s] >= SOC_min * (battery_units * battery_nominal_capacity))
    @constraint(model, [t=1:T, s=1:S], SOC[t,s] <= SOC_max * (battery_units * battery_nominal_capacity))
    @constraint(model, [s=1:S], SOC[1, s] == (SOC_0 * (battery_units * battery_nominal_capacity)) + (battery_charge[1,s] * η_charge - battery_discharge[1,s] * η_discharge))
    @constraint(model, [t=2:T, s=1:S], SOC[t,s] == SOC[t-1,s] + (battery_charge[t,s] * η_charge - battery_discharge[t,s] * η_discharge))
    @constraint(model, [s=1:S], SOC[T, s] == SOC_0 * (battery_units * battery_nominal_capacity))  # End-of-horizon SOC continuity
end

    # Generator Capacity Limit (if applicable)
    if has_generator == true
        @constraint(model, [t=1:T, s=1:S], generator_production[t,s] <= generator_units * generator_nominal_capacity * Δt)

        # Partial Load constraints (fuel consumtpion piecewise linear approximation)
        if allow_partial_load
            # Compute fuel consumption points
            fuel_power_points = [sampled_relative_output[i] * generator_nominal_capacity for i in eachindex(sampled_relative_output)]
            fuel_consumption_samples = [(sampled_relative_output[i] * generator_nominal_capacity) / (sampled_efficiency[i] * fuel_lhv) for i in eachindex(sampled_relative_output)]

            # Add piecewise fuel consumption linear constraints
            for s in 1:S
                for t in 1:T
                    for i in 1:(length(sampled_relative_output) - 1)
                        slope = (fuel_consumption_samples[i+1] - fuel_consumption_samples[i]) / (fuel_power_points[i+1] - fuel_power_points[i])
                
                        @constraint(model, generator_fuel_consumption[t,s] >= slope * (generator_production[t,s] - fuel_power_points[i] * generator_units) +
                                                                fuel_consumption_samples[i] * generator_units)
                    end
                end
            end
        end
    end

if allow_grid_connection == true
    @constraint(model, [t=1:T, s=1:S], grid_import[t,s] <= grid_availability[t,s] * (max_line_capacity * Δt))
    if allow_grid_export == true
        @constraint(model, [t=1:T, s=1:S], grid_export[t,s] <= grid_availability[t,s] * (max_line_capacity * Δt))
    end
end

println("Operation Constraints added successfully to the model.")

# ========================
# COST EXPRESSIONS
# ========================

# Initialize cost components
CAPEX_expr = 0
Replacement_Cost_npv_expr = 0
Subsidies_expr = 0
OPEX_fixed_expr = 0
OPEX_variable_expr = [AffExpr() for t in 1:T, s in 1:S]
Salvage_expr = 0

# Add technology costs conditionally
if has_solar == true
    CAPEX_expr += (solar_units * solar_nominal_capacity) * solar_capex
    Replacement_Cost_npv_expr += sum(((solar_units * solar_nominal_capacity * solar_capex) * discount_factor[y]) for y in solar_replacement_years; init=0)
    Subsidies_expr += ((solar_units * solar_nominal_capacity) * solar_capex) * solar_subsidy_share
    OPEX_fixed_expr += ((solar_units * solar_nominal_capacity) * solar_capex) * solar_opex
    Salvage_expr += ((solar_units * solar_nominal_capacity) * solar_capex) * salvage_solar_fraction
end

if has_wind == true
    CAPEX_expr += (wind_units * wind_nominal_capacity) * wind_capex
    Replacement_Cost_npv_expr += sum(((wind_units * wind_nominal_capacity * wind_capex) * discount_factor[y]) for y in wind_replacement_years; init=0)
    Subsidies_expr += ((wind_units * wind_nominal_capacity) * wind_capex) * wind_subsidy_share
    OPEX_fixed_expr += ((wind_units * wind_nominal_capacity) * wind_capex) * wind_opex
    Salvage_expr += ((wind_units * wind_nominal_capacity) * wind_capex) * salvage_wind_fraction
end

if has_battery == true
    CAPEX_expr += (battery_units * battery_nominal_capacity) * battery_capex
    Replacement_Cost_npv_expr += sum(((battery_units * battery_nominal_capacity * battery_capex) * discount_factor[y]) for y in battery_replacement_years; init=0)
    OPEX_fixed_expr += ((battery_units * battery_nominal_capacity) * battery_capex) * battery_opex
    Salvage_expr += ((battery_units * battery_nominal_capacity) * battery_capex) * salvage_battery_fraction
end

if has_generator == true
    CAPEX_expr += (generator_units * generator_nominal_capacity) * generator_capex
    Replacement_Cost_npv_expr += sum(((generator_units * generator_nominal_capacity * generator_capex) * discount_factor[y]) for y in generator_replacement_years; init=0)
    OPEX_fixed_expr += ((generator_units * generator_nominal_capacity) * generator_capex) * generator_opex
    Salvage_expr += ((generator_units * generator_nominal_capacity) * generator_capex) * salvage_generator_fraction
end

# Grid-related operational costs
if allow_grid_connection
    for s in 1:S
        for t in 1:T
            OPEX_variable_expr[t, s] += grid_import[t, s] * grid_cost[t, s]
            if allow_grid_export
                OPEX_variable_expr[t, s] -= grid_export[t, s] * grid_price[t, s]
            end
        end
    end
end

# Generator fuel cost (variable OPEX)
if has_generator
    for s in 1:S
        for t in 1:T
            if allow_partial_load
                # Use fuel consumption for fuel cost calculation
                OPEX_variable_expr[t, s] += generator_fuel_consumption[t, s] * fuel_cost
            else
                # Use generator production for fuel cost calculation
                OPEX_variable_expr[t, s] += (generator_production[t, s] / fuel_lhv) * fuel_cost
            end
        end
    end
end

# Define JuMP expressions in the model
@expression(model, CAPEX, CAPEX_expr)
@expression(model, Replacement_Cost_npv, Replacement_Cost_npv_expr)
@expression(model, Subsidies, Subsidies_expr)
@expression(model, OPEX_fixed, OPEX_fixed_expr)
@expression(model, OPEX_variable[t=1:T, s=1:S], OPEX_variable_expr[t,s])
@expression(model, OPEX_npv, sum((sum(season_weights[s] * sum(OPEX_variable_expr[t, s] for t in 1:T) for s in 1:S) + OPEX_fixed) * discount_factor[y] for y in 1:project_lifetime))
@expression(model, Salvage_npv, Salvage_expr * discount_factor[project_lifetime])
@expression(model, NPC, (CAPEX - Subsidies) + Replacement_Cost_npv + OPEX_npv - Salvage_npv)

println("Cost Expressions added successfully to the model.")

# ========================
# OPTIMIZATION CONSTRAINTS
# ========================
# Lost Load constraint
if max_lost_load_share > 0
    @constraint(model, sum(season_weights[s] * sum(lost_load[t, s] for t in 1:T) for s in 1:S) <= max_lost_load_share * sum(season_weights[s] * sum(load[t, s] for t in 1:T) for s in 1:S))
end

# CAPEX cap constraint
@constraint(model, CAPEX <= max_capex)

# Renewable penetration constraint
if min_res_share > 0
    # Initialize total renewable and total generation expressions per season
    total_renewable_expr = Dict((t, s) => AffExpr() for t in 1:T, s in 1:S)  # Renewable generation
    total_generation_expr = Dict((t, s) => AffExpr() for t in 1:T, s in 1:S)  # Total generation

    # Compute renewable and total generation expressions per time step and season
    for s in 1:S
        for t in 1:T
            if has_solar
                total_renewable_expr[t, s] += solar_production[t, s]
                total_generation_expr[t, s] += solar_production[t, s]
            end
            if has_wind
                total_renewable_expr[t, s] += wind_production[t, s]
                total_generation_expr[t, s] += wind_production[t, s]
            end
            if has_generator
                total_generation_expr[t, s] += generator_production[t, s]
            end
        end
    end

    # Apply the renewable penetration constraint for each season
    if has_solar || has_wind
        annual_renewable_production = sum(season_weights[s] * sum(total_renewable_expr[t, s] for t in 1:T) for s in 1:S)
        annual_total_generation = sum(season_weights[s] * sum(total_generation_expr[t, s] for t in 1:T) for s in 1:S)
        @constraint(model, annual_renewable_production >= min_res_share * annual_total_generation)
    end
end

# Max fuel consumption constraint
if has_generator && fuel_consumption_limit
    for s in 1:S
        for t in 1:T
            Fuel_consumption[t, s] += (generator_production[t, s] / fuel_lhv)
        end
    end
    @constraint(model, [t=1:T, s=1:S], sum(season_weights[s] * sum(Fuel_consumption[t, s] for t in 1:T) for s in 1:S) <= max_fuel_consumption)
end

println("Optimization constraints added successfully to the model.")

# Objective Function: Minimization of NPC
@objective(model, Min, NPC)

println("Model initialized successfully")

# SOLVING THE MODEL
# -----------------

# Initialize Ipopt solver
optimizer = optimizer_with_attributes(Gurobi.Optimizer)

# Setting solver options
solver_settings = parameters["solver_settings"]["gurobi_options"]
println("\nInitializing the solver (Gurobi)...")
for (key, value) in solver_settings
    set_optimizer_attribute(optimizer, key, value)
end

# Attach the solver to the model
set_optimizer(model, optimizer)

# Solve the optimization problem
@time optimize!(model)
solution_summary(model, verbose = true)

# Evaluate solution status
status = termination_status(model)

if status == MOI.INFEASIBLE
    error("\nOptimization result: INFEASIBLE. The model has no feasible solution. Please check constraints and input parameters.")
else
    println("\nOptimization completed with status: ", status)
end

# POST PROCESSING
# -----------------

# Display results
include(joinpath(@__DIR__, "display_results.jl"))

# Export results to CSV
write_sizing_to_csv(model, parameters)
write_costs_to_csv(model, parameters)
write_dispatch_to_csv(model, parameters)
write_operation_indicators_to_csv(model, parameters, season_weights)


