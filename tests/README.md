# Test Suite for Autarky Models

This folder contains test scripts to verify that each optimization model in the repository:
- Runs without errors
- Produces expected result files (e.g., CSV, JSON)

## Default Case Studies

Each model (Deterministic, Expected, ICC, JCC) is tested using the pre-loaded inputs inside their respective `/inputs` folder.

The inputs are minimal exemplative test cases intended to:
- Validate functionality
- Keep runtime low for the sake of quick testing

---

### Deterministic Model

#### **Overview**

The deterministic test model simulates a **remote island community in Kenya**, where energy needs span both residential and productive uses. The modeled users include:

- Households with basic electricity needs (lighting, phone charging)
- Micro-enterprises using power tools, refrigeration, and milling machines
- Public services such as health centers and schools

The load demand profile has been simulated using [RAMP](https://rampdemand.org/), which generates representative profiles based on local energy use patterns and activity-based modeling.
Key demand characteristics are: Average daily peak power of ~30 kW and Average daily energy use of 486 kWh.

#### **Load Profile Visualization**

![Load Profile Overview](https://github.com/AleOnori98/Autarky-2.0/blob/main/tests/images/load_profile.png)

> *Figure: Hourly demand profile for a typical day in wet and dry seasons.*

---

#### **System Configuration**

The system is designed as a fully off-grid hybrid mini-grid with the following specifications:

- **Project lifetime**: 20 years (used for long-term cost minimization and net present cost calculation)
- **Dispatch resolution**: Hourly (daily operation)
- **Seasons modeled**: Wet and dry
- **Grid connection**: None (fully off-grid)
- **Lost load allowed**: ❌ No (full demand satisfaction required)

##### **Technologies included:**

- **Solar PV** (with seasonal availability from [Renewables.ninja](https://www.renewables.ninja/))
- **Battery storage** (including round-trip efficiency, state of charge limits, and degradation)
- **Diesel generator** (with partial load efficiency curve)

![System Layout](https://github.com/AleOnori98/Autarky-2.0/blob/main/tests/images/system_layout.png)

> *Figure: System schematic showing solar PV, battery, and diesel backup configuration.*

To implement the optimal dispatch strategy from Autarky, the system should include also an **Energy System Manager (ESM)** connected to **smart meters**, with internet access for forecasts and API-based control in advanced configurations.


#### **Results:**

The optimal system configuration for the Kenyan island community includes an 128 kW solar PV array, 366 kWh of battery storage with a little backup contribution of 0.7 kW provided by the diesel generator. The model achieves almost 100% renewable penetration with no lost load, meeting all demand reliably. The total Net Present Cost of the project is approximately 334.35 kUSD (considerin 10% of discount rate over 20 years), with a Total Investment Cost 236.64 kUSD resulting in a levelized cost of energy (LCOE) of 0.22 USD/kWh. Annual Solar Curtailment Share is 11.22 % of total solar production while Annual fuel consumption is 83.58 liters/year, with the generator operating at an average efficiency of 10.5 kWh/liter and a load factor of nearly 13.9%.

![Results](https://github.com/AleOnori98/Autarky-2.0/blob/main/tests/images/results_1.png)

> *Figure: Optimal dispatch plot and cost breakdown.*

---

### Expected Values Model

#### **Overview**

This test case builds upon the same Kenyan island community used in the deterministic model, with identical energy demand (peak ~30 kW, average daily energy ~486 kWh) and the same set of residential, productive, and public users.

However, the key distinction here is the inclusion of **uncertainties**, particularly those related to renewable generation forecasting errors and main grid reliability. The model adopts an **expected values formulation**, which captures the average-case performance across probabilistic outages and deviations in solar/demand forecasts.

#### **Grid & Uncertainty Configuration**

The system is now modeled as **on-grid**, allowing import of electricity when local generation is insufficient, but **grid export is disabled**. The connection to the national grid is limited to a maximum of 500 kW.

Key grid and uncertainty settings:

- **Allow grid import**: ✅
- **Allow grid export**: ❌
- **Grid connection limit**: 500 kW
- **Grid exchange cost**: 0.30 USD/kWh

Modeling of outages and islanding:

- **Average daily outage duration**: 3 hours
- **Probability of daily outage**: 90%
- **Probability of successful islanding during outage**: 90%

The model incorporates **solar PV**, **battery storage**, and a **diesel generator**, all operating under the same technical specifications as in the deterministic test. Time series for prices and costs are assumed constant and simplified to ensure quick and robust testing.

---

#### Results Overview

The expected values formulation provides a more resilient energy strategy by accounting for likely outages and variability. In this expected values scenario, the model achieves 100% renewable penetration using a 75.7 kW solar PV array and 137.3 kWh of battery storage, without requiring any generator capacity. The system successfully relies on the grid for backup during forecasted outages, importing approximately 70.7 MWh annually. The Net Present Cost is 197.39 kUSD and Total Annual Grid Cost 7.07 kUSD/year, with a significantly lower LCOE of 0.12 USD/kWh, thanks to optimized grid use and a well-sized battery reserve (~20.16 MWh annually).

![Results](https://github.com/AleOnori98/Autarky-2.0/blob/main/tests/images/results_2.png)

> *Figure: Optimal dispatch plot and cost breakdown.*

---

### ICC Model

#### **Overview**

The Individual Chance Constraints (ICC) model uses the **same system setup, time series data, and uncertainty parameters** as the Expected Values formulation. However, instead of optimizing based on average outcomes, the ICC model enforces **probabilistic guarantees** on key constraints, particularly demand satisfaction, by introducing reliability thresholds on a per-time-step basis.

This makes the system more robust to extreme conditions (e.g., long outages or simultaneous solar underproduction and load spikes), by requiring the system to meet its constraints with a specified confidence level.

---

#### Results Overview

The results of the ICC model are very close to those of the Expected Values formulation, with only marginal differences in system sizing and costs. The ICC model recommends a slightly larger solar PV capacity (76.0 kW vs. 75.7 kW) and battery storage (137.9 kWh vs. 137.3 kWh), which leads to a **slightly higher total investment cost** but also **reduces the expected shortfall from 0.08 MWh to just 0.02 MWh annually**.

Grid imports are also marginally higher (+0.5 MWh/year), suggesting the ICC model takes a more conservative approach to ensure reliable service under uncertain conditions. The **LCOE remains identical** at 0.12 USD/kWh, indicating that this increased robustness does not come at a significant cost premium.

![Results](https://github.com/AleOnori98/Autarky-2.0/blob/main/tests/images/results_3.png)

> *Figure: Optimal dispatch plot and cost breakdown for ICC model.*

---

### JCC Model

#### **Overview**

The Joint Chance Constraints (JCC) formulation models correlated and compound uncertainty more rigorously than the Expected Values and ICC approaches. Using the same community, grid, and demand setup, this formulation enforces simultaneous probability guarantees across all time steps, making it significantly more conservative in sizing and dispatch decisions.

#### Results Overview

Unlike the ICC and Expected Values models—which achieved 100% renewable penetration with no generator use, the JCC formulation results in a more risk-averse configuration: only 66% renewable penetration, higher grid reliance, and the inclusion of a 5.8 kW diesel generator. Solar capacity is downsized to 32.9 kW with over 56% curtailment, while generator and grid imports are both elevated. These decisions lead to a much higher Net Present Cost of 964.9 kUSD and LCOE of 0.60 USD/kWh, driven by costly operational redundancy needed to satisfy the strict joint probability constraints. This highlights the cost-risk trade-off intrinsic to robust energy system design under uncertainty.

![Results](https://github.com/AleOnori98/Autarky-2.0/blob/main/tests/images/results_4.png)

> *Figure: Optimal dispatch plot and cost breakdown for ICC model.*

---

## ⚠️ Modeling Limitations: Impact of Forecast Horizon on Uncertainty Effects

A key consideration when comparing the different model formulations (Deterministic, Expected Values, ICC, JCC) lies in the **duration of the dispatch optimization time horizon**.

Currently, the Autarky test cases use a **short operational period** (e.g., 2 representative seasonal days at hourly resolution) to allow for fast testing and demonstration. While this setup is sufficient to validate core functionality and logic, it also **limits the visibility of uncertainty impacts**, especially under high outage probabilities or strong forecasting errors.

In real-world scenarios, the **longer the operation time frame** (e.g., full-year dispatch), the more visible the effects of:
- Prolonged or frequent outages
- Cumulative renewable generation errors
- Variability in grid availability
- Temporal energy storage imbalances

This means that **the value and effect of probabilistic formulations (like ICC and JCC)** grow with the temporal scope. On short horizons, deterministic and stochastic formulations may yield similar results; however, **over longer periods, they can diverge significantly** in terms of sizing, cost, and operational strategies.

> **Recommendation**: For robust planning studies, it is advisable to run simulations over extended periods (e.g., multiple weeks or a full year) to fully capture the dynamics of uncertainty and assess the trade-offs among model formulations.  
> However, **note that the longer the time horizon, the higher the computational complexity**, especially for probabilistic models (ICC and JCC), which involve **non-linear constraints** and chance-based expressions. The **solve time can grow exponentially**, and trade-offs between model fidelity and runtime may need to be carefully balanced.

---

