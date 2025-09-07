from sqlalchemy.orm import Session
from . import models, schemas

def create_back_pain(db: Session, back_pain: schemas.BackPainCreate):
    """
    Create a new back pain entry in the database.

    Args:
        db (Session): The database session.
        back_pain (schemas.BackPainCreate): The back pain data to be inserted.

    Returns:
        models.BackPain: The newly created back pain entry.
    """
    db_back_pain = models.BackPain(
        pain_level=back_pain.pain_level,
        date=back_pain.date
    )
    db.add(db_back_pain)
    db.commit()
    db.refresh(db_back_pain)
    return db_back_pain

def get_back_pain_entries(db: Session, skip: int = 0, limit: int = 100):
    """
    Retrieve a list of back pain entries from the database.

    Args:
        db (Session): The database session.
        skip (int, optional): Number of records to skip. Defaults to 0.
        limit (int, optional): Maximum number of records to return. Defaults to 100.

    Returns:
        List[models.BackPain]: A list of back pain entries.
    """
    return db.query(models.BackPain).offset(skip).limit(limit).all() 