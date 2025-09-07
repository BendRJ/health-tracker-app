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

### Using Docker (Recommended for Production)

**First time setup:**
```bash
make docker-build    # Build all containers
make docker-up       # Start all services
```

**Daily development:**
```bash
make docker-dev      # Start with live code reloading
```

**Quick commands:**
```bash
make help            # See all available commands
make docker-status   # Check container status
make docker-logs     # View logs
make docker-down     # Stop all services
```

### Using Local Development (Alternative)

**Using Makefile:**
```bash
make run            # Start full application locally
make help           # See all available commands
```

**Using Shell Script:**
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

#### Docker Workflow (Recommended)

**Production deployment:**
```bash
make docker-build    # Build containers
make docker-up       # Start all services in background
```

**Development with live reload:**
```bash
make docker-dev      # Start with volume mounts for code changes
```

**Individual services:**
```bash
make docker-status   # Check what's running
make docker-logs     # View all logs
make docker-down     # Stop everything
```

#### Local Development Workflow

**Using Makefile:**
```bash
make run             # Start full application locally
make run-api         # Start API only (includes database)
make run-frontend    # Start frontend only
make dev             # Development mode with auto-reload
```

**Manual setup:**
```bash
docker-compose up -d postgres    # Start database only
uvicorn app.main:app --reload    # Start FastAPI backend
streamlit run app/frontend.py    # Start Streamlit frontend
```

## Makefile Commands

The Makefile provides convenient commands for both Docker and local development:

### Docker Commands (Recommended)
- `make docker-build` - Build all container images
- `make docker-up` - Start all services with Docker
- `make docker-dev` - Start with development volume mounts
- `make docker-down` - Stop all Docker services
- `make docker-logs` - View logs from all services
- `make docker-status` - Show container status
- `make docker-clean` - Clean up containers and images
- `make docker-rebuild` - Rebuild and restart everything

### Local Development Commands
- `make install` - Install Python dependencies
- `make install-dev` - Install development dependencies
- `make run` - Start full application locally
- `make run-api` - Start only FastAPI backend
- `make run-frontend` - Start only Streamlit frontend
- `make dev` - Start in development mode

### Database Management
- `make db-up` - Start PostgreSQL container only
- `make db-down` - Stop PostgreSQL container
- `make db-reset` - Reset database (remove all data)
- `make db-logs` - View database logs

### Development Tools
- `make test` - Run tests
- `make lint` - Run code linting
- `make format` - Format code with black
- `make clean` - Clean temporary files
- `make compile-deps` - Compile requirements.in to requirements.txt

### Utility
- `make status` - Check service status
- `make stop` - Stop all services
- `make check-env` - Check if required tools are installed
- `make help` - Show all available commands

## Usage

### Access the Application
- **Frontend**: `http://localhost:8501` - Streamlit web interface
- **API**: `http://localhost:8000` - FastAPI backend
- **API Documentation**: `http://localhost:8000/docs` - Interactive Swagger UI
- **Alternative API Docs**: `http://localhost:8000/redoc` - ReDoc interface

### Application Features
- Use the web form to input back pain data (pain level 1-10 and date)
- View historical pain level entries
- RESTful API for programmatic access to data

## Docker Compose Architecture

The Health Tracker application uses Docker Compose to orchestrate three interconnected services that work together to provide a complete web application stack. Here's how they connect and communicate:

### Service Overview

```
External Access (Host Machine)
┌─────────────────────────────────────────────────────────────────────────────────┐
│  Browser → localhost:8501          Direct API → localhost:8000                  │
│           ▲                                    ▲                                │
└───────────┼────────────────────────────────────┼────────────────────────────────┘
            │                                    │
            │ Port Mapping                       │ Port Mapping
            │ 8501:8501                          │ 8000:8000
            ▼                                    ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                       health_network (Docker Bridge)                            │
│                                                                                 │
│ ┌─────────────────────┐              ┌─────────────────────┐                    │
│ │     frontend        │              │        api          │                    │
│ │   (Streamlit)       │              │     (FastAPI)       │                    │
│ │                     │    HTTP      │                     │   PostgreSQL       │
│ │ Container:          │◄────────────►│ Container:          │◄─────────────────┐ │
│ │ health_frontend     │ api:8000     │ health_api          │ postgres:5432    │ │
│ │ Port: 8501          │              │ Port: 8000          │                  │ │
│ └─────────────────────┘              └─────────────────────┘                  │ │
│                                                                               │ │
│                                                            ┌──────────────────┘ │
│                                                            │                    │
│                                                            ▼                    │
│                                       ┌─────────────────────────┐               │
│                                       │       postgres          │               │
│                                       │     (PostgreSQL)        │               │
│                                       │                         │               │
│                                       │ Container:              │               │
│                                       │ health_postgres         │               │
│                                       │ Port: 5432              │               │
│                                       │                         │               │
│                                       │ Volume:                 │               │
│                                       │ postgres_data           │               │
│                                       └─────────────────────────┘               │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘

Data Flow:
1. User accesses Streamlit UI at localhost:8501
2. Frontend makes HTTP requests to api:8000 (internal network)
3. API connects to postgres:5432 for database operations
4. PostgreSQL data persisted in named volume postgres_data
```

### Service Interconnections

#### 1. **PostgreSQL Database Service (`postgres`)**
- **Role**: Data persistence layer
- **Image**: `postgres:15`
- **Container Name**: `health_postgres`
- **Internal Network**: Accessible at `postgres:5432` from other services
- **External Access**: `localhost:5432` (mapped from host)
- **Data Storage**: Uses named volume `postgres_data` for persistence
- **Health Check**: Monitors database readiness with `pg_isready`

