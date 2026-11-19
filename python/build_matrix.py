#!/usr/bin/env python3
"""Build the image matrix from versions/*.json."""

import json
import os
from glob import glob

from common import write_output


def build_matrix(engine_filter, version_filter):
    images = []
    for path in sorted(glob("versions/*.json")):
        engine = os.path.basename(path)[: -len(".json")]
        with open(path, encoding="utf-8") as handle:
            versions = json.load(handle)["versions"]
        images.extend({**version, "engine": engine} for version in versions)

    if engine_filter:
        wanted = {item.strip() for item in engine_filter.split(",")}
        images = [image for image in images if image["engine"] in wanted]
    if version_filter:
        wanted = {item.strip() for item in version_filter.split(",")}
        images = [image for image in images if image["minecraft"] in wanted]
    return images


if __name__ == "__main__":
    write_output("images", build_matrix(os.environ.get("ENGINES", ""), os.environ.get("VERSIONS", "")))
