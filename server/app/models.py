from datetime import datetime

from sqlalchemy import DateTime, ForeignKey, Integer, JSON, String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base


class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    openid: Mapped[str] = mapped_column(String(128), unique=True, index=True)
    nickname: Mapped[str | None] = mapped_column(String(64), nullable=True)
    status: Mapped[str] = mapped_column(String(16), default="active")  # active / banned
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    diaries: Mapped[list["Diary"]] = relationship(back_populates="user")


class Diary(Base):
    __tablename__ = "diaries"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    user_id: Mapped[int] = mapped_column(Integer, ForeignKey("users.id"), index=True)
    content: Mapped[str] = mapped_column(Text)
    mood_tag: Mapped[str] = mapped_column(String(32))  # happy/calm/anxious/sad/angry/confused/grateful
    topic_tags: Mapped[dict | None] = mapped_column(JSON, nullable=True)  # ["工作", "成长"]
    type: Mapped[str] = mapped_column(String(16))  # private / drift
    ai_analysis: Mapped[dict | None] = mapped_column(JSON, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    user: Mapped["User"] = relationship(back_populates="diaries")
    drift_bottle: Mapped["DriftBottle | None"] = relationship(back_populates="diary", uselist=False)


class DriftBottle(Base):
    __tablename__ = "drift_bottles"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    diary_id: Mapped[int] = mapped_column(Integer, ForeignKey("diaries.id"), unique=True)
    status: Mapped[str] = mapped_column(String(16), default="drifting")  # drifting / picked / removed
    current_station: Mapped[int] = mapped_column(Integer, default=0)
    current_holder_id: Mapped[int | None] = mapped_column(Integer, ForeignKey("users.id"), nullable=True)
    picked_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    diary: Mapped["Diary"] = relationship(back_populates="drift_bottle")
    responses: Mapped[list["DriftResponse"]] = relationship(back_populates="drift_bottle", order_by="DriftResponse.station_number")


class DriftResponse(Base):
    __tablename__ = "drift_responses"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    drift_bottle_id: Mapped[int] = mapped_column(Integer, ForeignKey("drift_bottles.id"), index=True)
    user_id: Mapped[int] = mapped_column(Integer, ForeignKey("users.id"))
    content: Mapped[str] = mapped_column(Text)
    station_number: Mapped[int] = mapped_column(Integer)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    drift_bottle: Mapped["DriftBottle"] = relationship(back_populates="responses")


class Report(Base):
    __tablename__ = "reports"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    reporter_id: Mapped[int] = mapped_column(Integer, ForeignKey("users.id"))
    target_type: Mapped[str] = mapped_column(String(16))  # diary / response
    target_id: Mapped[int] = mapped_column(Integer)
    reason: Mapped[str] = mapped_column(String(256))
    status: Mapped[str] = mapped_column(String(16), default="pending")  # pending / reviewed / resolved
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
