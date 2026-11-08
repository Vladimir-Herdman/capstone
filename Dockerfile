FROM alpine:3.22

RUN apk add --no-cache bash unzip gzip tar neovim uv python3 mariadb-client
RUN printf "[client]\nskip-ssl\nlocal-infile=1\n" > /etc/my.cnf.d/client.cnf

ARG UID=10001
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/home/capstone" \
    --shell "/bin/bash" \
    --no-create-home \
    --uid "${UID}" \
    user

RUN mkdir -p /home/capstone/data       \
             /home/capstone/data/zips  \
             /home/capstone/data/raw   \
             /home/capstone/data/mysql \
             /home/capstone/scripts    \
             /home/capstone/src
RUN chown -R user:user /home/capstone

COPY ./scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

USER user
WORKDIR /home/capstone

ENTRYPOINT ["entrypoint.sh"]
CMD ["/bin/bash"]
