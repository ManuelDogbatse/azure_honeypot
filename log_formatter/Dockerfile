FROM debian:12

WORKDIR /src/app

SHELL ["/bin/bash", "-c"]

RUN apt update && apt install -y inotify-tools curl jq && \
apt-get clean && rm -rf /var/lib/apt/lists/*

COPY log_formatter/ ./

CMD ["bash", "format_logs.sh"]
