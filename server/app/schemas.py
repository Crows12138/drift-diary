from datetime import datetime

from pydantic import BaseModel


# ===== Auth =====
class WxLoginRequest(BaseModel):
    code: str


class DevLoginRequest(BaseModel):
    test_user_id: str  # 测试用，如 "test_user_1"


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"


# ===== Diary =====
class DiaryCreate(BaseModel):
    content: str
    mood_tag: str
    topic_tags: list[str] | None = None
    type: str  # private / drift


class DiaryResponse(BaseModel):
    id: int
    content: str
    mood_tag: str
    topic_tags: list[str] | None
    type: str
    ai_analysis: dict | None
    created_at: datetime

    model_config = {"from_attributes": True}


class DiaryListResponse(BaseModel):
    items: list[DiaryResponse]
    total: int


# ===== AI =====
class AIAnalyzeRequest(BaseModel):
    content: str


class AIAnalyzeResponse(BaseModel):
    mood: str  # 识别到的主要情绪
    intensity: int  # 情绪强度 1-10
    summary: str  # 一段温暖的分析文字
    keywords: list[str]  # 关键词


# ===== Drift =====
class DriftBottleResponse(BaseModel):
    id: int
    diary_content: str
    mood_tag: str
    current_station: int
    status: str
    responses: list["DriftResponseItem"]
    created_at: datetime


class DriftResponseItem(BaseModel):
    content: str
    station_number: int
    created_at: datetime


class DriftRespondRequest(BaseModel):
    content: str


class DriftMineItem(BaseModel):
    id: int
    diary_content_preview: str  # 前50字
    mood_tag: str
    current_station: int
    status: str
    has_new_response: bool
    created_at: datetime


# ===== Report =====
class ReportCreate(BaseModel):
    target_type: str  # diary / response
    target_id: int
    reason: str


class MessageResponse(BaseModel):
    message: str
