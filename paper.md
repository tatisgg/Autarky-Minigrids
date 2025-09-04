---
title: 'XXXX'
tags:
  - energy systems
  - optimization
  - Julia
  - JuMP
  - mini-grids
  - chance constraints
  - decentralized electrification
  - ....
authors:
  - name: XXXX
    orcid: XXXX
    affiliation: '1'
affiliations:
  - index: 1
    name: XXX
    ror: XXX
date: XXX
bibliography: paper.bib
---

# Summary

Autarky is .....

# Statement of need

Energy system planning tools are essential for designing affordable and reliable electrification solutions in areas with constrained infrastructure and high uncertainty in demand and renewable supply. Existing tools often either (i) lack probabilistic reliability modeling, (ii) are not open source, or (iii) do not scale well to decentralized, modular energy systems. Autarky addresses these gaps by:

- Enabling high-resolution, long-term optimization of off-grid systems with seasonality and uncertainty.
- Supporting multiple formulations (LP, EV, ICC, JCC) to balance computational cost and system robustness.
- Including JCC formulations using the JointChance.jl package, enabling power system planners to specify reliability levels over outage durations.
- Offering an integrated user interface to facilitate adoption by policy-makers, planners, and non-programmers.

Autarky is already used in ongoing research projects and educational contexts, including the iDesignRES EU project and EMP-A 2025 training in Addis Ababa.

# Functionality

Autarky allows users to:

- ....

# Research applications

Autarky has enabled:

- Probabilistic analysis of mini-grid islanding during main-grid outages, using ICC and JCC constraints with Gaussian error distributions.
- Optimal sizing and dispatch of systems for informal settlements (e.g., Kingstone in Mukuru, Nairobi), revealing cost-robustness tradeoffs in marginalized urban contexts.
- Comparative analysis of grid-tied vs. stand-alone planning scenarios across diverse geographies and regulatory assumptions.

Ongoing work includes extending the platform to swarm-grids and tariff design using complementarity constraints under uncertainty.

...

# Acknowledgements

....

# References

....
