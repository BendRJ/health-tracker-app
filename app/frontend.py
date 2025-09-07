import streamlit as st
import requests
from datetime import date
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Check if running in Docker (API_URL env var is set) or locally
API_URL = os.getenv('API_URL')
if API_URL:
    # Running in Docker - use the API container URL
    FASTAPI_URL = f"{API_URL}/api/v1"
else:
    # Running locally - use localhost
    FASTAPI_PORT = os.getenv('FASTAPI_PORT', '8000')
    FASTAPI_URL = f"http://localhost:{FASTAPI_PORT}/api/v1"

st.title("Back Pain Tracker")

# Input form for pain level and date
with st.form("back_pain_form"):
    pain_level = st.slider("Pain Level (1-10)", 1, 10, 5)
    pain_date = st.date_input("Date", date.today())
    submitted = st.form_submit_button("Submit")

    if submitted:
        try:
            response = requests.post(
                f"{FASTAPI_URL}/back-pain/",
                json={"pain_level": pain_level, "date": pain_date.isoformat()}
            )
            response.raise_for_status()
            st.success("Pain level recorded successfully!")
        except Exception as e:
            st.error(f"Error recording pain level: {str(e)}")

# Display pain history
st.subheader("Pain History")
try:
    response = requests.get(f"{FASTAPI_URL}/back-pain/")
    response.raise_for_status()
    entries = response.json()
    if entries:
        for entry in entries:
            st.write(f"Date: {entry['date']}, Pain Level: {entry['pain_level']}")
    else:
        st.write("No entries yet.")
except Exception as e:
    st.error(f"Error fetching history: {str(e)}")
