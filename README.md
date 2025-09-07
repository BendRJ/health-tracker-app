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
│   ├── frontend.py
│   └── routers/
│       └── health.py
├── .env
├── docker-compose.yml
├── start_app.sh
└── requirements.txt
```

## Quick Start

To start the application with one click, run:

```bash
./start_app.sh
```

This script will:
1. Start the PostgreSQL container.
2. Start the FastAPI backend.
3. Start the Streamlit frontend.

## Manual Setup

### Prerequisites
- Docker and Docker Compose
- Python 3.8+
- pip

### Installation
1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd health-tracker-app
   ```

2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Create a `.env` file in the root directory with the following content:
   ```
   DATABASE_URL=postgresql://health_user:health_password@localhost:5432/health_db
   FASTAPI_HOST=0.0.0.0
   FASTAPI_PORT=8000
   STREAMLIT_PORT=8501
   ```

### Running the Application
1. Start the PostgreSQL container:
   ```bash
   docker-compose up -d
   ```

2. Start the FastAPI backend:
   ```bash
   uvicorn app.main:app --reload
   ```

3. Start the Streamlit frontend:
   ```bash
   streamlit run app/frontend.py
   ```

## Usage
- Open your browser and navigate to `http://localhost:8501` to access the Streamlit frontend.
- Use the form to input back pain data (pain level and date).
- View the history of recorded pain levels.

## API Documentation
- FastAPI Swagger UI: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

## Chronology of Scripts

The application uses the following scripts in sequence:

1. **start_app.sh**: A shell script that automates the startup process:
   - Starts the PostgreSQL container using `docker-compose up -d`.
   - Waits for PostgreSQL to be ready (5 seconds).
   - Starts the FastAPI backend using `uvicorn app.main:app --reload` in the background.
   - Waits for FastAPI to be ready (5 seconds).
   - Starts the Streamlit frontend using `streamlit run app/frontend.py`.

2. **app/main.py**: The FastAPI backend entry point:
   - Configures the FastAPI application.
   - Sets up CORS middleware.
   - Includes the health router for API endpoints.

3. **app/frontend.py**: The Streamlit frontend:
   - Provides a user interface for inputting back pain data.
   - Sends data to the FastAPI backend.
   - Displays the history of recorded pain levels.

4. **app/database.py**: Manages database connections:
   - Creates a SQLAlchemy engine and session.
   - Provides a `get_db` function for dependency injection in FastAPI.

5. **app/crud.py**: Contains CRUD operations:
   - `create_back_pain`: Inserts a new back pain entry into the database.
   - `get_back_pain_entries`: Retrieves a list of back pain entries.

6. **app/routers/health.py**: Defines API endpoints:
   - `POST /back-pain/`: Creates a new back pain entry.
   - `GET /back-pain/`: Retrieves a list of back pain entries.

7. **docker-compose.yml**: Defines the PostgreSQL container:
   - Sets up the PostgreSQL database with the specified credentials.
   - Maps the database port to the host machine.

8. **.env**: Contains environment variables:
   - `DATABASE_URL`: Connection string for PostgreSQL.
   - `FASTAPI_HOST` and `FASTAPI_PORT`: Configuration for the FastAPI backend.
   - `STREAMLIT_PORT`: Configuration for the Streamlit frontend.

This sequence ensures that the application starts correctly and all components are properly initialized.
