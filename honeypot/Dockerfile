FROM python:3

WORKDIR /src/app

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN pip3 install --upgrade pip
COPY honeypot/requirements.txt .
RUN pip3 install -r requirements.txt

EXPOSE 2222

COPY honeypot/ server_key* .

CMD ["python3", "./honeypot.py"]
