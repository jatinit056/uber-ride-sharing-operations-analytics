"""Download the large raw Uber trip files (not stored in Git because of their size) into data/raw/.

Source: FiveThirtyEight's "uber-tlc-foil-response" repository (data the NYC Taxi & Limousine Commission released
under a Freedom of Information Law request). The URLs are pinned to one commit, and every file is checked against the
SHA-256 checksums in data/raw/SHA256SUMS.txt, so you get exactly the files used in this project.

Usage (from the project root):
    python scripts/download_data.py

Downloads about 280 MB and also extracts uber-raw-data-janjune-15.csv (552 MB) from its zip for the SQL load.
Only the Python standard library is used.
"""
import hashlib
import shutil
import sys
import urllib.request
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RAW = ROOT / "data" / "raw"
COMMIT = "63bb878b76f47f69b4527d50af57aac26dead983"
BASE_URL = f"https://raw.githubusercontent.com/fivethirtyeight/uber-tlc-foil-response/{COMMIT}/uber-trip-data/"
FILES = [f"uber-raw-data-{m}14.csv" for m in ("apr", "may", "jun", "jul", "aug", "sep")] + ["uber-raw-data-janjune-15.csv.zip"]
EXTRACT = "uber-raw-data-janjune-15.csv"


def expected_hashes():
    hashes = {}
    for line in (RAW / "SHA256SUMS.txt").read_text().splitlines():
        if line.strip() and not line.startswith("#"):
            digest, name = line.split(maxsplit=1)
            hashes[name.strip()] = digest
    return hashes


def sha256(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def download(name, digest):
    target = RAW / name
    if target.exists() and sha256(target) == digest:
        print(f"ok (already downloaded)  {name}")
        return
    tmp = target.with_suffix(target.suffix + ".part")
    print(f"downloading {name} ...", flush=True)
    with urllib.request.urlopen(BASE_URL + name, timeout=120) as response, open(tmp, "wb") as out:
        shutil.copyfileobj(response, out, length=1 << 20)
    actual = sha256(tmp)
    if actual != digest:
        tmp.unlink()
        sys.exit(f"Checksum mismatch for {name}: expected {digest}, got {actual}. File deleted - please retry.")
    tmp.replace(target)
    print(f"ok  {name}  ({target.stat().st_size / 1e6:.1f} MB, SHA-256 verified)")


def extract_2015(digest):
    target = RAW / EXTRACT
    if target.exists() and sha256(target) == digest:
        print(f"ok (already extracted)  {EXTRACT}")
        return
    print(f"extracting {EXTRACT} for the SQL load ...", flush=True)
    with zipfile.ZipFile(RAW / "uber-raw-data-janjune-15.csv.zip") as z, z.open(EXTRACT) as src, open(target, "wb") as out:
        shutil.copyfileobj(src, out, length=1 << 20)
    if sha256(target) != digest:
        sys.exit(f"Checksum mismatch for extracted {EXTRACT}.")
    print(f"ok  {EXTRACT}  ({target.stat().st_size / 1e6:.0f} MB, SHA-256 verified)")


if __name__ == "__main__":
    hashes = expected_hashes()
    for name in FILES:
        download(name, hashes[name])
    extract_2015(hashes[EXTRACT])
    print("All raw files are in place:", RAW)
