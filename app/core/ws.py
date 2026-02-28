from typing import Dict, Set
from fastapi import WebSocket


class WebSocketManager:
    def __init__(self) -> None:
        self.connections: Dict[int, Set[WebSocket]] = {}

    async def connect(self, user_id: int, websocket: WebSocket) -> None:
        await websocket.accept()
        self.connections.setdefault(user_id, set()).add(websocket)

    def disconnect(self, user_id: int, websocket: WebSocket) -> None:
        if user_id in self.connections:
            self.connections[user_id].discard(websocket)
            if not self.connections[user_id]:
                self.connections.pop(user_id, None)

    async def send_to_user(self, user_id: int, message: dict) -> None:
        for ws in list(self.connections.get(user_id, set())):
            await ws.send_json(message)

    async def broadcast(self, message: dict) -> None:
        for sockets in list(self.connections.values()):
            for ws in list(sockets):
                await ws.send_json(message)
