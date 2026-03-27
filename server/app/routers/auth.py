from datetime import datetime, timedelta, timezone
from hashlib import sha256

import httpx
from fastapi import APIRouter, Depends, HTTPException
from jose import jwt
from sqlalchemy.orm import Session

from app.config import settings
from app.database import get_db
from app.models import User
from app.schemas import (
    DevLoginRequest,
    LoginRequest,
    RegisterRequest,
    TokenResponse,
    WxLoginRequest,
)

router = APIRouter()


def create_token(user_id: int) -> str:
    expire = datetime.now(timezone.utc) + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    payload = {"sub": str(user_id), "exp": expire}
    return jwt.encode(payload, settings.SECRET_KEY, algorithm="HS256")


def _hash_password(password: str) -> str:
    return sha256((password + settings.SECRET_KEY).encode()).hexdigest()


@router.post("/register", response_model=TokenResponse)
def register(req: RegisterRequest, db: Session = Depends(get_db)):
    """用户名密码注册"""
    if len(req.username) < 2 or len(req.username) > 20:
        raise HTTPException(status_code=400, detail="用户名长度需要2-20个字符")
    if len(req.password) < 6:
        raise HTTPException(status_code=400, detail="密码至少6个字符")

    existing = db.query(User).filter(User.openid == req.username).first()
    if existing:
        raise HTTPException(status_code=400, detail="用户名已被注册")

    user = User(
        openid=req.username,
        nickname=req.nickname or req.username,
        password_hash=_hash_password(req.password),
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return TokenResponse(access_token=create_token(user.id))


@router.post("/login", response_model=TokenResponse)
def login(req: LoginRequest, db: Session = Depends(get_db)):
    """用户名密码登录"""
    user = db.query(User).filter(User.openid == req.username).first()
    if not user or not user.password_hash:
        raise HTTPException(status_code=401, detail="用户名或密码错误")
    if user.password_hash != _hash_password(req.password):
        raise HTTPException(status_code=401, detail="用户名或密码错误")
    if user.status == "banned":
        raise HTTPException(status_code=403, detail="账号已被封禁")
    return TokenResponse(access_token=create_token(user.id))


@router.post("/wx-login", response_model=TokenResponse)
async def wx_login(req: WxLoginRequest, db: Session = Depends(get_db)):
    """微信小程序登录：用 code 换 openid，创建或查找用户，返回 JWT"""
    async with httpx.AsyncClient() as client:
        resp = await client.get(
            "https://api.weixin.qq.com/sns/jscode2session",
            params={
                "appid": settings.WX_APP_ID,
                "secret": settings.WX_APP_SECRET,
                "js_code": req.code,
                "grant_type": "authorization_code",
            },
        )
    data = resp.json()
    openid = data.get("openid")
    if not openid:
        raise HTTPException(status_code=400, detail=f"微信登录失败: {data.get('errmsg', '未知错误')}")

    # 查找或创建用户
    user = db.query(User).filter(User.openid == openid).first()
    if not user:
        user = User(openid=openid)
        db.add(user)
        db.commit()
        db.refresh(user)

    return TokenResponse(access_token=create_token(user.id))


@router.post("/dev-login", response_model=TokenResponse)
def dev_login(req: DevLoginRequest, db: Session = Depends(get_db)):
    """开发环境测试登录，用 test_user_id 直接创建/查找用户"""
    openid = f"dev_{req.test_user_id}"
    user = db.query(User).filter(User.openid == openid).first()
    if not user:
        user = User(openid=openid, nickname=req.test_user_id)
        db.add(user)
        db.commit()
        db.refresh(user)

    return TokenResponse(access_token=create_token(user.id))
