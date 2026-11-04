#!/usr/bin/env python3

# Convert CSV and JSON files to Parquet format

# Usage:
#    python to_parquet.py data.csv
#    python to_parquet.py data.json -o out/ --compression zstd
#    python to_parquet.py ./raw_data/ -o ./parquet_data/

#Install dependency:
 #   pip install pyarrow


import argparse
import json
import sys
from pathlib import Path

import pyarrow as pa
import pyarrow.csv as pacsv
import pyarrow.json as pajson
import pyarrow.parquet as pq

CSV_SUFFIXES = {".csv", ".tsv"}
JSON_SUFFIXES = {".json", ".jsonl", ".ndjson"}
SUPPORTED = CSV_SUFFIXES | JSON_SUFFIXES


def convert_csv(src: Path, dst: Path, compression: str) -> int:
    """Stream a CSV/TSV into Parquet batch by batch (low memory use)."""
    delimiter = "\t" if src.suffix.lower() == ".tsv" else ","
    reader = pacsv.open_csv(
        src, parse_options=pacsv.ParseOptions(delimiter=delimiter)
    )
    rows = 0
    with pq.ParquetWriter(dst, reader.schema, compression=compression) as writer:
        for batch in reader:
            writer.write_batch(batch)
            rows += batch.num_rows
    return rows


def _first_char(path: Path) -> str:
    with open(path, "r", encoding="utf-8-sig") as f:
        while True:
            ch = f.read(1)
            if not ch or not ch.isspace():
                return ch


def _load_json_records(path: Path) -> pa.Table:
    """Load a JSON array / single object / wrapped list into a Table."""
    with open(path, "r", encoding="utf-8-sig") as f:
        data = json.load(f)

    # {"items": [ {...}, {...} ]} -> unwrap the single list of records
    if isinstance(data, dict):
        list_values = [
            v for v in data.values()
            if isinstance(v, list) and v and isinstance(v[0], dict)
        ]
        data = list_values[0] if len(list_values) == 1 else [data]

    if not isinstance(data, list):
        raise ValueError("JSON must contain an object or an array of objects")
    return pa.Table.from_pylist(data)


def convert_json(src: Path, dst: Path, compression: str) -> int:
    """Handle JSON arrays, pretty-printed objects, and JSON Lines."""
    table = None
    if _first_char(src) == "{":
        # Could be JSON Lines (one object per line) - try that first.
        try:
            table = pajson.read_json(src)
        except pa.ArrowInvalid:
            table = None
    if table is None:
        table = _load_json_records(src)

    pq.write_table(table, dst, compression=compression)
    return table.num_rows


def convert_file(src: Path, out_dir: Path, compression: str) -> None:
    out_dir.mkdir(parents=True, exist_ok=True)
    dst = out_dir / f"{src.stem}.parquet"
    suffix = src.suffix.lower()
    try:
        if suffix in CSV_SUFFIXES:
            rows = convert_csv(src, dst, compression)
        elif suffix in JSON_SUFFIXES:
            rows = convert_json(src, dst, compression)
        else:
            print(f"Skipping unsupported file: {src}")
            return
    except Exception as e:
        dst.unlink(missing_ok=True)  # don't leave a partial file behind
        print(f"FAILED  {src}: {e}", file=sys.stderr)
        return

    in_kb = src.stat().st_size / 1024
    out_kb = dst.stat().st_size / 1024
    print(f"OK      {src} -> {dst}  ({rows:,} rows, {in_kb:,.0f} KB -> {out_kb:,.0f} KB)")


def main() -> None:
    p = argparse.ArgumentParser(description="Convert CSV/JSON files to Parquet.")
    p.add_argument("input", type=Path, help="A file or a directory of files")
    p.add_argument("-o", "--output", type=Path, default=None,
                   help="Output directory (default: next to the input)")
    p.add_argument("-c", "--compression", default="snappy",
                   choices=["snappy", "zstd", "gzip", "brotli", "lz4", "none"],
                   help="Compression codec (default: snappy)")
    args = p.parse_args()

    if not args.input.exists():
        sys.exit(f"Input not found: {args.input}")

    if args.input.is_dir():
        files = sorted(f for f in args.input.iterdir()
                       if f.is_file() and f.suffix.lower() in SUPPORTED)
        out_dir = args.output or args.input
    else:
        files = [args.input]
        out_dir = args.output or args.input.parent

    if not files:
        sys.exit("No supported files (.csv, .tsv, .json, .jsonl, .ndjson) found.")

    for f in files:
        convert_file(f, out_dir, args.compression)


if __name__ == "__main__":
    main()