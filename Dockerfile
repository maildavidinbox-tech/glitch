FROM python:3.11-slim
WORKDIR /app
COPY . .
CMD ["python", "-c", "print('hello from docker image')"]
