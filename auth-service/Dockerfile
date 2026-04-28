ARG PYTHON_BASE_IMAGE=python:3.11-slim
FROM ${PYTHON_BASE_IMAGE}

WORKDIR /app

ENV UV_INDEX_URL=https://mirrors.aliyun.com/pypi/simple/
ENV UV_PYPI_INDEX=https://mirrors.aliyun.com/pypi/simple/

RUN pip install -i https://mirrors.aliyun.com/pypi/simple/ uv

COPY requirements.txt .

RUN uv pip install --system --no-cache-dir -r requirements.txt --index-url https://mirrors.aliyun.com/pypi/simple/

COPY . .

EXPOSE 8000

CMD ["uv", "run", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]