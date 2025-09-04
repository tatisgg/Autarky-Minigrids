println("\n------ System Optimization Settings ------")

println("\nProject Time Settings:")
println(" Project Time Horizon: ", project_lifetime, " years")
println(" Number of Operation Time Steps: ", operation_time_steps, " hours")
println(" Number of Seasons: ", num_seasons)

println("\nOptimization Settings:")
println("  System Components: ", has_solar ? "Solar PV, " : "", has_wind ? "Wind Turbine, " : "", has_battery ? "Battery Bank, " : "", has_generator ? "Backup Generator" : "")
println("  Maximum Lost Load Share: ", max_lost_load_share*100, " %")
println("  Maximum Renewable Penetration: ", min_res_share*100, " %")
if allow_grid_connection
    println("  Grid Connection: ", allow_grid_connection ? "Yes" : "No")
    println("  Grid Export: ", allow_grid_export ? "Yes" : "No")
end

println("\n------ System Optimization Results ------")

println("\nSystem Sizing:")
if has_solar
    println("  Solar Capacity: ", round(value(model[:solar_units]) * solar_nominal_capacity, digits=2), " kW")
end
if has_wind 
    println("  Wind Capacity: ", round(value(model[:wind_units]) * wind_nominal_capacity, digits=2), " kW")
end
if has_battery 
    println("  Battery Capacity: ", round(value(model[:battery_units]) * battery_nominal_capacity, digits=2), " kWh")
end
if has_generator 
    println("  Generator Capacity: ", round(value(model[:generator_units]) * generator_nominal_capacity, digits=2), " kW")
end

println("\nProject Costs:")
println("  Net Present Cost: ", round(value(model[:NPC]) / 1000, digits=2), " k$currency")
println("  Total Investment Cost: ", round(value(model[:CAPEX]) / 1000, digits=2), " k$currency")
println("  Total Subsidies: ", round(value(model[:Subsidies]) / 1000, digits=2), " k$currency")
println("  Discounted Replacement Cost: ", round(value(model[:Replacement_Cost_npv]) / 1000, digits=2), " k$currency")
println("  Discounted Total Operation Cost: ", round(value(model[:OPEX_npv]) / 1000, digits=2), " k$currency")

if allow_grid_connection
    
    total_grid_cost = sum(season_weights[s] * (value(model[:grid_import][t, s]) * grid_cost[t,s]) for t in 1:T, s in 1:S)
    println("  Total Annual Grid Cost: ", round(total_grid_cost / 1000, digits=2), " k$currency/year")

    if allow_grid_export
        total_grid_revenue = sum(season_weights[s] * (value(model[:grid_export][t, s]) * grid_price[t,s]) for t in 1:T, s in 1:S)
        println("  Total Annual Grid Revenue: ", round(total_grid_revenue / 1000, digits=2), " k$currency/year")
    end
end

println("  Discounted Salvage Value: ", round(value(model[:Salvage_npv]) / 1000, digits=2), " k$currency")
actualized_demand = sum(sum(season_weights[s] * load[t, s] for t in 1:T, s in 1:S) * discount_factor[y] for y in 1:project_lifetime)
lcoe = value(model[:NPC]) / actualized_demand
println("  Levelized Cost of Energy (LCOE) over actualized met demand: ", round(lcoe, digits=2), " $currency/kWh")

println("\nOptimal Operation:")

# Solar production & curtailment
if has_solar 
    total_solar_production = sum(season_weights[s] * value(model[:solar_production][t, s]) for t in 1:T, s in 1:S)
    println("  Total Annual Solar Production: ", round(total_solar_production / 1000, digits=2), " MWh/year")

    total_solar_max_production = sum(season_weights[s] * (solar_unit_production[t, s] * value(model[:solar_units])) for t in 1:T, s in 1:S)
    total_curtailment = total_solar_max_production - total_solar_production
    println("  Annual Solar Curtailment Share: ", round((total_curtailment / total_solar_max_production) * 100, digits=2), " % of total solar production")
end

