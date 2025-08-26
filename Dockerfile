FROM python:3.8-slim

# Install system dependencies needed for psycopg2 and other packages
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    libpq-dev \
    python3-dev \
    build-essential \
    libssl-dev \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Use older pip version
RUN pip install pip==20.3.4

# Install packages in specific order to avoid conflicts
RUN pip install --no-cache-dir six==1.12.0
RUN pip install --no-cache-dir MarkupSafe==1.1.1
RUN pip install --no-cache-dir itsdangerous==1.1.0
RUN pip install --no-cache-dir Click==7.0
RUN pip install --no-cache-dir Werkzeug==0.14.1
RUN pip install --no-cache-dir Jinja2==2.10.1
RUN pip install --no-cache-dir Flask==1.0.2
RUN pip install --no-cache-dir greenlet==0.4.15
RUN pip install --no-cache-dir SQLAlchemy==1.3.1
RUN pip install --no-cache-dir Flask-SQLAlchemy==2.3.2
RUN pip install --no-cache-dir Flask-Login==0.4.1
RUN pip install --no-cache-dir WTForms==2.2.1
RUN pip install --no-cache-dir Flask-WTF==0.14.2
RUN pip install --no-cache-dir passlib==1.7.1
RUN pip install --no-cache-dir psycopg2-binary==2.7.7
RUN pip install --no-cache-dir python-engineio==3.5.1
RUN pip install --no-cache-dir python-socketio==3.1.2
RUN pip install --no-cache-dir Flask-SocketIO==3.3.2
RUN pip install --no-cache-dir gevent==1.4.0
RUN pip install --no-cache-dir gevent-websocket==0.10.1
RUN pip install --no-cache-dir gunicorn==19.9.0

# Copy application code
COPY . .

# Expose the port your Flask app runs on
EXPOSE 5000

# Command to run the application
CMD ["python", "app.py"]
