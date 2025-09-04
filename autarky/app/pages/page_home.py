import streamlit as st

def home() -> None:
    st.title("Welcome to the Autarky Project Viewer!")

    # Introduction to Autarky
    st.subheader("What is Autarky?")
    st.markdown("""
        **Autarky** is an energy modeling framework designed to **optimize sizing and operation** of decentralized, often isolated or weak-connected, energy systems.

        It supports:
        - Hybrid systems with **renewables**, **storage**, and **backup generators**
        - **Seasonality** and **temporal** variations in demand and generation
        - Scenarios with or without **grid connection**
        - Operation under **uncertainty** and outages

        Its goal is to minimize **net present cost (NPC)** while ensuring **reliability and resilience**.
    """)

    st.divider()

    # Model types
    st.subheader("Types of Models in Autarky")
    st.markdown("""
        Autarky includes multiple model types that represent different levels of reliability and stochastic behavior:

        - **Deterministic Model**: Standard least-cost optimization assuming perfect foresight.
        - **Expected Value Model**: Incorporates uncertainty by using expected values for uncertain parameters.
        - **ICC (Individual Chance Constraints)**: Adds reliability by enforcing constraints under uncertain demand/production individually per timestep.
        - **JCC (Joint Chance Constraints)**: Handles uncertainty more rigorously by guaranteeing performance over a full outage window.
    """)

    st.divider()

    # App usage instructions
    st.subheader("How to Use This App")
    st.markdown("""
        This application lets you explore the inputs and results of energy system optimization projects.

        Use the sidebar to navigate:
        - 📂 **Visualize Inputs**: Load profiles, solar/wind production, techno-economic parameters, efficiency curves, and error metrics.
        - 📈 **Visualize Results**: Optimal sizing and dispatch results, LCOE, NPC, cost breakdown, and operation plots.
        - 🔍 **Compare Projects**: Select and compare two project results side by side, including:
            - Installed capacities
            - Seasonal dispatch plots
            - Cost breakdowns
            - Operational performance indicators

        This comparison helps identify design trade-offs and performance differences under varying assumptions or model types.
    """)

page = st.Page(home, title="Home", icon="🏠")