# Wind production & curtailment
if has_wind 
    total_wind_production = sum(season_weights[s] * value(model[:wind_production][t, s]) for t in 1:T, s in 1:S)
    println("  Total Annual Wind Production: ", round(total_wind_production / 1000, digits=2), " MWh/year")

    total_wind_max_production = sum(season_weights[s] * (wind_power[t, s] * value(model[:wind_units])) for t in 1:T, s in 1:S)
    total_curtailment = total_wind_max_production - total_wind_production
    println("  Annual Wind Curtailment Share: ", round((total_curtailment / total_wind_max_production) * 100, digits=2), " % of total wind production")
end

# Battery charge & discharge
if has_battery
    total_battery_discharge = sum(season_weights[s] * value(model[:battery_discharge][t, s]) for t in 1:T, s in 1:S)
    total_battery_charge = sum(season_weights[s] * value(model[:battery_charge][t, s]) for t in 1:T, s in 1:S)

    println("  Total Annual Battery Discharge: ", round(total_battery_discharge / 1000, digits=2), " MWh/year")
    println("  Total Annual Battery Charge: ", round(total_battery_charge / 1000, digits=2), " MWh/year")
end

# Generator production
if has_generator
    total_generator_production = sum(season_weights[s] * value(model[:generator_production][t, s]) for t in 1:T, s in 1:S)
    println("  Total Annual Generator Production: ", round(total_generator_production / 1000, digits=2), " MWh/year")
    total_fuel_consumption = sum(season_weights[s] * (value(model[:generator_production][t, s]) / fuel_lhv) for t in 1:T, s in 1:S)
    println("  Total Annual Fuel Consumption: ", round(total_fuel_consumption, digits=2), " liters/year")
    if allow_partial_load
        total_energy_production = sum(season_weights[s] * value(model[:generator_production][t, s]) for t in 1:T, s in 1:S if value(model[:generator_units]) > 0; init=0)
        avg_efficiency = value(model[:generator_units]) > 0 ? total_energy_production / total_fuel_consumption : 0
        println("  Average Generator Efficiency: ", round(avg_efficiency, digits=2), " kWh/liter")
        avg_load_factor = value(model[:generator_units]) > 0 ? total_energy_production / (value(model[:generator_units]) * generator_nominal_capacity * 8760) : 0
        println("  Average Generator Load Factor: ", round(avg_load_factor * 100, digits=2), " %")
    end
end 

# Grid import/export
if allow_grid_connection
    total_grid_import = sum(season_weights[s] * value(model[:grid_import][t, s]) for t in 1:T, s in 1:S)
    println("  Total Annual Grid Import: ", round(total_grid_import / 1000, digits=2), " MWh/year")

    if allow_grid_export
        total_grid_export = sum(season_weights[s] * value(model[:grid_export][t, s]) for t in 1:T, s in 1:S)
        println("  Total Annual Grid Export: ", round(total_grid_export / 1000, digits=2), " MWh/year")
    end
    # Grid availability
    average_grid_availability = sum(season_weights[s] * grid_availability[t, s] for t in 1:T, s in 1:S)
    println("  Average Annual Grid Availability: ", round((average_grid_availability / 8760) * 100, digits=2), " %")
end

# Compute lost load share safely
if max_lost_load_share > 0
    total_lost_load = sum(season_weights[s] * value(model[:lost_load][t, s]) for t in 1:T, s in 1:S)
    total_load = sum(season_weights[s] * load[t, s] for t in 1:T, s in 1:S)
    lost_load_share = (total_lost_load / total_load) * 100

    println("  Lost Load Share: ", round(lost_load_share, digits=2), " % of total load")
end

# Compute renewable penetration safely
if has_solar || has_wind
    total_renewable_generation = sum(season_weights[s] * value(model[:solar_production][t, s]) for t in 1:T, s in 1:S if has_solar; init=0) +
                                 sum(season_weights[s] * value(model[:wind_production][t, s]) for t in 1:T, s in 1:S if has_wind; init=0)

    total_generation = total_renewable_generation + sum(season_weights[s] * value(model[:generator_production][t, s]) for t in 1:T, s in 1:S if has_generator; init=0)

    if total_generation > 0  # Avoid division by zero
        renewable_penetration = (total_renewable_generation / total_generation) * 100
        println("  Renewable Penetration: ", round(renewable_penetration, digits=2), " % of total generation")
    else
        println("  Renewable Penetration: N/A (No generation)")
    end
end

println("\n----------------------------------------")