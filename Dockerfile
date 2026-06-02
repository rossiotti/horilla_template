FROM python:3.10-slim-bullseye

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

# Install Python packages
RUN pip install --no-cache-dir -r requirements.txt

# Nuke the default env files to force Horilla to read Railway's Variables tab
RUN rm -f .env.dist .env

# Expose a fallback port just in case
EXPOSE 8000

# Bypass the native entrypoint.sh entirely. 
# We compile static files, run database migrations, and force the server to bind to Railway's dynamic PORT.
CMD sh -c "python3 manage.py collectstatic --noinput && python3 manage.py migrate && python3 manage.py runserver 0.0.0.0:${PORT:-8000}"
