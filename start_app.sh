#!/bin/bash

# Start PostgreSQL container
echo "Starting PostgreSQL container..."
docker-compose up -d

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
sleep 5

# Start FastAPI backend
echo "Starting FastAPI backend..."
uvicorn app.main:app --reload &

# Wait for FastAPI to be ready
echo "Waiting for FastAPI to be ready..."
sleep 5

# Start Streamlit frontend
echo "Starting Streamlit frontend..."
streamlit run app/frontend.py 