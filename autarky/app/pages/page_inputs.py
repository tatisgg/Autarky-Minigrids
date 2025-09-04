import os
import yaml
import streamlit as st
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

from typing import Dict, List


def plot_time_series(csv_path:str, title:str, y_label:str, multiselect_key:str) -> None:
    """Plot seasonal time series from a CSV file with user-selectable seasons."""
    # Check if the CSV file exists
    if not os.path.isfile(csv_path):
        st.warning(f"{os.path.basename(csv_path)} not found.")
        return

    # Read the CSV
    df = pd.read_csv(csv_path)
    seasons = list(df.columns)

    # Select seasons to visualize
    selected_seasons = st.multiselect(
        f"Select seasons to visualize for {title.lower()}",
        seasons,
        default=[seasons[0]] if seasons else [],
        key=multiselect_key)

    # Check if any seasons are selected
    if not selected_seasons:
        st.warning(f"Please select at least one season for {title.lower()}.")
        return
    
    # Plot the selected seasons data
    fig, ax = plt.subplots(figsize=(10, 5))
    for season in selected_seasons:
        ax.plot(df[season], label=season)
    ax.set_title(f"{title} per Season")
    ax.set_xlabel("Timestep")
    ax.set_ylabel(y_label)
    ax.legend(title="Season")
    ax.grid(True)
    st.pyplot(fig)

def compute_error_metrics(errors_path: str, prefix: str, season_names: List[str]) -> Dict[str, Dict[str, float]]:
    """Compute RMSE, MAE, and Bias for each seasonal error file."""
    metrics = {}

    for i, season in enumerate(season_names, start=1):
        file_path = os.path.join(errors_path, f"{prefix}_{i}.csv")
        if os.path.exists(file_path):
            df = pd.read_csv(file_path)
            errors = df.values.flatten()
            metrics[season] = {
                "Root Mean Square Error (RMSE)": np.sqrt(np.mean(errors**2)),
                "Mean Absolute Error (MAE)": np.mean(np.abs(errors)),
                "Bias (Mean Error)": np.mean(errors)}
    return metrics

def plot_error_metrics(metrics: Dict[str, Dict[str, float]], title: str) -> None:
    """Plot RMSE, MAE, and Bias per season as bar charts."""
    if not metrics:
        st.warning(f"No error data available for {title.lower()}.")
        return

    df = pd.DataFrame(metrics).T  # seasons as index, metrics as columns
    st.bar_chart(df)

