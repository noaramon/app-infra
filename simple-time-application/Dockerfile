FROM python:3.9-slim-bookworm

RUN mkdir /app
WORKDIR /app
ADD . /app/
RUN pip install --no-cache-dir  -r requirements.txt

EXPOSE 8080
CMD ["python", "/app/main.py"]