from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from .. import crud, schemas
from ..database import get_db

router = APIRouter()

@router.post("/back-pain/", response_model=schemas.BackPain)
def create_back_pain(back_pain: schemas.BackPainCreate, db: Session = Depends(get_db)):
    """
    Create a new back pain entry.

    Args:
        back_pain (schemas.BackPainCreate): The back pain data to be inserted.
        db (Session, optional): The database session. Defaults to Depends(get_db).

    Returns:
        schemas.BackPain: The newly created back pain entry.
    """
    return crud.create_back_pain(db=db, back_pain=back_pain)

@router.get("/back-pain/", response_model=List[schemas.BackPain])
def read_back_pain_entries(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """
    Retrieve a list of back pain entries.

    Args:
        skip (int, optional): Number of records to skip. Defaults to 0.
        limit (int, optional): Maximum number of records to return. Defaults to 100.
        db (Session, optional): The database session. Defaults to Depends(get_db).

    Returns:
        List[schemas.BackPain]: A list of back pain entries.
    """
    entries = crud.get_back_pain_entries(db, skip=skip, limit=limit)
    return entries 