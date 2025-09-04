import os
import streamlit as st
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

color_dict = {
    "Solar Production (kWh)": "#FFD700",
    "Battery": "#ADD8E6",
    "Generator Production (kWh)": "#00008B",
    "Grid Import (kWh)": "#800080",
    "Grid Export (kWh)": "#800080",
    "Solar Curtailment (kWh)": "#FFA500",
    "Lost Load (kWh)": "#FF0000",
    "Load Demand (kWh)": "#000000",
}

def create_dispatch_plot_streamlit(data: pd.DataFrame, on_grid: bool, allow_grid_export: bool, lost_load: bool, uncertainty: bool) -> None:
    fig, ax1 = plt.subplots(figsize=(12, 6))
    x = range(len(data))
    cumulative_outflow = np.zeros(len(data))
    cumulative_inflow = np.zeros(len(data))

    ax1.fill_between(x, cumulative_outflow, cumulative_outflow + data["Solar Production (kWh)"],
                     label="Solar Production", color=color_dict["Solar Production (kWh)"], alpha=0.5)
    cumulative_outflow += data["Solar Production (kWh)"]

    if "Battery Discharge (kWh)" in data.columns and "Battery Charge (kWh)" in data.columns:
        net_battery_flow = data["Battery Discharge (kWh)"] - data["Battery Charge (kWh)"]
        net_discharge = net_battery_flow.clip(lower=0)
        net_charge = -net_battery_flow.clip(upper=0)

        ax1.fill_between(x, cumulative_outflow, cumulative_outflow + net_discharge,
                         label="Battery Discharge", color=color_dict["Battery"], alpha=0.5)
        cumulative_outflow += net_discharge

        ax1.fill_between(x, -cumulative_inflow, -(cumulative_inflow + net_charge),
                         label="Battery Charge", color=color_dict["Battery"], alpha=0.5)
        cumulative_inflow += net_charge

    ax1.fill_between(x, cumulative_outflow, cumulative_outflow + data["Generator Production (kWh)"],
                     label="Generator Production", color=color_dict["Generator Production (kWh)"], alpha=0.5)
    cumulative_outflow += data["Generator Production (kWh)"]

    if on_grid:
        ax1.fill_between(x, cumulative_outflow, cumulative_outflow + data["Grid Import (kWh)"],
                         label="Grid Import", color=color_dict["Grid Import (kWh)"], alpha=0.5)
        cumulative_outflow += data["Grid Import (kWh)"]

        if allow_grid_export and "Grid Export (kWh)" in data:
            ax1.fill_between(x, -cumulative_inflow, -(cumulative_inflow + data["Grid Export (kWh)"]),
                             label="Grid Export", color=color_dict["Grid Export (kWh)"], alpha=0.5)
            cumulative_inflow += data["Grid Export (kWh)"]

    if uncertainty:
        if "Battery Reserve (kWh)" in data.columns:
            battery_bars = ax1.bar(x, data["Battery Reserve (kWh)"], width=1.0,
                                   label="Battery Reserve", color=color_dict["Battery"],
                                   alpha=0.6, edgecolor='black', linewidth=0.2)
            for bar in battery_bars:
                bar.set_hatch("///")

        if "Generator Reserve (kWh)" in data.columns:
            generator_bars = ax1.bar(x, data["Generator Reserve (kWh)"], width=1.0,
                                     label="Generator Reserve", color=color_dict["Generator Production (kWh)"],
                                     alpha=0.6, edgecolor='black', linewidth=0.2)
            for bar in generator_bars:
                bar.set_hatch("\\\\\\")

    if lost_load:
        ax1.fill_between(x, cumulative_outflow, cumulative_outflow + data["Lost Load (kWh)"],
                         label="Lost Load", color=color_dict["Lost Load (kWh)"], alpha=0.5)
        cumulative_outflow += data["Lost Load (kWh)"]

    ax1.plot(x, data["Load Demand (kWh)"], label="Load", color=color_dict["Load Demand (kWh)"], linewidth=2)
    ax1.set_xlabel("Hour")
    ax1.set_ylabel("Energy (kWh)")
    ax1.set_title("Dispatch Plot")
    ax1.grid(True)
    st.pyplot(fig)

