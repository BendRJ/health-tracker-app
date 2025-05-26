from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .routers import health
from .database import engine
from . import models

# Create database tables based on the models defined in models.py
models.Base.metadata.create_all(bind=engine)

# Initialize the FastAPI application
app = FastAPI()

# Configure CORS (Cross-Origin Resource Sharing) middleware
# This allows the frontend (Streamlit) to communicate with the backend (FastAPI)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, replace with specific origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include the health router for API endpoints
# This router handles requests related to back pain data
app.include_router(health.router, prefix="/api/v1") 