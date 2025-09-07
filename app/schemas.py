from pydantic import BaseModel
from datetime import date, datetime

class BackPainBase(BaseModel):
    """
    Base schema for back pain data.

    Attributes:
        pain_level (int): The level of back pain on a scale of 1 to 10.
        date (date): The date when the back pain was recorded.
    """
    pain_level: int
    date: date

class BackPainCreate(BackPainBase):
    """
    Schema for creating a new back pain entry.

    Inherits from BackPainBase and is used for input validation when creating a new entry.
    """
    pass

class BackPain(BackPainBase):
    """
    Schema for a back pain entry retrieved from the database.

    Attributes:
        id (int): The unique identifier for the back pain entry.
        created_at (datetime): The timestamp when the entry was created.
    """
    id: int
    created_at: datetime

    class Config:
        from_attributes = True 