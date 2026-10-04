#!/usr/bin/env python3
"""Point Formula/mrdocs.rb and Formula/mrdocs-bin.rb at an mrdocs release.

Usage: bump.py <tag> <commit-sha> <darwin-sha256> <linux-sha256>
"""

import re
import sys
from pathlib import Path

tag, commit, darwin_sha, linux_sha = sys.argv[1:5]


def update(path, substitutions):
    text = Path(path).read_text()
    for pattern, replacement in substitutions:
        text, count = re.subn(pattern, replacement, text, flags=re.MULTILINE)
        if count != 1:
            sys.exit(f"{path}: expected exactly one match for {pattern!r}, found {count}")
    Path(path).write_text(text)


update("Formula/mrdocs.rb", [
    (r'^(\s+tag:\s+)"[^"]+"', rf'\g<1>"{tag}"'),
    (r'^(\s+revision:\s+)"[0-9a-f]{40}"', rf'\g<1>"{commit}"'),
])

release = f"https://github.com/cppalliance/mrdocs/releases/download/{tag}/MrDocs-{tag}"
update("Formula/mrdocs-bin.rb", [
    (r'^(\s+)url "[^"]+-Darwin\.tar\.xz"\n(\s+)sha256 "[0-9a-f]{64}"',
     rf'\g<1>url "{release}-Darwin.tar.xz"\n\g<2>sha256 "{darwin_sha}"'),
    (r'^(\s+)url "[^"]+-Linux\.tar\.xz"\n(\s+)sha256 "[0-9a-f]{64}"',
     rf'\g<1>url "{release}-Linux.tar.xz"\n\g<2>sha256 "{linux_sha}"'),
])
