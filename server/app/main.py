from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.database import Base, engine
from app.routers import ai, auth, diary, drift

# 创建数据库表
Base.metadata.create_all(bind=engine)

app = FastAPI(title="漂流日记 API", version="0.1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router, prefix="/api/auth", tags=["认证"])
app.include_router(diary.router, prefix="/api/diaries", tags=["日记"])
app.include_router(ai.router, prefix="/api/ai", tags=["AI"])
app.include_router(drift.router, prefix="/api/drift", tags=["漂流瓶"])


@app.get("/")
def root():
    return {"message": "漂流日记 API 正在运行"}
