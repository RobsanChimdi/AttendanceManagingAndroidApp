import json
import logging
from typing import List, Dict, Any, Set
from fastapi import WebSocket

logger = logging.getLogger(__name__)

class ConnectionManager:
    """
    WebSocket Connection Manager for handling real-time push notifications
    and attendance event streaming across active clients.
    """
    def __init__(self):
        # Store active connections
        self.active_connections: Set[WebSocket] = set()
        # Role/Channel-based client maps (e.g. 'admin', 'teacher')
        self.channel_connections: Dict[str, Set[WebSocket]] = {
            "admin": set(),
            "teacher": set(),
            "all": set(),
        }

    async def connect(self, websocket: WebSocket, channel: str = "all"):
        """
        Accept an incoming WebSocket connection and register it to a channel.
        """
        await websocket.accept()
        self.active_connections.add(websocket)
        
        if channel not in self.channel_connections:
            self.channel_connections[channel] = set()
        self.channel_connections[channel].add(websocket)
        self.channel_connections["all"].add(websocket)
        
        logger.info(f"WebSocket client connected on channel '{channel}'. Total active: {len(self.active_connections)}")

    def disconnect(self, websocket: WebSocket, channel: str = "all"):
        """
        Remove a disconnected client WebSocket.
        """
        if websocket in self.active_connections:
            self.active_connections.remove(websocket)
        
        for ch_set in self.channel_connections.values():
            if websocket in ch_set:
                ch_set.remove(websocket)
                
        logger.info(f"WebSocket client disconnected. Remaining active: {len(self.active_connections)}")

    async def send_personal_message(self, message: Dict[str, Any], websocket: WebSocket):
        """
        Send a JSON payload to a specific WebSocket client.
        """
        try:
            await websocket.send_json(message)
        except Exception as e:
            logger.error(f"Error sending personal message to WebSocket: {e}")

    async def broadcast(self, message: Dict[str, Any], channel: str = "all"):
        """
        Broadcast a notification payload to all connected clients in a channel.
        """
        target_connections = self.channel_connections.get(channel, self.active_connections)
        disconnected = []
        
        for connection in list(target_connections):
            try:
                await connection.send_json(message)
            except Exception as e:
                logger.warning(f"Failed to send to client socket, marking for removal: {e}")
                disconnected.append(connection)

        for conn in disconnected:
            self.disconnect(conn, channel)

# Global singleton instance
ws_manager = ConnectionManager()
