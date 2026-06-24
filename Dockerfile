# ---- Build Stage ----
FROM python:3.11-slim AS builder

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# ---- Production Stage ----
FROM python:3.11-slim

# Create non-root user for security
RUN useradd --create-home --shell /bin/bash appuser

WORKDIR /app

# Copy installed packages from builder
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin/gunicorn /usr/local/bin/gunicorn

# Copy application source
COPY app/ .

# Set ownership to non-root user
RUN chown -R appuser:appuser /app

USER appuser

# Environment variables
ENV FLASK_ENV=production \
    PORT=5000 \
    APP_VERSION=1.0.0

EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')"

# Run with Gunicorn for production
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "--threads", "2", "--timeout", "60", "app:app"]
