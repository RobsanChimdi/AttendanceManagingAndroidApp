from fastapi import APIRouter, WebSocket, WebSocketDisconnect, Query, status
from typing import Optional
from app.services.websocket_manager import ws_manager

router = APIRouter(prefix="/ws", tags=["WebSocket Notifications"])

@router.websocket("/notifications")
async def websocket_notifications_endpoint(
    websocket: WebSocket,
    channel: Optional[str] = Query("all", description="Notification channel (all, admin, teacher)"),
    token: Optional[str] = Query(None, description="Auth token for verification")
):
    """
    WebSocket endpoint for real-time notification push & live attendance events.
    """
    await ws_manager.connect(websocket, channel=channel)
    try:
        # Send initial confirmation connection payload
        await websocket.send_json({
            "event": "connected",
            "message": "Connected to EduTrack AI real-time notification stream.",
            "channel": channel
        })
        
        while True:
            # Keep connection open and receive ping/messages from client
            data = await websocket.receive_text()
            # Echo back pong or handle client commands if needed
            if data == "ping":
                await websocket.send_json({"event": "pong"})

    except WebSocketDisconnect:
        ws_manager.disconnect(websocket, channel=channel)
    except Exception:
        ws_manager.disconnect(websocket, channel=channel)
