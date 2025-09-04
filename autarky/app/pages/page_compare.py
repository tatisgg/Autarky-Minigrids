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
            battery_bars = ax1.bar(
                x, data["Battery Reserve (kWh)"], width=1.0,
                label="Battery Reserve", color=color_dict["Battery"],
                alpha=0.6, edgecolor='black', linewidth=0.2
            )
            for bar in battery_bars:
                bar.set_hatch("///")

        if "Generator Reserve (kWh)" in data.columns:
            generator_bars = ax1.bar(
                x, data["Generator Reserve (kWh)"], width=1.0,
                label="Generator Reserve", color=color_dict["Generator Production (kWh)"],
                alpha=0.6, edgecolor='black', linewidth=0.2
            )
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

def highlight_differences_by_cols(col1, col2):
    def style_row(row):
        val1, val2 = row[col1], row[col2]
        if pd.isna(val1) or pd.isna(val2):
            return ['background-color: #ffe0b2'] * len(row)  # Orange for N/A
        try:
            if not np.isclose(val1, val2, atol=1e-5):
                return ['background-color: #fff9c4'] * len(row)  # Yellow for numeric mismatch
        except Exception:
            return ['background-color: #ffe0b2'] * len(row)  # Fallback for mismatched types
        return [''] * len(row)
    return style_row

