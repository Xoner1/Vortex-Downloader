from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from pydantic import BaseModel
import asyncio
from typing import Dict
import uuid
import sys
import os

from core.downloader import VortexDownloader
from environment import get_ffmpeg_path
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class DownloadRequest(BaseModel):
    url: str
    path: str
    mode: str
    quality: str

class ConnectionManager:
    def __init__(self):
        self.active_connections: Dict[str, WebSocket] = {}

    async def connect(self, task_id: str, websocket: WebSocket):
        await websocket.accept()
        self.active_connections[task_id] = websocket

    def disconnect(self, task_id: str):
        if task_id in self.active_connections:
            del self.active_connections[task_id]

    async def send_personal_message(self, message: str, task_id: str):
        if task_id in self.active_connections:
            await self.active_connections[task_id].send_text(message)

    async def send_personal_json(self, data: dict, task_id: str):
        if task_id in self.active_connections:
            await self.active_connections[task_id].send_json(data)

manager = ConnectionManager()
download_tasks = {}

# Global queue to receive events from all downloaders
progress_queue = asyncio.Queue()

async def process_queue():
    while True:
        try:
            event = await progress_queue.get()
            task_id = event.get("task_id")
            if task_id not in manager.active_connections:
                continue

            if event["type"] == "progress":
                await manager.send_personal_json(event["data"], task_id)
            elif event["type"] == "status":
                await manager.send_personal_json({"status_msg": event["data"]}, task_id)
        except Exception as e:
            print(f"Error sending progress: {e}")

@app.on_event("startup")
async def startup_event():
    asyncio.create_task(process_queue())

@app.post("/api/download")
async def start_download(request: DownloadRequest):
    task_id = str(uuid.uuid4())

    ffmpeg_bin = get_ffmpeg_path()
    if not os.path.exists(ffmpeg_bin) and ffmpeg_bin != "ffmpeg":
        pass # Letyt-dlp use default or try to find it

    downloader = VortexDownloader(task_id=task_id, progress_queue=progress_queue)
    download_tasks[task_id] = downloader

    downloader.start(request.url, request.path, request.mode, request.quality, ffmpeg_bin)

    return {"message": "Download started", "task_id": task_id}

@app.websocket("/ws/progress/{task_id}")
async def websocket_endpoint(websocket: WebSocket, task_id: str):
    await manager.connect(task_id, websocket)
    try:
        while True:
            # We keep the connection alive to send messages from the queue
            data = await websocket.receive_text()
    except WebSocketDisconnect:
        manager.disconnect(task_id)
