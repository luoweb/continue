# Dockerfile for Continue Dev Data Service
FROM registry.cn-hangzhou.aliyuncs.com/roweb/python:3.13-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install uv using pip
RUN pip install --no-cache-dir uv

# Copy project files
COPY pyproject.toml .
COPY main.py .
COPY database.py .

# Create data directory
RUN mkdir -p /app/data

# Environment variables
ENV HOST=0.0.0.0
ENV PORT=8001
ENV DB_TYPE=sqlite
ENV DATABASE_PATH=/app/data/dev_data.db
ENV REQUIRE_AUTH=false

# Install dependencies with uv (pydantic 1.x has prebuilt wheels)
RUN uv pip install --system --break-system-packages --no-cache \
    fastapi==0.110.0 \
    uvicorn==0.29.0 \
    python-dotenv==1.0.0 \
    pydantic==1.10.21 \
    pymysql>=1.1.0

# Expose port
EXPOSE 8001

# Run the application
CMD ["python", "main.py"]
