from fastapi import APIRouter, Depends

from app.deps import get_current_user
from app.models import User
from app.schemas import AIAnalyzeRequest, AIAnalyzeResponse
from app.services.ai_service import analyze_emotion

router = APIRouter()


@router.post("/analyze", response_model=AIAnalyzeResponse)
async def analyze_diary(
    req: AIAnalyzeRequest,
    user: User = Depends(get_current_user),
):
    """AI 情绪分析"""
    result = await analyze_emotion(req.content)
    return AIAnalyzeResponse(**result)