def plot_mae_over_time(errors_path: str, prefix: str, season_names: List[str], multiselect_key: str, title: str) -> None:
    """Plot MAE per simulation for each season."""
    mae_curves = {}

    for i, season in enumerate(season_names, start=1):
        file_path = os.path.join(errors_path, f"{prefix}_{i}.csv")
        if os.path.exists(file_path):
            df = pd.read_csv(file_path)
            # MAE per simulation: mean(abs(error)) across time for each simulation
            mae_curves[season] = np.mean(np.abs(df), axis=0)

    if not mae_curves:
        st.warning(f"No MAE data found for {prefix}.")
        return

    selected_seasons = st.multiselect(
        f"Select seasons to visualize MAE over simulations for {title.lower()}",
        list(mae_curves.keys()),
        default=[season_names[0]],
        key=multiselect_key
    )

    if not selected_seasons:
        st.warning(f"Please select at least one season to visualize MAE for {title.lower()}.")
        return

    fig, ax = plt.subplots(figsize=(10, 5))
    for season in selected_seasons:
        mae_values = mae_curves[season]
        ax.plot(range(1, len(mae_values) + 1), mae_values, label=season)

    ax.set_title(f"{title} - MAE Over Simulations")
    ax.set_xlabel("Simulation")
    ax.set_ylabel("MAE (kWh)")
    ax.legend(title="Season")
    ax.grid(True)

    # Improve x-axis layout
    ax.set_xticks(range(0, len(mae_values) + 1, max(1, len(mae_values) // 10)))  # 10 ticks max
    ax.tick_params(axis='x', rotation=45)

    st.pyplot(fig)

def visualize_inputs()-> None:
    """Main function to visualize inputs and time series data."""
    # Set the page title and header
    st.title("Visualize Inputs and Time Series Data")
    st.subheader("Select a project folder")

    # List available projects
    projects_root = "projects"
    project_folders = [name for name in os.listdir(projects_root) if os.path.isdir(os.path.join(projects_root, name))]
    # Check if there are any project folders
    if not project_folders:
        st.warning("No project folders found in the 'projects' directory.")
        return

    # Select a project folder
    selected_project = st.selectbox("Project:", project_folders)
    # Define input and results paths
    project_path = os.path.join(projects_root, selected_project)
    inputs_path = os.path.join(project_path, "inputs")

    # Load parameters.yaml
    parameters_file = os.path.join(inputs_path, "parameters.yaml")
    # Check if the parameters file exists
    if not os.path.isfile(parameters_file):
        st.error("parameters.yaml file not found in the inputs folder.")
        return
    with open(parameters_file, "r") as file:
        parameters = yaml.safe_load(file)

    st.divider()

    # Display project location and time settings
    st.subheader("📍 Project Location")
    project_settings = parameters.get("project_settings", {})
    latitude = project_settings.get("latitude")
    longitude = project_settings.get("longitude")

    if latitude is not None and longitude is not None:
        st.map(pd.DataFrame({"lat": [latitude], "lon": [longitude]}))
    else:
        st.warning("Location coordinates not available.")

    st.divider()
    st.subheader("📅 Project Time Settings")
    col1, col2, col3 = st.columns(3)
    col1.metric("Start Date", str(project_settings.get("start_date", "N/A")))
    col2.metric("Project Lifetime (years)", project_settings.get("project_lifetime", "N/A"))
    col3.metric("Time Step Duration (hours)", project_settings.get("time_step_duration", "N/A"))

    st.markdown("### Seasonality Settings")
    time_series_settings = parameters.get("time_series_settings", {})
    st.write(f"**Data Type:** {time_series_settings.get('data_type', 'N/A')}")
    st.write(f"**Seasonality Enabled:** {time_series_settings.get('seasonality', 'N/A')}")
    st.write(f"**Number of Seasons:** {time_series_settings.get('num_seasons', 'N/A')}")

    if time_series_settings.get("seasonal_definition"):
        st.write("**Seasonal Definition (Months):**")
        for season, months in time_series_settings["seasonal_definition"].items():
            st.write(f"- Season {season}: {months}")

    st.divider()
    
    st.subheader("🔒 Optimization Constraints")

    opt_settings = parameters.get("optimization_settings", {})
    uncertainty_settings = parameters.get("uncertainty_settings", {})

    # Helper to safely format numeric values
    def fmt_pct(val):
        return f"{val:.2%}" if isinstance(val, (int, float)) else "N/A"

    def fmt_dollars(val):
        return f"${val:,.0f}" if isinstance(val, (int, float)) else "N/A"

    def fmt_hours(val):
        return f"{val} h" if isinstance(val, (int, float)) else "N/A"

    constraints = []
    constraints.append(("Maximum Lost Load Share", fmt_pct(opt_settings.get("max_lost_load_share"))))
    constraints.append(("Maximum CAPEX", fmt_dollars(opt_settings.get("max_capex"))))
    constraints.append(("Minimum Renewable Penetration", fmt_pct(opt_settings.get("min_res_share"))))

    # Add uncertainty settings if present
    if "outage_duration" in uncertainty_settings:
        constraints.append(("Average Daily Outage Duration", fmt_hours(uncertainty_settings["outage_duration"])))
    if "outage_probability" in uncertainty_settings:
        constraints.append(("Probability of Daily Outage", fmt_pct(uncertainty_settings["outage_probability"])))
    if "islanding_probability" in uncertainty_settings:
        constraints.append(("Probability of Successful Islanding", fmt_pct(uncertainty_settings["islanding_probability"])))

    constraints_df = pd.DataFrame(constraints, columns=["Constraint", "Value"])
    st.table(constraints_df)

    st.divider()
    # Display components and their statuses
    st.subheader("⚡ Enabled System Components")

    solar = parameters.get("solar_pv", {})
    wind = parameters.get("wind_turbine", {})
    battery = parameters.get("battery", {})
    generator = parameters.get("generator", {})
    grid = parameters.get("optimization_settings", {}).get("on_grid", {})

    components = {
        "Solar PV": solar.get("enabled", False),
        "Wind Turbine": wind.get("enabled", False),
        "Battery": battery.get("enabled", False),
        "Backup Generator": generator.get("enabled", False),
        "Grid Connection": grid.get("allow_grid_connection", False)
    }

    # Helper function to format a setting row
    def component_detail(label, value, unit=""):
        st.write(f"- **{label}:** {value} {unit}")

    for component, enabled in components.items():
        if enabled:
            st.success(f"✅ {component} Enabled")

            if component == "Solar PV":
                component_detail("Unit Commitment", solar.get("allow_units", False))
                component_detail("Nominal Capacity", solar.get("technical", {}).get("nominal_capacity", "N/A"), "kW")

            elif component == "Wind Turbine":
                component_detail("Unit Commitment", wind.get("allow_units", False))
                component_detail("Nominal Capacity", wind.get("technical", {}).get("nominal_capacity", "N/A"), "kW")

            elif component == "Battery":
                component_detail("Unit Commitment", battery.get("allow_units", False))
                component_detail("Nominal Capacity", battery.get("nominal_capacity", "N/A"), "kWh")

            elif component == "Backup Generator":
                component_detail("Unit Commitment", generator.get("allow_units", False))
                component_detail("Nominal Capacity", generator.get("nominal_capacity", "N/A"), "kW")
                component_detail("Partial Load Enabled", generator.get("allow_partial_load", False))
                fuel_settings = generator.get("fuel", {})
                if fuel_settings.get("fuel_consumption_limit", False):
                    component_detail("Max Fuel Consumption", fuel_settings.get("max_fuel_consumption", "N/A"), "liters/year")

            elif component == "Grid Connection":
                component_detail("Grid Export Allowed", grid.get("allow_grid_export", False))
                component_detail("Max Grid Capacity", grid.get("max_capacity", "N/A"), "kW")

        else:
            st.error(f"❌ {component} Disabled")

    st.divider()

    # Display time series data plots
    st.subheader("📊 Time Series Data")

    # Load demand plot
    st.markdown("### Load Demand")
    plot_time_series(
        os.path.join(inputs_path, "load.csv"),
        title="Load Demand",
        y_label="Load (kWh)",
        multiselect_key="load")

    # Solar PV production plot
    if parameters.get("solar_pv", {}).get("enabled", False):
        st.divider()
        st.markdown("### Solar PV Production")
        plot_time_series(
            os.path.join(inputs_path, "solar_production.csv"),
            title="Solar PV Production",
            y_label="Production (kWh)",
            multiselect_key="solar")

    # Wind turbine production plot
    if parameters.get("wind_turbine", {}).get("enabled", False):
        st.divider()
        st.markdown("### Wind Turbine Production")
        plot_time_series(
            os.path.join(inputs_path, "wind_production.csv"),
            title="Wind Turbine Production",
            y_label="Production (kWh)",
            multiselect_key="wind")

    # --- Grid-related plots ---
    if parameters.get("optimization_settings", {}).get("on_grid", {}).get("allow_grid_connection", False):
        st.divider()
        st.markdown("### Grid Electricity Cost and Price")

        # --- Grid Cost ---
        plot_time_series(
            os.path.join(inputs_path, "grid_cost.csv"),
            title="Grid Electricity Cost",
            y_label="Cost (USD/kWh)",
            multiselect_key="grid_cost")

        # --- Grid Price ---
        plot_time_series(
            os.path.join(inputs_path, "grid_price.csv"),
            title="Grid Electricity Price",
            y_label="Price (USD/kWh)",
            multiselect_key="grid_price")
        
    # If uncertainty settings are present, compute and show error metrics
    uncertainty_settings = parameters.get("uncertainty_settings")
    errors_path = os.path.join(inputs_path, "errors")
    season_names = ["Winter", "Spring", "Summer", "Fall"]

    if uncertainty_settings:
        st.divider()
        st.subheader("📉 Forecast Error Metrics")

        st.markdown("### Load Forecast Errors")
        load_metrics = compute_error_metrics(errors_path, "load_errors", season_names)
        plot_error_metrics(load_metrics, "Load Forecast Errors")
        plot_mae_over_time(errors_path, "load_errors", season_names, multiselect_key="load_rmse", title="Load Forecast")

        st.markdown("### Solar Forecast Errors")
        solar_metrics = compute_error_metrics(errors_path, "solar_errors", season_names)
        plot_error_metrics(solar_metrics, "Solar Forecast Errors")
        plot_mae_over_time(errors_path, "solar_errors", season_names, multiselect_key="solar_rmse", title="Solar Forecast")

        if parameters.get("wind_turbine", {}).get("enabled", False):
            st.markdown("### Wind Forecast Errors")
            wind_metrics = compute_error_metrics(errors_path, "wind_errors", season_names)
            plot_error_metrics(wind_metrics, "Wind Forecast Errors")
            plot_mae_over_time(errors_path, "wind_errors", season_names, multiselect_key="wind_rmse", title="Wind Forecast")

page = st.Page(visualize_inputs, title="Visualize Inputs", icon="📂")