#### 2. **FastAPI Backend Service (`api`)**
- **Role**: Business logic and REST API layer
- **Build**: Custom image from `Dockerfile`
- **Container Name**: `health_api`
- **Dependencies**: Waits for `postgres` service to be healthy
- **Database Connection**: `postgresql://health_user:health_password@postgres:5432/health_db`
- **Internal Network**: Accessible at `api:8000` from frontend service
- **External Access**: `localhost:8000` (mapped from host)

#### 3. **Streamlit Frontend Service (`frontend`)**
- **Role**: User interface and web application layer
- **Build**: Custom image from `Dockerfile.frontend`
- **Container Name**: `health_frontend`
- **Dependencies**: Waits for `api` service to start
- **API Connection**: `http://api:8000` (internal network communication)
- **External Access**: `localhost:8501` (mapped from host)

### Service Startup Sequence

The services start in a specific order managed by Docker Compose dependency chains:

```
1. postgres (starts first)
   ├── Health check: pg_isready -U health_user -d health_db
   ├── Status: Waiting for database initialization...
   └── Ready: Database accepts connections

2. api (starts after postgres is healthy)
   ├── Depends on: postgres (condition: service_healthy)
   ├── Database connection: postgresql://health_user:health_password@postgres:5432/health_db
   ├── Application startup: FastAPI server initialization
   └── Ready: API endpoints available at api:8000

3. frontend (starts after api is running)
   ├── Depends on: api (condition: service_started)
   ├── API connection: http://api:8000
   ├── Streamlit startup: Web interface initialization
   └── Ready: Web application available at frontend:8501
```

### Network Communication

#### Internal Service Discovery
- **Custom Network**: All services run on `health_network` (bridge driver)
- **DNS Resolution**: Docker provides automatic service discovery
  - `postgres` resolves to the database container IP
  - `api` resolves to the FastAPI container IP
  - `frontend` resolves to the Streamlit container IP

#### Communication Flows
1. **User → Frontend**: Browser connects to `localhost:8501`
2. **Frontend → API**: HTTP requests to `http://api:8000/back-pain/`
3. **API → Database**: PostgreSQL connections to `postgres:5432`
4. **User → API** (optional): Direct API access at `localhost:8000`

### Environment Configuration

#### Database Service Environment
```yaml
POSTGRES_USER: health_user
POSTGRES_PASSWORD: health_password
POSTGRES_DB: health_db
```

#### API Service Environment
```yaml
DATABASE_URL: postgresql://health_user:health_password@postgres:5432/health_db
FASTAPI_HOST: 0.0.0.0
FASTAPI_PORT: 8000
```

#### Frontend Service Environment
```yaml
API_URL: http://api:8000
```

### Volume Mounts & Data Persistence

#### Production Volumes
- **Database Data**: `postgres_data:/var/lib/postgresql/data` (named volume)
- **Application Code**: Embedded in container images

#### Development Volumes
- **Live Code Reload**: `./app:/app/app:ro` (read-only bind mounts)
- **Database Data**: `postgres_data:/var/lib/postgresql/data` (persistent)

### Port Mapping Strategy

| Service  | Internal Port | External Port | Purpose |
|----------|---------------|---------------|---------|
| postgres | 5432          | 5432          | Database access (dev/debugging) |
| api      | 8000          | 8000          | REST API endpoints |
| frontend | 8501          | 8501          | Web application interface |

### Health Checks & Reliability

#### Database Health Check
```bash
pg_isready -U health_user -d health_db
```
- **Interval**: Every 10 seconds
- **Timeout**: 5 seconds per check
- **Retries**: 5 attempts before marking unhealthy

#### Service Restart Policies
- **API**: `unless-stopped` - Restarts automatically unless manually stopped
- **Frontend**: `unless-stopped` - Restarts automatically unless manually stopped
- **Database**: Default policy - Stops if container fails

### Development vs Production Differences

#### Development Configuration (`make docker-dev`)
- **Volume Mounts**: Live code reload with `./app:/app/app:ro`
- **Logging**: Foreground mode with `docker-compose up` (no -d flag)
- **Code Changes**: Reflected immediately without rebuild

#### Production Configuration (`make docker-up`)
- **Volume Mounts**: No code volume mounts (code embedded in image)
- **Logging**: Background mode with `docker-compose up -d`
- **Code Changes**: Require image rebuild and container restart

### Troubleshooting Common Issues

#### Connection Problems
1. **Frontend can't reach API**: Check if `api` service is healthy
   ```bash
   make docker-status  # Check container status
   make docker-logs    # Check for API startup errors
   ```

2. **API can't reach Database**: Verify postgres health check
   ```bash
   docker-compose exec postgres pg_isready -U health_user -d health_db
   ```

3. **Services not starting**: Check dependency chain
   ```bash
   docker-compose ps      # Check service status
   docker-compose logs    # View startup logs
   ```

#### Network Issues
- Ensure all services are on the same network: `health_network`
- Verify internal DNS resolution: `docker-compose exec api ping postgres`
- Check port conflicts: `lsof -i :8000,8501,5432`

This architecture ensures a robust, scalable, and maintainable application stack with proper service isolation, health monitoring, and development flexibility.

## Architecture Overview

### Docker Setup (Production)
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Streamlit     │    │    FastAPI      │    │   PostgreSQL    │
│   Frontend      │◄──►│    Backend      │◄──►│   Database      │
│   Port: 8501    │    │   Port: 8000    │    │   Port: 5432    │
│   (Container)   │    │   (Container)   │    │   (Container)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Local Development Setup
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Streamlit     │    │    FastAPI      │    │   PostgreSQL    │
│   Frontend      │◄──►│    Backend      │◄──►│   Database      │
│   Port: 8501    │    │   Port: 8000    │    │   Port: 5432    │
│   (Local)       │    │   (Local)       │    │   (Container)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

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
