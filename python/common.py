import json
import os
import sys


def log(message):
    print(message, file=sys.stderr)


def compact(value):
    return json.dumps(value, separators=(",", ":"))


def write_output(name, value):
    """Append compact JSON as a GitHub Actions KEY=VALUE output."""
    line = f"{name}={compact(value)}\n"
    path = os.environ.get("GITHUB_OUTPUT")
    if path:
        with open(path, "a", encoding="utf-8") as handle:
            handle.write(line)
    else:
        sys.stdout.write(line)


def load_images(raw):
    return json.loads(raw) if raw else []
