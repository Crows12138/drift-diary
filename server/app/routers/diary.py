from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db
from app.deps import get_current_user
from app.models import Diary, DriftBottle, User
from app.schemas import DiaryCreate, DiaryListResponse, DiaryResponse

router = APIRouter()


@router.post("", response_model=DiaryResponse)
def create_diary(
    req: DiaryCreate,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    """创建日记。如果 type=drift，同时创建漂流瓶记录"""
    if req.type not in ("private", "drift"):
        raise HTTPException(status_code=400, detail="type 必须是 private 或 drift")

    diary = Diary(
        user_id=user.id,
        content=req.content,
        mood_tag=req.mood_tag,
        topic_tags=req.topic_tags,
        type=req.type,
    )
    db.add(diary)
    db.flush()

    # 如果是漂流日记，自动创建漂流瓶
    if req.type == "drift":
        bottle = DriftBottle(diary_id=diary.id, status="drifting", current_station=0)
        db.add(bottle)

    db.commit()
    db.refresh(diary)
    return diary


@router.get("", response_model=DiaryListResponse)
def list_diaries(
    page: int = 1,
    page_size: int = 20,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    """获取我的日记列表（分页，按时间倒序）"""
    query = db.query(Diary).filter(Diary.user_id == user.id).order_by(Diary.created_at.desc())
    total = query.count()
    items = query.offset((page - 1) * page_size).limit(page_size).all()
    return DiaryListResponse(items=items, total=total)


@router.get("/{diary_id}", response_model=DiaryResponse)
def get_diary(
    diary_id: int,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    """获取日记详情（只能看自己的）"""
    diary = db.query(Diary).filter(Diary.id == diary_id, Diary.user_id == user.id).first()
    if not diary:
        raise HTTPException(status_code=404, detail="日记不存在")
    return diary


@router.delete("/{diary_id}")
def delete_diary(
    diary_id: int,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    """删除日记（如果有漂流瓶会一起删除）"""
    diary = db.query(Diary).filter(Diary.id == diary_id, Diary.user_id == user.id).first()
    if not diary:
        raise HTTPException(status_code=404, detail="日记不存在")

    # 如果有漂流瓶，标记为 removed
    if diary.drift_bottle:
        diary.drift_bottle.status = "removed"

    db.delete(diary)
    db.commit()
    return {"message": "已删除"}
