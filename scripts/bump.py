#!/usr/bin/env python3
"""Point the sidecarkeeper formula at a release tag. Usage: bump.py v1.2.3

Reads the SidecarLauncher commit that release pins from its install.sh, so the formula always
builds the same upstream code as the official installer. Prints "unchanged" or "bumped".
"""
import hashlib, pathlib, re, sys, urllib.request

REPO = "https://github.com/EMOEMOJAI/SidecarKeeper"
UPSTREAM = "https://github.com/Ocasio-J/SidecarLauncher"
tag = sys.argv[1]
if not re.fullmatch(r"v\d+(\.\d+)+", tag):
    sys.exit(f"refusing odd tag: {tag!r}")

def fetch(url):
    with urllib.request.urlopen(url, timeout=60) as r:
        return r.read()

def sha(url):
    return hashlib.sha256(fetch(url)).hexdigest()

installer = fetch(f"https://raw.githubusercontent.com/EMOEMOJAI/SidecarKeeper/{tag}/install.sh").decode()
m = re.search(r'^UPSTREAM_REF="\$\{SIDECARLAUNCHER_REF:-([0-9a-f]{40})\}"$', installer, re.M)
if not m:
    sys.exit("could not find the pinned SidecarLauncher commit in install.sh")
ref = m.group(1)

src_url = f"{REPO}/archive/refs/tags/{tag}.tar.gz"
up_url = f"{UPSTREAM}/archive/{ref}.tar.gz"
path = pathlib.Path(__file__).resolve().parent.parent / "Formula" / "sidecarkeeper.rb"
old = path.read_text()

new, n1 = re.subn(r'(\n  url ")[^"]*("\n  sha256 ")[0-9a-f]{64}(")',
                  lambda k: f"{k.group(1)}{src_url}{k.group(2)}{sha(src_url)}{k.group(3)}", old, count=1)
new, n2 = re.subn(r'(\n    url ")[^"]*("\n    sha256 ")[0-9a-f]{64}(")',
                  lambda k: f"{k.group(1)}{up_url}{k.group(2)}{sha(up_url)}{k.group(3)}", new, count=1)
if (n1, n2) != (1, 1):
    sys.exit("formula layout changed, could not update it")
if new == old:
    print("unchanged")
else:
    path.write_text(new)
    print("bumped")
