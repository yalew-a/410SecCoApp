FROM python:3.11-slim

WORKDIR /app

# Install dependencies first
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy app source code after dependencies
COPY app/ .

# Create a non-root user
# If the container is compromised, the attacker has non-root access.
RUN adduser --disabled-password --gecos "" appuser
# Switch to the non-root user
USER appuser

# Expose port 5000
EXPOSE 5000

# Run the command "python app.py"
CMD ["python", "app.py"]