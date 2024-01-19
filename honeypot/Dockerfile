FROM python:3

ARG PORT

WORKDIR /src/app

# Python environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Install Python dependencies
RUN pip3 install --upgrade pip
COPY honeypot/requirements.txt .
RUN pip3 install -r requirements.txt

# Expose inner port for clients to connect to
EXPOSE ${PORT}

COPY honeypot/ server_key* ./

CMD ["python3", "./honeypot.py"]
