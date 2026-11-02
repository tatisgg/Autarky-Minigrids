# Autarky Mini-Grid Optimization Models

[![CI](https://github.com/tatisgg/Autarky-Minigrids/actions/workflows/CI.yml/badge.svg)](https://github.com/tatisgg/Autarky-Minigrids/actions/workflows/CI.yml)

## Overview

**Autarky** is a modern open-source framework for the **optimal sizing and dispatch of decentralized grid-connected mini-grid systems**, under four different uncertainties: demand, weather variability, frequency of outages and duration of outages from the main grid. 

This is tailored for rural electrification and energy resilience. Implemented in **Julia** with **JuMP**, it supports hybrid systems including **solar PV**, **batteries**, **diesel generators**, and **grid connection** under both **deterministic** and **stochastic** conditions.

The framework enables robust and cost-effective energy system design by minimizing the **Net Present Cost (NPC)**, accounting for capital investment, replacement, operational costs, and salvage value — all under a multi-year horizon with optional **seasonality**.

Autarky supports four distinct optimization formulations:

- **Regular (Deterministic)**: Least-cost sizing and dispatch assuming perfect foresight.
- **Expected Value Model (EVM)**: Incorporates uncertainty using expected forecasting errors.
- **Individual Chance Constraints (ICC)**: Enforces per-time-step reliability under uncertainty.
- **Joint Chance Constraints (JCC)**: Ensures system-wide reliability across outage windows, the most robust approach.

---

## Key Features

- Hybrid energy system modeling: PV, wind, battery, diesel, grid.
- Modular activation of components and constraints.
- Seasonal time series support.
- Reserve planning under outages and forecast uncertainty.
- Advanced reliability modeling with probabilistic constraints.
- Objective: Minimize NPC via discounted cash flow logic.
- Optional unit commitment formulation with integer sizing.

---

## Repository Structure

Each model variant (Regular, EVM, ICC, JCC) resides in a dedicated folder with the following structure:

```bash

autarky/
│
├── deterministic/ # Deterministic model
├── expected_values/ # EVM with forecast errors
├── icc/ # Individual Chance Constraints
├── jcc_genz/ # Joint Chance Constraints
│
Each model folder contains:
├── src/
│ └── main.jl # Entrypoint to run the optimization
├── inputs/
│ └── *.csv, *.yaml # Time-series and techno-economic parameters
└── results/
└── *.csv # Output results saved here

```

To install the environment once, from the repository root:

```bash
julia --project=. -e 'using Pkg; Pkg.instantiate()'
```

To run a model:

```bash
cd autarky/<selected model>/src
julia --project=../../.. main.jl
```

To run the test suite, which runs each model on its bundled inputs:

```bash
julia --project=. -e 'using Pkg; Pkg.test()'
```

### Solvers
All models run on open-source solvers: HiGHS for the deterministic model, and Ipopt with the MUMPS linear solver for EVM, ICC and JCC. Two optional solvers are supported if you have a licence:
- **HSL** (ma27, ma57, ...): obtain `HSL_jll` from the [HSL licensing portal](https://licences.stfc.ac.uk/product/libhsl), add it with `julia --project=. -e 'using Pkg; Pkg.develop(path="<path to HSL_jll.jl>")'`, and set `linear_solver` in `ipopt_options`. The repository does not distribute HSL.
- **Gurobi**: add `Gurobi` to the environment and set `solver_name: Gurobi` in the deterministic `parameters.yaml`.

## Inputs
- inputs/parameters.yaml: General project and technology configuration
- CSV time-series:
  - load.csv: Load demand profile
  - solar_unit.csv: Unit production of PV
  - wind_unit.csv: (Optional) Wind production
  - grid_cost.csv, grid_price.csv: Grid tariffs (optional)
  - grid_availability.csv: Binary grid outage series (for stochastic modeling)
  - solar_errors_*.csv, load_errors_*.csv: Forecasting error samples (for EVM/ICC/JCC)

## Model Comparison
| **Model**        | **Description**                                                                   | **Reliability Scope**                           | **Complexity**               | **Runtime**         | **Robustness**   |
|------------------|------------------------------------------------------------------------------------|--------------------------------------------------|-------------------------------|-----------------------|-------------------|
| **Regular**      | Least-cost, deterministic optimization assuming perfect foresight                | None (0%)                                       | Linear                        | 🟢 Fast              | 🔴 Low           |
| **EVM**          | Penalizes expected shortfall using nonlinear cost terms                          | Expected-value reliability (~20%)               | Nonlinear                     | 🟡 Moderate          | 🟡 Medium        |
| **ICC**          | Enforces a confidence level per time step using normal quantiles                 | Per-timestep reliability (~60%)                 | Nonlinear                     | 🟡 Moderate          | 🟡 Medium        |
| **JCC**          | Guarantees feasibility across outage windows using joint probability constraints | Window-based reliability (≥90% over κ hours)    | Nonlinear + Multivariate      | 🔴 Minutes     | 🟢 High          |


## Streamlit Viewer App
Autarky comes with a Streamlit web app to visualize and compare projects:

```bash
cd autarky/app
streamlit run app.py
```

### Features:
- 📂 Visualize Inputs: Time series, component specs, costs, error metrics
- 📈 Visualize Results: Dispatch, cost breakdown, sizing, LCOE, NPC
- 🔍 Compare Projects: Assess sizing and cost trade-offs across models

### Workflow:

- Run a model (main.jl) in one of the four folders.
- Copy the generated inputs/ and results/ folders.
- Paste them into a new folder inside Autarky App/projects/your_project_name/.

Now you can explore the project via the Streamlit UI.

## Requirements
- Julia ≥ 1.12
- Packages: JuMP, HiGHS, Ipopt, Distributions, YAML, etc. (see `Project.toml`)
- Python ≥ 3.10 for the Streamlit app
- Streamlit dependencies: pandas, plotly, matplotlib, etc.

## Citation
This framework builds on the methods described in:
- Ouanes, N., González Grandón, T., Heitsch, H., Henrion, R. (2025). Optimizing the economic dispatch of weakly-connected mini-grids under uncertainty using joint chance constraints. Annals of Operations Research.