def compare_projects():
    st.title("Compare Projects")
    st.markdown("Select two projects below to compare their system sizing, dispatch results, cost summary, and operational performance indicators side by side.")

    projects_root = "projects"
    project_folders = [name for name in os.listdir(projects_root) if os.path.isdir(os.path.join(projects_root, name))]

    if len(project_folders) < 2:
        st.warning("At least two projects are required for comparison.")
        return

    col1, col2 = st.columns(2)
    with col1:
        project_a = st.selectbox("Select Project A", project_folders, key="proj_a")
    with col2:
        project_b = st.selectbox("Select Project B", [p for p in project_folders if p != project_a], key="proj_b")

    def load_csv(project, filename):
        path = os.path.join(projects_root, project, "results", filename)
        return pd.read_csv(path) if os.path.isfile(path) else None

    sizing_a = load_csv(project_a, "sizing_summary.csv")
    sizing_b = load_csv(project_b, "sizing_summary.csv")
    cost_a = load_csv(project_a, "costs_summary.csv")
    cost_b = load_csv(project_b, "costs_summary.csv")
    opind_a = load_csv(project_a, "operation_indicators.csv")
    opind_b = load_csv(project_b, "operation_indicators.csv")

    dispatch_files = {
        "Winter": "optimal_dispatch_season_1.csv",
        "Spring": "optimal_dispatch_season_2.csv",
        "Summer": "optimal_dispatch_season_3.csv",
        "Fall": "optimal_dispatch_season_4.csv"
    }

    # === Sizing Comparison ===
    st.divider()
    st.subheader("Total Installed Capacity Comparison")
    if sizing_a is not None and sizing_b is not None:
        merged = pd.merge(sizing_a, sizing_b, on="Technology", how="outer", suffixes=(f" ({project_a})", f" ({project_b})"))
        df = merged[["Technology", f"Total Installed Capacity ({project_a})", f"Total Installed Capacity ({project_b})"]]
        numeric_cols = df.select_dtypes(include=[np.number]).columns
        styled = df.reset_index(drop=True).style\
            .apply(highlight_differences_by_cols(numeric_cols[0], numeric_cols[1]), axis=1)\
            .format({col: "{:.2f}" for col in numeric_cols})
        st.dataframe(styled, use_container_width=True)
    else:
        st.warning("Could not load sizing data for both projects.")

    # === Dispatch Plot Comparison ===
    st.divider()
    st.subheader("📊 Dispatch Comparison")

    dispatch_files = {
        "Winter": "optimal_dispatch_season_1.csv",
        "Spring": "optimal_dispatch_season_2.csv",
        "Summer": "optimal_dispatch_season_3.csv",
        "Fall":   "optimal_dispatch_season_4.csv"
    }

    def get_dispatch_type(project):
        seasonal_found = any(os.path.isfile(os.path.join(projects_root, project, "results", f)) for f in dispatch_files.values())
        flat_found = os.path.isfile(os.path.join(projects_root, project, "results", "optimal_dispatch.csv"))
        return "seasonal" if seasonal_found else "flat" if flat_found else "missing"

    type_a = get_dispatch_type(project_a)
    type_b = get_dispatch_type(project_b)

    # Season selector only shown if at least one is seasonal
    season_to_display = None
    if "seasonal" in [type_a, type_b]:
        st.markdown("Select season for seasonal project(s).")
        season_to_display = st.selectbox("Season", list(dispatch_files.keys()))

    def load_dispatch(project, dispatch_type, selected_season):
        if dispatch_type == "seasonal":
            return load_csv(project, dispatch_files[selected_season])
        elif dispatch_type == "flat":
            return load_csv(project, "optimal_dispatch.csv")
        return None

    col1, col2 = st.columns(2)

    with col1:
        st.markdown(f"**Dispatch - {project_a}**")
        df_a = load_dispatch(project_a, type_a, season_to_display)
        if df_a is not None:
            create_dispatch_plot_streamlit(
                df_a,
                on_grid="Grid Import (kWh)" in df_a.columns,
                allow_grid_export="Grid Export (kWh)" in df_a.columns,
                lost_load="Lost Load (kWh)" in df_a.columns,
                uncertainty=any(col in df_a.columns for col in ["Battery Reserve (kWh)", "Generator Reserve (kWh)", "Expected Shortfall (kWh)"])
            )
        else:
            st.warning("Dispatch data not available for Project A.")

    with col2:
        st.markdown(f"**Dispatch - {project_b}**")
        df_b = load_dispatch(project_b, type_b, season_to_display)
        if df_b is not None:
            create_dispatch_plot_streamlit(
                df_b,
                on_grid="Grid Import (kWh)" in df_b.columns,
                allow_grid_export="Grid Export (kWh)" in df_b.columns,
                lost_load="Lost Load (kWh)" in df_b.columns,
                uncertainty=any(col in df_b.columns for col in ["Battery Reserve (kWh)", "Generator Reserve (kWh)", "Expected Shortfall (kWh)"])
            )
        else:
            st.warning("Dispatch data not available for Project B.")

    # === Cost Comparison ===
    st.divider()
    st.subheader("Cost Summary Comparison")
    if cost_a is not None and cost_b is not None:
        merged = pd.merge(cost_a, cost_b, on="Cost Component", suffixes=(f" ({project_a})", f" ({project_b})"))
        df = merged[[f"Cost Component", f"Value (kUSD) ({project_a})", f"Value (kUSD) ({project_b})"]]
        numeric_cols = df.select_dtypes(include=[np.number]).columns
        styled = df.reset_index(drop=True).style\
            .apply(highlight_differences_by_cols(numeric_cols[0], numeric_cols[1]), axis=1)\
            .format({col: "{:.2f}" for col in numeric_cols})
        st.dataframe(styled, use_container_width=True)
    else:
        st.warning("Could not load cost summary for both projects.")

    # === Operational Indicator Comparison ===
    st.divider()
    st.subheader("Operational Performance Indicators")

    if opind_a is not None and opind_b is not None:
        # Outer join to include all metrics from both projects
        merged = pd.merge(opind_a, opind_b, on="Indicator", how="outer", suffixes=(f" ({project_a})", f" ({project_b})"))

        col_a = f"Value ({project_a})"
        col_b = f"Value ({project_b})"
        cols = ["Indicator", col_a, col_b]
        if "Unit" in merged.columns:
            cols.append("Unit")

        df = merged[cols].copy()

        # Apply style with custom highlight
        styled = df.style\
            .apply(highlight_differences_by_cols(col_a, col_b), axis=1)\
            .format({col_a: "{:.2f}", col_b: "{:.2f}"}, na_rep="N/A")

        st.dataframe(styled, use_container_width=True)

    else:
        st.warning("Could not load operational indicators for both projects.")

page = st.Page(compare_projects, title="Compare Projects", icon="🔍")
