# Autarky Streamlit App

Welcome to the **Autarky Project Viewer** , a user-friendly web application built with **Streamlit** to explore, visualize, and compare results from **Autarky's mini-grid optimization models**.

Autarky is an energy modeling framework that optimizes the **sizing and operation** of decentralized, often weakly connected or off-grid hybrid energy systems. This app brings its powerful backend models to life with interactive dashboards and charts.

---

## 🚀 Features Overview

### What You Can Do

- **Visualize project inputs** such as load profiles, renewable production, techno-economic parameters, constraints, and forecast errors.
- **Explore optimization results**, including system sizing, dispatch strategies, cost breakdowns, and reliability metrics.
- **Compare multiple projects side by side** to evaluate trade-offs across technologies, costs, and model assumptions.

---

## Page Navigation

### 🏠 Home
Introduces Autarky's purpose and the four model types:
- **Deterministic**: Perfect foresight, baseline model.
- **Expected Value**: Penalizes expected forecasting errors.
- **Individual Chance Constraints (ICC)**: Adds per-timestep reliability.
- **Joint Chance Constraints (JCC)**: Enforces reliability over outage windows.

---

### 📂 Visualize Inputs

Select a project and explore:
- Project location and time settings
- Techno-economic parameters and enabled components
- Optimization and reliability constraints
- Time series for load, solar, wind, and grid
- Forecast error metrics with RMSE, MAE, and bias

---

### 📈 Visualize Results

Explore the outcome of an optimization run:
- System sizing summary and bar chart
- Seasonal or non-seasonal dispatch flow plot
- Net present cost and cost structure (CAPEX, OPEX, replacements, subsidies, salvage)
- Key performance indicators such as unmet demand, renewable share, and energy import/export

---

### 🔍 Compare Projects

Choose two projects to compare:
- Installed capacity per technology
- Dispatch behavior for each project
- Cost breakdown comparison
- Operational indicators like LCOE, fuel usage, curtailment, or lost load

Smart formatting highlights mismatches between project metrics for easy analysis.

---

## How to Use

1. Run the backend model (e.g. `main.jl` in one of the Autarky model folders).
2. Copy the generated `inputs/` and `results/` folders into a new subdirectory under: Autarky App/projects/your_project_name/
3. Launch the Streamlit app:

```bash
cd autarky-streamlit
streamlit run app.py
```
You can now navigate through the interface to explore or compare your model runs.

## Requirements
- Python ≥ 3.10
- streamlit
- pandas
- numpy
- matplotlib
- pyyaml

Install dependencies with:

```bash
pip install -r requirements.txt
```