# Dockerfile
FROM python:3.11-slim

WORKDIR /app

# Install system deps (if any). Keep minimal.
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy and install Python deps
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy app code
COPY . .

# Expose the flask port
EXPOSE 5000

# Start the app (adjust if your entrypoint is different)
CMD ["python3", "application.py"]

