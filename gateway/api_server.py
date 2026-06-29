"""OpenAI-compatible API server — connect any frontend to Pravidhi.

Endpoints:
- POST /v1/chat/completions — Standard OpenAI Chat Completions
- GET  /v1/models             — List available models
- GET  /health                — Health check

All tool capabilities available through the chat endpoint.
"""

from __future__ import annotations

import logging
import time
import uuid
from typing import Any, Dict, List, Optional

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

from engine.pipeline import Pipeline
from engine.registry import get_registry

logger = logging.getLogger("pravidhi.api")


# ── Pydantic Models ──────────────────────────────────────────────────────────

class ChatMessage(BaseModel):
    role: str
    content: str | List[Dict[str, Any]]


class ChatRequest(BaseModel):
    model: str = "pravidhi-agent"
    messages: List[ChatMessage]
    stream: bool = False
    max_tokens: int = 4096
    temperature: float = 0.7


class ChatChoice(BaseModel):
    index: int = 0
    message: ChatMessage
    finish_reason: str = "stop"


class ChatUsage(BaseModel):
    prompt_tokens: int = 0
    completion_tokens: int = 0
    total_tokens: int = 0


class ChatResponse(BaseModel):
    id: str = ""
    object: str = "chat.completion"
    created: int = 0
    model: str = "pravidhi-agent"
    choices: List[ChatChoice]
    usage: ChatUsage = ChatUsage()


class ModelInfo(BaseModel):
    id: str
    object: str = "model"
    created: int


class ModelsResponse(BaseModel):
    object: str = "list"
    data: List[ModelInfo]


# ── FastAPI App ──────────────────────────────────────────────────────────────

app = FastAPI(title="Pravidhi API", version="0.1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.on_event("startup")
async def startup():
    """Initialize Pravidhi engine on API startup."""
    from engine.registry import get_registry
    registry = get_registry()
    registry.discover_skills()
    # Mount control UI
    mount_control_ui(app)
    logger.info("Pravidhi API server started")


@app.get("/health")
async def health():
    return {
        "status": "ok",
        "service": "pravidhi",
        "version": "0.1.0",
        "timestamp": time.time(),
    }


@app.get("/v1/models", response_model=ModelsResponse)
async def list_models():
    """List available models (OpenAI-compatible)."""
    from engine.provider_router import BUILTIN_PROVIDERS
    models = []
    now = int(time.time())
    for provider_name, info in BUILTIN_PROVIDERS.items():
        for model_name in info.get("models", {}):
            models.append(ModelInfo(
                id=f"{provider_name}/{model_name}",
                created=now,
            ))
    return ModelsResponse(data=models)


@app.post("/v1/chat/completions", response_model=ChatResponse)
async def chat_completions(request: ChatRequest):
    """Standard OpenAI Chat Completions endpoint with full tool access."""
    # Extract user message
    user_message = ""
    for msg in request.messages:
        if msg.role == "user":
            if isinstance(msg.content, str):
                user_message = msg.content
            elif isinstance(msg.content, list):
                texts = [p.get("text", "") for p in msg.content if "text" in p]
                user_message = " ".join(texts)

    if not user_message:
        raise HTTPException(status_code=400, detail="No user message found")

    # Run through Pravidhi pipeline
    pipeline = Pipeline()
    ctx = await pipeline.run(user_message)

    response_content = ""
    if ctx.final_output:
        response_content = ctx.final_output.get("content", str(ctx.final_output))
    if not response_content:
        response_content = "I processed your request through the Pravidhi pipeline."

    if ctx.errors:
        response_content += f"\n\n[Pipeline completed with {len(ctx.errors)} warnings]"

    return ChatResponse(
        id=f"pravidhi-{ctx.request_id}",
        created=int(ctx.start_time),
        model=request.model,
        choices=[
            ChatChoice(
                index=0,
                message=ChatMessage(role="assistant", content=response_content),
                finish_reason="stop",
            )
        ],
        usage=ChatUsage(total_tokens=len(user_message.split()) + len(response_content.split())),
    )


# ── Standalone Runner ────────────────────────────────────────────────────────

def start_server(host: str = "127.0.0.1", port: int = 8642):
    """Start the API server with uvicorn."""
    import uvicorn
    logger.info(f"Starting Pravidhi API server on http://{host}:{port}")
    uvicorn.run(app, host=host, port=port, log_level="info")
