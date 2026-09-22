from fastapi import FastAPI, Depends
from app.core.config import get_setting, Settings
app = FastAPI(title=get_setting().APP_NAME)

@app.get("/health")
async def health(settings: Settings = Depends(get_setting)) -> dict[str, str]:
    return {"status": "ok", "app": settings.APP_NAME}
