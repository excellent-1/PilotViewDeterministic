from fastapi import APIRouter
from ..services.state_service import get_current_state

router = APIRouter()

@router.get('/current')
def state():
    return get_current_state()
