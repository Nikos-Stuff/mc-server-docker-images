#!/usr/bin/env python3
"""Record the published jar builds in the JAR_BUILD_STATE repo variable."""

import json
import os
import subprocess

from common import compact, load_images


def record_state(images, state, repository, runner=subprocess.run):
    for image in images:
        state[f"{image['engine']}:{image['tag']}"] = image["build_uuid"]
    runner(
        [
            "gh", "variable", "set", "JAR_BUILD_STATE",
            "--repo", repository,
            "--body", compact(state),
        ],
        check=True,
    )
    return state


if __name__ == "__main__":
    record_state(
        load_images(os.environ.get("IMAGES")),
        json.loads(os.environ.get("STATE") or "{}"),
        os.environ["GITHUB_REPOSITORY"],
    )
