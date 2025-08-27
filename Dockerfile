FROM python:3.8-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    libpq-dev \
    python3-dev \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install only essential packages without strict versioning
RUN pip install --no-cache-dir \
    Flask==1.0.2 \
    Flask-SQLAlchemy==2.3.2 \
    Flask-Login==0.4.1 \
    Flask-SocketIO==3.3.2 \
    psycopg2-binary \
    gunicorn

# Copy application code
COPY . .

# Expose the port
EXPOSE 5000

# Command to run the application
CMD ["python", "application.py"]
