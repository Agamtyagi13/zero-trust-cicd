FROM python:3.8-slim-buster
WORKDIR /app
COPY requirements.txt app.py ./
RUN pip install --no-cache-dir -r requirements.txt
# runs as root, outdated base, vulnerable deps, embedded secret = compromised
CMD ["python","app.py"]
