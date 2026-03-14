from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session, joinedload

from app.database import get_db
from app.deps import get_current_user
from app.models import Diary, DriftBottle, DriftResponse, Report, User
from app.schemas import (
    DriftBottleResponse,
    DriftMineItem,
    DriftRespondRequest,
    DriftResponseItem,
    MessageResponse,
    ReportCreate,
)
from app.services.ai_service import moderate_content

router = APIRouter()


@router.post("/pick", response_model=DriftBottleResponse)
async def pick_bottle(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    """捡一个漂流瓶（随机匹配一个不是自己的、正在漂流的瓶子）"""
    bottle = (
        db.query(DriftBottle)
        .join(Diary)
        .filter(
            DriftBottle.status == "drifting",
            Diary.user_id != user.id,  # 不能捡自己的
            DriftBottle.current_holder_id.is_(None),  # 没被别人持有
        )
        .options(joinedload(DriftBottle.diary), joinedload(DriftBottle.responses))
        .order_by(DriftBottle.created_at)  # 先投出的先被捡到
        .first()
    )

    if not bottle:
        raise HTTPException(status_code=404, detail="暂时没有漂流瓶可捡，过一会儿再来看看吧")

    # 标记为被捡起
    bottle.status = "picked"
    bottle.current_holder_id = user.id
    bottle.picked_at = datetime.now(timezone.utc)
    db.commit()
    db.refresh(bottle)

    return DriftBottleResponse(
        id=bottle.id,
        diary_content=bottle.diary.content,
        mood_tag=bottle.diary.mood_tag,
        current_station=bottle.current_station,
        status=bottle.status,
        responses=[
            DriftResponseItem(
                content=r.content,
                station_number=r.station_number,
                created_at=r.created_at,
            )
            for r in bottle.responses
        ],
        created_at=bottle.created_at,
    )


@router.post("/{bottle_id}/respond", response_model=MessageResponse)
async def respond_to_bottle(
    bottle_id: int,
    req: DriftRespondRequest,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    """给漂流瓶写回应，然后放回漂流"""
    bottle = (
        db.query(DriftBottle)
        .filter(DriftBottle.id == bottle_id, DriftBottle.current_holder_id == user.id)
        .first()
    )
    if not bottle:
        raise HTTPException(status_code=404, detail="漂流瓶不存在或你不是当前持有者")

    if not req.content.strip():
        raise HTTPException(status_code=400, detail="回应内容不能为空")

    # 内容审核
    moderation = await moderate_content(req.content)
    if not moderation.get("safe", True):
        raise HTTPException(status_code=400, detail=f"内容未通过审核: {moderation.get('reason', '')}")

    # 添加回应
    bottle.current_station += 1
    response = DriftResponse(
        drift_bottle_id=bottle.id,
        user_id=user.id,
        content=req.content.strip(),
        station_number=bottle.current_station,
    )
    db.add(response)

    # 放回漂流
    bottle.status = "drifting"
    bottle.current_holder_id = None
    bottle.picked_at = None

    db.commit()
    return MessageResponse(message="回应成功，漂流瓶已继续漂流")


@router.get("/mine", response_model=list[DriftMineItem])
def my_bottles(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    """获取我投出的漂流瓶列表"""
    bottles = (
        db.query(DriftBottle)
        .join(Diary)
        .filter(Diary.user_id == user.id, DriftBottle.status != "removed")
        .options(joinedload(DriftBottle.diary))
        .order_by(DriftBottle.created_at.desc())
        .all()
    )

    return [
        DriftMineItem(
            id=b.id,
            diary_content_preview=b.diary.content[:50],
            mood_tag=b.diary.mood_tag,
            current_station=b.current_station,
            status=b.status,
            has_new_response=b.current_station > 0,  # 简化判断
            created_at=b.created_at,
        )
        for b in bottles
    ]


@router.get("/{bottle_id}/journey", response_model=DriftBottleResponse)
def bottle_journey(
    bottle_id: int,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    """查看漂流瓶的旅程（原作者或曾经回应过的人可查看）"""
    bottle = (
        db.query(DriftBottle)
        .filter(DriftBottle.id == bottle_id)
        .options(joinedload(DriftBottle.diary), joinedload(DriftBottle.responses))
        .first()
    )
    if not bottle:
        raise HTTPException(status_code=404, detail="漂流瓶不存在")

    # 权限检查：原作者或曾经回应过的人
    is_author = bottle.diary.user_id == user.id
    has_responded = any(r.user_id == user.id for r in bottle.responses)
    if not is_author and not has_responded:
        raise HTTPException(status_code=403, detail="无权查看此漂流瓶旅程")

    return DriftBottleResponse(
        id=bottle.id,
        diary_content=bottle.diary.content,
        mood_tag=bottle.diary.mood_tag,
        current_station=bottle.current_station,
        status=bottle.status,
        responses=[
            DriftResponseItem(
                content=r.content,
                station_number=r.station_number,
                created_at=r.created_at,
            )
            for r in bottle.responses
        ],
        created_at=bottle.created_at,
    )


@router.post("/report", response_model=MessageResponse)
def report_content(
    req: ReportCreate,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    """举报不当内容"""
    if req.target_type not in ("diary", "response"):
        raise HTTPException(status_code=400, detail="target_type 必须是 diary 或 response")

    report = Report(
        reporter_id=user.id,
        target_type=req.target_type,
        target_id=req.target_id,
        reason=req.reason,
    )
    db.add(report)
    db.commit()
    return MessageResponse(message="举报已提交，我们会尽快处理")
