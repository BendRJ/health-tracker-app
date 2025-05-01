# health-tracker-app
Streamlit application for tracking health data and storing it in local postgres database

## Project Structure

```plaintext
health_tracker/
├── app/
│   ├── __init__.py
│   ├── main.py
│   ├── database.py
│   ├── models.py
│   ├── schemas.py
│   ├── crud.py
│   └── routers/
│       └── health.py
├── .env
└── requirements.txt