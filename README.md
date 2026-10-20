# Setup
## Docker Container
To build the container:
- `docker compose up -d --build`

To run the container:
- `docker compose exec capstone bash`
## Data
Make sure all dropbox files are in the `/data/zips` directory. Then, once
inside the docker container and in the `capstone` project directory, run:
- `./scripts/build-raw-data.sh`

This will unzip all the `/data/zips/` files into `/data/raw`. This operation
took me about 10ish minutes to unzip all the data, so run it and take a break
or go do something.
