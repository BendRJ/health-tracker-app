from sqlalchemy import Column, Integer, Date, DateTime
from sqlalchemy.ext.declarative import declarative_base
from datetime import datetime

Base = declarative_base()

class BackPain(Base):
    __tablename__ = "back_pain"

    id = Column(Integer, primary_key=True, index=True)
    pain_level = Column(Integer, nullable=False)
    date = Column(Date, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow) 