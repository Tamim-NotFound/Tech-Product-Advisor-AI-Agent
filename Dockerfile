# ---------- Stage 1: build dependencies ----------

FROM python:3.12-slim AS builder

# Copy the uv binary from its official image
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

WORKDIR /app

ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy

# Copy dependency manifests first for better Docker caching
COPY pyproject.toml uv.lock ./

# Install dependencies into /app/.venv
RUN uv sync --frozen --no-install-project --no-dev


# ---------- Stage 2: runtime ----------

FROM python:3.12-slim

# Create a non-root user
RUN groupadd --system app && \
    useradd --system --gid app --create-home app

WORKDIR /app

# Bring virtual environment from builder
COPY --from=builder /app/.venv /app/.venv

# Use virtual environment
ENV PATH="/app/.venv/bin:$PATH" \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Copy application code
COPY --chown=app:app app/ ./app/

USER app

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]