def visualize_results() -> None:
    st.title("Visualize Optimization Results")
    st.subheader("Select a Project Folder")

    projects_root = "projects"
    project_folders = [name for name in os.listdir(projects_root) if os.path.isdir(os.path.join(projects_root, name))]

    if not project_folders:
        st.warning("No project folders found.")
        return

    selected_project = st.selectbox("Project:", project_folders)
    project_path = os.path.join(projects_root, selected_project)
    results_path = os.path.join(project_path, "results")

    # === Sizing Summary ===
    st.divider()
    st.subheader("System Sizing Summary")
    sizing_file = os.path.join(results_path, "sizing_summary.csv")
    if not os.path.isfile(sizing_file):
        st.warning("sizing_summary.csv not found.")
    else:
        df = pd.read_csv(sizing_file)
        df = df[["Technology", "Installed Units", "Total Installed Capacity"]] if set(["Technology", "Installed Units", "Total Installed Capacity"]).issubset(df.columns) else df
        st.dataframe(df.style.format({"Installed Units": "{:.2f}", "Total Installed Capacity": "{:.2f}"}), use_container_width=True)

        fig, ax = plt.subplots(figsize=(8, 4))
        ax.bar(df["Technology"], df["Total Installed Capacity"])
        ax.set_ylabel("Capacity (kW or kWh)")
        ax.set_title("Total Installed Capacity by Technology")
        ax.set_xticks(range(len(df["Technology"])))
        ax.set_xticklabels(df["Technology"], rotation=30)
        ax.grid(axis='y')
        st.pyplot(fig)

    # === Dispatch Plot ===
    st.divider()
    st.subheader("Dispatch Plot")

    # Look for seasonal files dynamically
    seasonal_files = {}
    for i in range(1, 5):
        season_name = f"Season {i}"
        season_file = os.path.join(results_path, f"optimal_dispatch_season_{i}.csv")
        if os.path.isfile(season_file):
            seasonal_files[season_name] = season_file

    if seasonal_files:
        selected_season = st.selectbox("Select season to visualize", list(seasonal_files.keys()))
        dispatch_file = seasonal_files[selected_season]
    else:
        # Fallback to single dispatch file if no seasonal files exist
        dispatch_file = os.path.join(results_path, "optimal_dispatch.csv")
        if os.path.isfile(dispatch_file):
            st.markdown("**Note:** Seasonality not enabled. Showing single dispatch result.")
        else:
            dispatch_file = None
            st.warning("No dispatch file found.")

    if dispatch_file:
        dispatch_df = pd.read_csv(dispatch_file)
        on_grid = "Grid Import (kWh)" in dispatch_df.columns
        allow_grid_export = "Grid Export (kWh)" in dispatch_df.columns
        lost_load = "Lost Load (kWh)" in dispatch_df.columns
        uncertainty = any(col in dispatch_df.columns for col in ["Expected Shortfall (kWh)", "Battery Reserve (kWh)", "Generator Reserve (kWh)"])

        create_dispatch_plot_streamlit(dispatch_df, on_grid, allow_grid_export, lost_load, uncertainty)

    # === Cost Summary ===
    st.divider()
    st.subheader("💰 Cost Summary")

    costs_file = os.path.join(results_path, "costs_summary.csv")
    if not os.path.isfile(costs_file):
        st.warning("costs_summary.csv not found.")
    else:
        costs_df = pd.read_csv(costs_file)

        def get_cost(label):
            row = costs_df[costs_df["Cost Component"] == label]
            return float(row["Value (kUSD)"].values[0]) if not row.empty else 0.0

        npc = get_cost("Net Present Cost")
        capex = get_cost("Total Investment Cost (CAPEX)")
        replacement = get_cost("Total Discounted Replacement Cost")
        opex = get_cost("Total Discounted Operation Cost")
        subsidies = get_cost("Total Subsidies (share of CAPEX)")
        salvage = get_cost("Total Discounted Salvage Value")

        col1, col2 = st.columns([2, 1])
        with col1:
            labels = ["Investment", "Replacement", "Operation"]
            values = [capex, replacement, opex]
            fig, ax = plt.subplots(figsize=(6, 6))
            ax.pie(values, labels=labels, autopct='%1.1f%%', startangle=90)
            ax.set_title("Share of Key Costs (kUSD)")
            st.pyplot(fig)
        with col2:
            st.metric("Net Present Cost (kUSD)", f"{npc:,.2f}")
            st.metric("Subsidies (share of CAPEX)", f"{subsidies:.2%}")
            st.metric("Salvage Value (kUSD)", f"{salvage:,.2f}")

    # === Operational Indicators ===
    st.divider()
    st.subheader("Operational Performance Indicators")

    indicators_file = os.path.join(results_path, "operation_indicators.csv")
    if not os.path.isfile(indicators_file):
        st.warning("operation_indicators.csv not found.")
    else:
        indicators_df = pd.read_csv(indicators_file)
        indicators_df["Value"] = indicators_df["Value"].round(2)
        indicators_df = indicators_df[["Indicator", "Value", "Unit"]] if set(["Indicator", "Value", "Unit"]).issubset(indicators_df.columns) else indicators_df
        st.dataframe(indicators_df.style.format({"Value": "{:.2f}"}), use_container_width=True)

page = st.Page(visualize_results, title="Visualize Results", icon="📈")
