FROM alpine:3.22

RUN apk add --no-cache bash unzip gzip tar neovim uv python3

ARG UID=10001
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/home/capstone" \
    --shell "/bin/bash" \
    --no-create-home \
    --uid "${UID}" \
    user

RUN mkdir -p /home/capstone/data /home/capstone/data/zips /home/capstone/data/raw /home/capstone/data/mysql /home/capstone/scripts /home/capstone/src
RUN chown -R user:user /home/capstone

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

USER user
WORKDIR /home/capstone

VOLUME /home/capstone/data/mysql

ENTRYPOINT ["entrypoint.sh"]
CMD ["/bin/bash"]
