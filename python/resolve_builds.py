#!/usr/bin/env python3
"""Resolve the latest jar build for every image in the matrix."""

import json
import os
import urllib.error
import urllib.request

from common import load_images, log, write_output

MCJARS_API = "https://mcjars.app/api/v3"
ENGINE_TYPES = {
    "paper": "PAPER",
    "purpur": "PURPUR",
    "fabric": "FABRIC",
    "leafmc": "LEAF",
}


def resolve_build_uuid(engine, minecraft, opener=urllib.request.urlopen):
    build_type = ENGINE_TYPES.get(engine)
    if build_type is None:
        log(f"No mcjars type mapping for engine {engine}; skipping")
        return None

    url = f"{MCJARS_API}/builds/types/{build_type}/versions/{minecraft}/latest"
    try:
        with opener(url, timeout=30) as response:
            payload = json.load(response)
    except (urllib.error.URLError, OSError, ValueError) as error:
        log(f"Couldn't resolve latest build for {engine} {minecraft}: {error}")
        return None

    uuid = (payload.get("build") or {}).get("uuid")
    if not uuid:
        log(f"Couldn't resolve latest build for {engine} {minecraft}; skipping")
        return None
    return uuid


def images_with_builds(images, opener=urllib.request.urlopen):
    result = []
    for image in images:
        uuid = resolve_build_uuid(image["engine"], image["minecraft"], opener)
        if uuid:
            result.append({**image, "build_uuid": uuid})
    return result


if __name__ == "__main__":
    write_output("images", images_with_builds(load_images(os.environ.get("IMAGES"))))
