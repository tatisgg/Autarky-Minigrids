import streamlit as st
from pages import page_home, page_inputs, page_results, page_compare

# Set page config
st.set_page_config(
    page_title="Autarky Project Viewer",
    page_icon="assets/logo.svg",  
    layout="centered",
    initial_sidebar_state="expanded"
)

# Sidebar
with st.sidebar:
    selected_page = st.navigation([
        page_home.page,
        page_inputs.page,
        page_results.page,
        page_compare.page
    ])

    # Place logo and title in sidebar
    col1, col2, col3 = st.columns([1, 3, 1])
    with col2:
        st.image("assets/logo.svg", width=100) 
        st.markdown("### Autarky Viewer")
    st.caption("Made with ❤️ using Streamlit.")

# Run selected page
selected_page.run()