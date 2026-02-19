"""
backend-fastapi/app/routes/state.py

State-related API routes.
This module defines endpoints under the `/state` prefix (configured in app/main.py).
These endpoints read the current aircraft/system state from the backing store (Redis).
"""

from fastapi import APIRouter
from ..services.state_service import get_current_state

# Router for all state endpoints. In app/main.py this is mounted like:
#   app.include_router(StateRouter, prefix="/state", tags=["State"])
router = APIRouter()


@router.get(
    "/current",
    summary="Get current aircraft state",
    description="Returns the latest F-35 state snapshot from Redis (key: 'f35:state'). "
                "If Redis is unavailable or not configured, returns an empty object.",
)
def state():
    """
    Get the current state snapshot.
    Behavior:
    - Returns a dictionary of state fields from Redis when available.
    - Returns {} if Redis is unavailable, not configured, or no state is present.

    Note:
    - We intentionally do NOT raise an HTTP error here because you requested that
      the endpoint returns {} instead of failing.
    """
    return get_current_state()