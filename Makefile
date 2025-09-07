# Health Tracker App Makefile
# =========================

.PHONY: help install install-dev compile-deps db-up db-down db-reset db-logs run run-api run-frontend dev test lint format clean status logs docker-build docker-up docker-down docker-dev docker-logs docker-clean docker-status

# Default target
.DEFAULT_GOAL := help

# Variables
PYTHON := python3
PIP := pip3
DOCKER_COMPOSE := docker compose
UVICORN := uvicorn
STREAMLIT := streamlit
API_HOST := 0.0.0.0
API_PORT := 8000
FRONTEND_PORT := 8501

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
NC := \033[0m # No Color

# Help target
help: ## Show this help message
	@echo "$(BLUE)Health Tracker App - Available Commands:$(NC)"
	@echo ""
	@echo "$(YELLOW)Setup & Installation:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | grep -E '^(install|compile-deps)' | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)Database Management:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | grep -E '^db-' | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)Application Management:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | grep -E '^(run|dev)' | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)Development Tools:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | grep -E '^(test|lint|format|clean)' | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)Docker Commands:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | grep -E '^docker-' | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)Utility:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | grep -E '^(status|logs)' | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}'
	@echo ""

# Check if command exists
check-cmd = $(if $(shell command -v $(1) 2> /dev/null),,$(error "$(1) is not installed. Please install it first."))

# Setup & Installation
install: ## Install Python dependencies
	@echo "$(BLUE)Installing Python dependencies...$(NC)"
	@$(call check-cmd,$(PIP))
	$(PIP) install -r requirements.txt
	@echo "$(GREEN)Dependencies installed successfully!$(NC)"

install-dev: install ## Install development dependencies
	@echo "$(BLUE)Installing development dependencies...$(NC)"
	$(PIP) install pip-tools black flake8 pytest
	@echo "$(GREEN)Development dependencies installed successfully!$(NC)"

compile-deps: ## Compile requirements.in to requirements.txt
	@echo "$(BLUE)Compiling dependencies...$(NC)"
	@$(call check-cmd,pip-compile)
	pip-compile requirements.in
	@echo "$(GREEN)Dependencies compiled successfully!$(NC)"

# Database Management
db-up: ## Start PostgreSQL container
	@echo "$(BLUE)Starting PostgreSQL container...$(NC)"
	@$(call check-cmd,$(DOCKER_COMPOSE))
	$(DOCKER_COMPOSE) up -d
	@echo "$(GREEN)PostgreSQL container started!$(NC)"
	@echo "$(YELLOW)Waiting for database to be ready...$(NC)"
	@sleep 5
	@echo "$(GREEN)Database is ready!$(NC)"

db-down: ## Stop PostgreSQL container
	@echo "$(BLUE)Stopping PostgreSQL container...$(NC)"
	$(DOCKER_COMPOSE) down
	@echo "$(GREEN)PostgreSQL container stopped!$(NC)"

db-reset: ## Reset database (stop, remove volumes, restart)
	@echo "$(BLUE)Resetting database...$(NC)"
	$(DOCKER_COMPOSE) down -v
	@echo "$(YELLOW)Removed database volumes$(NC)"
	$(DOCKER_COMPOSE) up -d
	@echo "$(YELLOW)Waiting for database to be ready...$(NC)"
	@sleep 5
	@echo "$(GREEN)Database reset complete!$(NC)"

db-logs: ## View database logs
	@echo "$(BLUE)Showing PostgreSQL logs...$(NC)"
	$(DOCKER_COMPOSE) logs -f postgres

# Application Management
run: db-up ## Start the full application (database + API + frontend)
	@echo "$(BLUE)Starting the full health tracker application...$(NC)"
	@echo "$(YELLOW)Starting FastAPI backend...$(NC)"
	@$(call check-cmd,$(UVICORN))
	$(UVICORN) app.main:app --host $(API_HOST) --port $(API_PORT) --reload &
	@echo "$(YAML)Backend PID: $$!$(NC)"
	@echo "$(YELLOW)Waiting for API to be ready...$(NC)"
	@sleep 5
	@echo "$(YELLOW)Starting Streamlit frontend...$(NC)"
	@$(call check-cmd,$(STREAMLIT))
	$(STREAMLIT) run app/frontend.py --server.port $(FRONTEND_PORT)

run-api: db-up ## Start only the FastAPI backend
	@echo "$(BLUE)Starting FastAPI backend only...$(NC)"
	@$(call check-cmd,$(UVICORN))
	$(UVICORN) app.main:app --host $(API_HOST) --port $(API_PORT) --reload
	@echo "$(GREEN)API running at http://$(API_HOST):$(API_PORT)$(NC)"
	@echo "$(GREEN)API docs at http://$(API_HOST):$(API_PORT)/docs$(NC)"

run-frontend: ## Start only the Streamlit frontend
	@echo "$(BLUE)Starting Streamlit frontend only...$(NC)"
	@$(call check-cmd,$(STREAMLIT))
	$(STREAMLIT) run app/frontend.py --server.port $(FRONTEND_PORT)
	@echo "$(GREEN)Frontend running at http://localhost:$(FRONTEND_PORT)$(NC)"

dev: install db-up ## Start in development mode with auto-reload
	@echo "$(BLUE)Starting development environment...$(NC)"
	@echo "$(YELLOW)Starting FastAPI with auto-reload...$(NC)"
	$(UVICORN) app.main:app --host $(API_HOST) --port $(API_PORT) --reload &
	@sleep 3
	@echo "$(YELLOW)Starting Streamlit...$(NC)"
	$(STREAMLIT) run app/frontend.py --server.port $(FRONTEND_PORT)

# Development Tools
test: ## Run tests
	@echo "$(BLUE)Running tests...$(NC)"
	@if [ -d "tests" ]; then \
		$(PYTHON) -m pytest tests/ -v; \
	else \
		echo "$(YELLOW)No tests directory found. Create tests/ directory and add your tests.$(NC)"; \
	fi

lint: ## Run code linting
	@echo "$(BLUE)Running code linting...$(NC)"
	@if command -v flake8 > /dev/null 2>&1; then \
		flake8 app/ --max-line-length=88 --extend-ignore=E203,W503; \
	else \
		echo "$(YELLOW)flake8 not installed. Run 'make install-dev' first.$(NC)"; \
	fi

format: ## Format code with black
	@echo "$(BLUE)Formatting code...$(NC)"
	@if command -v black > /dev/null 2>&1; then \
		black app/; \
		echo "$(GREEN)Code formatted successfully!$(NC)"; \
	else \
		echo "$(YELLOW)black not installed. Run 'make install-dev' first.$(NC)"; \
	fi

clean: ## Clean up temporary files and caches
	@echo "$(BLUE)Cleaning up temporary files...$(NC)"
	find . -type f -name "*.pyc" -delete
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true
	find . -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
	@echo "$(GREEN)Cleanup complete!$(NC)"

# Utility
status: ## Check status of running services
	@echo "$(BLUE)Checking service status...$(NC)"
	@echo "$(YELLOW)Docker containers:$(NC)"
	@$(DOCKER_COMPOSE) ps 2>/dev/null || echo "$(RED)Docker compose not running$(NC)"
	@echo ""
	@echo "$(YELLOW)Running processes:$(NC)"
	@ps aux | grep -E "(uvicorn|streamlit)" | grep -v grep || echo "$(RED)No FastAPI/Streamlit processes found$(NC)"
	@echo ""
	@echo "$(YELLOW)Port usage:$(NC)"
	@lsof -i :$(API_PORT) 2>/dev/null | head -2 || echo "$(RED)Port $(API_PORT) not in use$(NC)"
	@lsof -i :$(FRONTEND_PORT) 2>/dev/null | head -2 || echo "$(RED)Port $(FRONTEND_PORT) not in use$(NC)"
	@lsof -i :5432 2>/dev/null | head -2 || echo "$(RED)Port 5432 (PostgreSQL) not in use$(NC)"

logs: ## View application logs
	@echo "$(BLUE)Application logs:$(NC)"
	@echo "$(YELLOW)=== Database Logs ====$(NC)"
	@$(DOCKER_COMPOSE) logs --tail=20 postgres 2>/dev/null || echo "$(RED)No database logs available$(NC)"

# Stop all services
stop: ## Stop all running services
	@echo "$(BLUE)Stopping all services...$(NC)"
	@pkill -f "uvicorn app.main:app" 2>/dev/null || true
	@pkill -f "streamlit run app/frontend.py" 2>/dev/null || true
	@$(DOCKER_COMPOSE) down 2>/dev/null || true
	@echo "$(GREEN)All services stopped!$(NC)"

# Quick start (equivalent to start_app.sh)
start: run ## Quick start (same as 'run')

# Docker Commands
docker-build: ## Build all Docker images
	@echo "$(BLUE)Building Docker images...$(NC)"
	@$(call check-cmd,docker)
	@$(call check-cmd,$(DOCKER_COMPOSE))
	$(DOCKER_COMPOSE) build --no-cache
	@echo "$(GREEN)Docker images built successfully!$(NC)"

docker-up: ## Start all services with Docker
	@echo "$(BLUE)Starting all services with Docker...$(NC)"
	@$(call check-cmd,docker)
	@$(call check-cmd,$(DOCKER_COMPOSE))
	$(DOCKER_COMPOSE) up -d
	@echo "$(GREEN)All services started!$(NC)"
	@echo "$(YELLOW)Frontend: http://localhost:8501$(NC)"
	@echo "$(YELLOW)API: http://localhost:8000$(NC)"
	@echo "$(YELLOW)API Docs: http://localhost:8000/docs$(NC)"

docker-dev: ## Start services with development volume mounts
	@echo "$(BLUE)Starting development environment with Docker...$(NC)"
	@$(call check-cmd,docker)
	@$(call check-cmd,$(DOCKER_COMPOSE))
	$(DOCKER_COMPOSE) up
	@echo "$(GREEN)Development environment started!$(NC)"

docker-down: ## Stop all Docker services
	@echo "$(BLUE)Stopping Docker services...$(NC)"
	$(DOCKER_COMPOSE) down
	@echo "$(GREEN)All services stopped!$(NC)"

docker-logs: ## View logs from all Docker services
	@echo "$(BLUE)Showing Docker service logs...$(NC)"
	$(DOCKER_COMPOSE) logs -f

docker-status: ## Show status of Docker services
	@echo "$(BLUE)Docker service status:$(NC)"
	$(DOCKER_COMPOSE) ps

docker-clean: ## Clean up Docker containers, images, and volumes
	@echo "$(BLUE)Cleaning up Docker resources...$(NC)"
	$(DOCKER_COMPOSE) down -v --rmi all --remove-orphans 2>/dev/null || true
	@echo "$(YELLOW)Removing unused Docker resources...$(NC)"
	docker system prune -f --volumes 2>/dev/null || true
	@echo "$(GREEN)Docker cleanup complete!$(NC)"

docker-rebuild: ## Rebuild and restart all services
	@echo "$(BLUE)Rebuilding and restarting services...$(NC)"
	$(DOCKER_COMPOSE) down
	$(DOCKER_COMPOSE) build --no-cache
	$(DOCKER_COMPOSE) up -d
	@echo "$(GREEN)Services rebuilt and restarted!$(NC)"

# Environment check
check-env: ## Check if all required tools are installed
	@echo "$(BLUE)Checking environment...$(NC)"
	@echo "$(YELLOW)=== Local Development ====$(NC)"
	@echo -n "Python 3: "
	@command -v $(PYTHON) >/dev/null 2>&1 && echo "$(GREEN)✓$(NC)" || echo "$(RED)✗$(NC)"
	@echo -n "pip: "
	@command -v $(PIP) >/dev/null 2>&1 && echo "$(GREEN)✓$(NC)" || echo "$(RED)✗$(NC)"
	@echo -n "uvicorn: "
	@command -v $(UVICORN) >/dev/null 2>&1 && echo "$(GREEN)✓$(NC)" || echo "$(RED)✗ (run 'make install')$(NC)"
	@echo -n "streamlit: "
	@command -v $(STREAMLIT) >/dev/null 2>&1 && echo "$(GREEN)✓$(NC)" || echo "$(RED)✗ (run 'make install')$(NC)"
	@echo ""
	@echo "$(YELLOW)=== Docker ====$(NC)"
	@echo -n "Docker: "
	@command -v docker >/dev/null 2>&1 && echo "$(GREEN)✓$(NC)" || echo "$(RED)✗$(NC)"
	@echo -n "Docker Compose: "
	@command -v $(DOCKER_COMPOSE) >/dev/null 2>&1 && echo "$(GREEN)✓$(NC)" || echo "$(RED)✗$(NC)"
