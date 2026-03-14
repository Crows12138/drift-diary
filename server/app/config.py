from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    # 应用
    SECRET_KEY: str = "dev-secret-key-change-in-production"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7  # 7天

    # 数据库
    DATABASE_URL: str = "sqlite:///./drift_diary.db"

    # 微信小程序
    WX_APP_ID: str = ""
    WX_APP_SECRET: str = ""

    # Google Gemini API
    GOOGLE_API_KEY: str = ""

    model_config = {"env_file": ".env", "extra": "ignore"}


settings = Settings()
