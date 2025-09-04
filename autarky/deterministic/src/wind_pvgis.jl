"Module to estimate wind power output using PVGIS data."

# Import necessary packages
using HTTP, JSON, CSV, DataFrames, YAML

"""
Function to download PVGIS data from a given URL.
"""
function download_pvgis_data(url::String)
    println("\nDownloading PVGIS data from $url...")
    response = HTTP.get(url)
    if response.status == 200
        println("Data downloaded succesfully!")
        return JSON.parse(String(response.body))
    else
        error("Response error $(response.status): $(String(response.body))")
    end
end

"""
Read wind turbine power curve from CSV.
It assumes the CSV file has two columns: wind speeds and power output in kW.
"""
function load_power_curve(csv_file::String)

    # Read CSV file into DataFrame
    df = CSV.read(csv_file, DataFrame; delim=';', decimal=',', header=true)
    wind_speeds = df[:, 1]   # First column: wind speeds
    power_output = df[:, 2]  # Second column: power output (kW)

    return wind_speeds, power_output
end

"""
Compute wind speed at rotor height using power law.

Arguments:
- wind_speed_10m: Wind speed at 10m height.
- alpha: Wind shear exponent.
- Z_rot: Rotor height.

Returns:
- Wind speed at rotor height.
"""
function rotor_wind_speed(wind_speed_10m::Vector{Float64}, alpha::Float64, Z_rot::Float64)
    return wind_speed_10m .* (Z_rot / 10) .^ alpha
end

"""
Compute air density at rotor height.

Arguments:
- Z: Height above sea level.
- T2M: Air temperature at 2m height.

Returns:
- Air density at rotor height.
"""
function air_density(Z::Float64, T2M::Vector{Float64})

    # Empirical formula for air density
    DT = -0.0066 * (Z - 2)  # Temperature lapse rate
    P = 101.29 - (0.011837) * Z + (4.793 * (10^-7)) * Z^2  # Pressure at height Z
    R_molar = 8.314 / 28.96  # Gas constant / Molar mass of dry air
    
    return P ./ (R_molar * (T2M .+ 273.15 .+ DT))  # Density formula
end

"""
Interpolate power output from the turbine power curve.
It is used to estimate the power output at a given wind speed.
"""
function interpolate_power_curve(power_curve_speeds, power_curve_output, wind_speeds)
    return [interp_linear(wind, power_curve_speeds, power_curve_output) for wind in wind_speeds]
end

"""
Linear interpolation function
"""
function interp_linear(x, xp, fp)
    if x <= minimum(xp)
        return first(fp)
    elseif x >= maximum(xp)
        return last(fp)
    else
        return fp[argmin(abs.(xp .- x))]
    end
end

"""
Compute wind turbine power output.

Arguments:
- power_curve_speeds: Wind speeds from the power curve.
- power_curve_output: Power output from the power curve.
- WS_rotor_lst: Wind speeds at rotor height.
- ro_air_lst: Air density at rotor height.
- surface_area: Surface area of the wind turbine.
- drivetrain_efficiency: Drivetrain efficiency of the wind turbine.

Returns:
- energy_wind: Wind Turbine Power output in kW.
"""
function compute_wind_power(power_curve_speeds, power_curve_output, WS_rotor_lst, ro_air_lst, surface_area, drivetrain_efficiency)
    
    # Calculate energy available in the wind and turbine power output
    energy_wind = 0.5 .* ro_air_lst .* surface_area .* WS_rotor_lst .^ 3
    energy_turbine = interpolate_power_curve(power_curve_speeds, power_curve_output, WS_rotor_lst) .* drivetrain_efficiency
    Cp = energy_turbine ./ energy_wind # Calculate power coefficient (turbine efficiency in extracting power from the wind)
    Cp[energy_wind .== 0] .= 0  # Avoid division by zero

    return energy_turbine, Cp
end

"""
Function to build PVGIS URL from latitude and longitude.
"""
function build_pvgis_url(lat, lon)

    # Construct the URL dynamically
    base_url = "https://re.jrc.ec.europa.eu/api/tmy?"
    pvgis_url = string(base_url, "lat=", lat, "&lon=", lon, "&outputformat=json")

    return pvgis_url
end

"""
Estimate wind power output using PVGIS data.

Arguments:
- pvgis_url: URL to download PVGIS data.
- turbine_technical: Wind turbine technical parameters.
- wind_power_curve_path: Path to the wind power curve CSV file.

Returns:
- DataFrame with wind power output.
"""
function estimate_wind_power(pvgis_url, turbine_technical, wind_power_curve_path)

    # Download PVGIS wind data
    data = download_pvgis_data(pvgis_url)
    hourly_data = data["outputs"]["tmy_hourly"]

    # Extract wind turbine parameters
    turbine_type = turbine_technical["turbine_type"]
    rot_diam = turbine_technical["rotor_diameter"]
    rot_height = turbine_technical["hub_height"]
    drivetrain_efficiency = turbine_technical["drivetrain_efficiency"]
    surface_roughness = turbine_technical["surface_roughness"]

    # Calculate surface area based on turbine type
    if turbine_type == "Horizontal Axis"
        surface_area = π * (rot_diam^2) / 4
    elseif turbine_type == "Vertical Axis"
        surface_area = rot_height * π * rot_diam
    else
        raiseError("Invalid turbine type. Please use 'Horizontal Axis' or 'Vertical Axis'.")
    end

    # Load power curve
    power_curve_speeds, power_curve_output = load_power_curve(wind_power_curve_path)

    # Extract wind speeds and temperature
    WS_10m_list = [d["WS10m"] for d in hourly_data]
    T2M_list = [d["T2m"] for d in hourly_data]

    # Calculate wind shear exponent
    alpha = 0.096 * log10(surface_roughness) + 0.16 * (log10(surface_roughness))^2 + 0.24

    # Calculate wind speeds at rotor height
    WS_rotor_lst = rotor_wind_speed(WS_10m_list, alpha, rot_height)

    # Compute air density at rotor height
    ro_air_lst = air_density(rot_height, T2M_list)

    # Calculate wind turbine power output
    turbine_output, Cp = compute_wind_power(power_curve_speeds, power_curve_output, WS_rotor_lst, ro_air_lst, surface_area, drivetrain_efficiency)

    # Return wind power output and power coefficient
    return turbine_output, Cp
end