# Setup
## Docker Container
To build and then run the container:
```bash
docker compose up -d --build
docker compose exec capstone bash
```
## MySql
Once within the container, run the following to connect to the mysql container:
```bash
mariadb -h db -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME"
```
## Data
Make sure all dropbox files are in the `/data/zips` directory. Then, once
inside the docker container and in the `capstone` project directory, run:
- `./scripts/build-raw-data.sh`

This will unzip all the `/data/zips/` files into `/data/raw`. This operation
took me about 10ish minutes to unzip all the data, so run it and take a break
or go do something.
