from opentelemetry.sdk.trace import SpanProcessor
from contextvars import ContextVar

_session_id_ctx_var: ContextVar[str] = ContextVar("session_id", default=None)


def get_session_id() -> str:
    return _session_id_ctx_var.get()


def set_session_id(session_id: str) -> str:
    return _session_id_ctx_var.set(session_id)


class SessionSpanProcessor(SpanProcessor):
    def on_start(
        self,
        span,
        parent_context=None,
    ) -> None:
        session_id = get_session_id()
        if session_id:
            span.set_attribute("session.id", session_id)
