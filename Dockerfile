FROM python:3.11-slim-bookworm

# Keep logs unbuffered so they stream instantly to the Railway dashboard
ENV PYTHONUNBUFFERED=1

# Install system dependencies (libpq-dev is crucial for PostgreSQL)
RUN apt-get update && apt-get install -y \
    libcairo2-dev \
    gcc \
    git \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Clone the latest repository
RUN git clone https://github.com/horilla-opensource/horilla.git /horilla

WORKDIR /horilla

# Install Python packages + production WSGI server
RUN pip install --no-cache-dir -r requirements.txt gunicorn

# Nuke the default env files to force Horilla to read Railway's Variables tab
RUN rm -f .env.dist .env

# Expose fallback port
EXPOSE 8000

# Collect static, run migrations, and launch Gunicorn on Railway's dynamic PORT
CMD sh -c "python3 manage.py collectstatic --noinput && python3 manage.py migrate && exec gunicorn horilla.wsgi:application --bind 0.0.0.0:${PORT:-8000} --workers 1 --threads 4 --timeout 120"
