FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

WORKDIR /app

COPY pyproject.toml README.md ./
COPY ai_chat_agent ./ai_chat_agent
COPY migrations ./migrations
COPY alembic.ini logging.json ./

RUN python -m pip install --no-cache-dir . \
    && useradd --system --uid 10001 --create-home app

USER app

EXPOSE 8088

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8088/healthz', timeout=3)" || exit 1

CMD ["uvicorn", "ai_chat_agent.main:app", "--host", "0.0.0.0", "--port", "8088", "--ws", "websockets", "--log-config", "logging.json"]
