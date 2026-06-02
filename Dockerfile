FROM python:3.10-slim-bullseye

# Keep stdout unbuffered so you can see logs in Railway in real-time
ENV PYTHONUNBUFFERED=1

# Install system dependencies (Added libpq-dev which is often required for PostgreSQL connections in Django)
RUN apt-get update && apt-get install -y \
    libcairo2-dev \
    gcc \
    git \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Clone Horilla directly into the working directory
RUN git clone https://github.com/horilla-opensource/horilla.git /horilla

WORKDIR /horilla

# Install Python requirements
RUN pip install --no-cache-dir -r requirements.txt

# Fix line endings and make entrypoint executable
RUN chmod +x /horilla/entrypoint.sh && sed -i 's/\r$//' /horilla/entrypoint.sh

# Remove the .env files entirely so Horilla is forced to read Railway's runtime environment variables
RUN rm -f .env.dist .env

# Bind Django to 0.0.0.0 and listen on the dynamic PORT provided by Railway
ENTRYPOINT ["/horilla/entrypoint.sh"]
CMD ["sh", "-c", "python3 manage.py runserver 0.0.0.0:${PORT:-8000}"]
