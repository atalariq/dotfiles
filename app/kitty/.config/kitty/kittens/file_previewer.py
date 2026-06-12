#!/usr/bin/env python3
import os
import sys
import subprocess
from kitty.boss import Boss

def main(args):
    path = args[-1] if len(args) > 1 else None
    if not path:
        path = os.getcwd()

    if not os.path.exists(path):
        print(f"File not found: {path}")
        return

    stat = os.stat(path)
    size = stat.st_size
    is_dir = os.path.isdir(path)
    is_exec = os.access(path, os.X_OK)

    if is_dir:
        try:
            entries = os.listdir(path)
        except PermissionError:
            entries = ["(permission denied)"]
        content = "\n".join(entries[:50])
        if len(entries) > 50:
            content += f"\n... and {len(entries) - 50} more"
        header = f"Directory: {path}\nSize: {len(entries)} entries\n\n{content}"
    else:
        try:
            with open(path, "rb") as f:
                raw = f.read(4096)
            text = raw.decode("utf-8", errors="replace")
        except (OSError, UnicodeDecodeError):
            text = f"<binary file, {size} bytes>"

        ext = os.path.splitext(path)[1].lower()
        try:
            result = subprocess.run(
                ["bat", "--style=plain", "--color=always", "--line-range=:50", path],
                capture_output=True, text=True, timeout=5
            )
            if result.returncode == 0:
                text = result.stdout
        except (FileNotFoundError, subprocess.TimeoutExpired):
            pass

        header = f"File: {path}\nSize: {size} bytes"
        if is_exec:
            header += " (executable)"
        header += f"\nType: {ext or '(no extension)'}\n\n{text}"

    print(header)


def handle_result(args, answer, target_window_id, boss):
    pass


if __name__ == "__main__":
    main(sys.argv[1:])
