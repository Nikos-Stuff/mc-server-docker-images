#!/usr/bin/env python3

import json
import os

from common import load_images, write_output


def changed_images(images, state):
    return [
        image
        for image in images
        if state.get(f"{image['engine']}:{image['tag']}") != image["build_uuid"]
    ]


if __name__ == "__main__":
    state = json.loads(os.environ.get("STATE") or "{}")
    write_output("images", changed_images(load_images(os.environ.get("IMAGES")), state))
