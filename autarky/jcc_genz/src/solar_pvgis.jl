using HTTP, JSON, CSV, DataFrames, YAML, Statistics

"""
Function to download PVGIS data from a given URL.
"""
function download_pvgis_data(url::String)
    println("\nDownloading PVGIS data from $url...")
    response = HTTP.get(url)
    if response.status == 200
        println("Data downloaded successfully!")
        return JSON.parse(String(response.body))
    else
        error("Response error $(response.status): $(String(response.body))")
    end
end

"""
Function to build PVGIS URL for solar data.
"""
function build_pvgis_url(lat, lon)
    base_url = "https://re.jrc.ec.europa.eu/api/tmy?"
    return string(base_url, "lat=", lat, "&lon=", lon, "&outputformat=json")
end

"""
Calculate irradiation on a tilted surface.
"""
function compute_tilted_irradiance(H_lst, I_diff_lst, lat, lon, day_of_year, tilt, azimuth, albedo)
    B = (day_of_year - 1) * 2 * π / 365
    delta = deg2rad(23.45 * sin(deg2rad((day_of_year + 284) * 360 / 365)))
    phi = deg2rad(lat)
    beta = deg2rad(tilt)
    gamma = deg2rad(azimuth)
    
    # Equation of Time (EoT)
    EoT = 229.2 * (0.000075 + 0.001868 * cos(B) - 0.032077 * sin(B) - 0.014615 * cos(2B) - 0.04089 * sin(2B))
    
    I_tilt = Float64[]
    for hour in 0:23
        utc_time = hour
        t_s = utc_time + 4 * lon / 60 + EoT / 60
        omega = deg2rad(15 * (t_s - 12))
        I_tot = H_lst[hour + 1]
        I_diff = I_diff_lst[hour + 1]
        if I_tot - I_diff < 0
            I_tot = I_diff
        end
        
        theta_z = abs(acos(cos(phi) * cos(delta) * cos(omega) + sin(phi) * sin(delta)))
        gamma_s = sign(omega) * abs(acos((cos(theta_z) * sin(phi) - sin(delta)) / (sin(theta_z) * cos(phi))))
        theta_i = acos(cos(theta_z) * cos(beta) + sin(theta_z) * sin(beta) * cos(gamma_s - gamma))
        
        if cos(theta_z) < 0.1
            theta_i = π / 2
        end
        
        I_tilt_iso = I_diff * (1 + cos(beta)) / 2 + I_tot * albedo * (1 - cos(beta)) / 2 + (I_tot - I_diff) * cos(theta_i) / cos(theta_z)
        push!(I_tilt, max(I_tilt_iso, 0))
    end
    return I_tilt
end

"""
Estimate solar PV power output using PVGIS data.
"""
function estimate_solar_power(pvgis_url, lat, lon, pv_params)
    # Download PVGIS solar data
    data = download_pvgis_data(pvgis_url)
    hourly_data = data["outputs"]["tmy_hourly"]
    # Extract solar PV parameters
    nom_power = pv_params["nominal_capacity"]
    tilt, azimuth = pv_params["tilt"], pv_params["azimuth"]
    albedo = pv_params["albedo"]
    k_T = pv_params["temperature_coefficient"]
    NMOT, T_NMOT, G_NMOT = pv_params["NMOT"], pv_params["T_NMOT"], pv_params["G_NMOT"]
    
    energy_PV = Float64[]
    for day in 1:365
        H_lst = [d["G(h)"] / 1000 for d in hourly_data[(day-1)*24+1:day*24]]
        I_diff_lst = [d["Gd(h)"] / 1000 for d in hourly_data[(day-1)*24+1:day*24]]
        I_tilt = compute_tilted_irradiance(H_lst, I_diff_lst, lat, lon, day, tilt, azimuth, albedo)
        
        T_amb = [d["T2m"] for d in hourly_data[(day-1)*24+1:day*24]]
        T_cell = [T_amb[h] + ((NMOT - T_NMOT) / G_NMOT) * I_tilt[h] * 1000 for h in 1:24]
        daily_energy = [(I_tilt[h] * nom_power * (1 + (k_T / 100) * (T_cell[h] - 25))) for h in 1:24]
        append!(energy_PV, daily_energy)
    end
    
    # Return energy output as a vector
    return energy_PV
end