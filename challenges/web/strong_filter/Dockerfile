FROM python:3.11-slim

WORKDIR /app
COPY src/app /app
COPY flag.txt /app/flag.txt

RUN pip install flask

EXPOSE 5000
CMD ["python", "main.py"]
