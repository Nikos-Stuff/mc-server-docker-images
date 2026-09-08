set -euo pipefail

SERVER_TYPE=${1:?Usage: $0 <server-type> <minecraft-version> <output>}
MC_VERSION=${2:?Usage: $0 <server-type> <minecraft-version> <output>}
OUTPUT=${3:?Usage: $0 <server-type> <minecraft-version> <output>}

API="https://mcjars.app/api/v3"
OUT_DIR="$(dirname "${OUTPUT}")"

SERVER_TYPE="${SERVER_TYPE^^}"

URL="${API}/builds/types/${SERVER_TYPE}/versions/${MC_VERSION}/latest"

RESPONSE="$(curl -fsSL "${URL}")" || {
  echo "Couldn't reach ${URL}" >&2
  echo "Couldn't find ${SERVER_TYPE} build for Minecraft version ${MC_VERSION}" >&2
  exit 1
}

BUILD="$(jq -c '.build // empty' <<<"${RESPONSE}")"

if [[ -z "${BUILD}" ]]; then
  echo "No build found for ${SERVER_TYPE} ${MC_VERSION}" >&2
  exit 1
fi

EXPERIMENTAL="$(jq -r '.experimental // false' <<<"${BUILD}")"

if [[ "${EXPERIMENTAL}" == "true" ]]; then
    echo "Latest ${SERVER_TYPE} build for Minecraft ${MC_VERSION} is experimental" >&2
    exit 1
fi

UUID="$(jq -r '.uuid // empty' <<<"${BUILD}")"

echo "Using build ${UUID}"

DOWNLOAD="$(
    jq -c '
        [
          .installation[][]
          | select(.type? == "download")
        ]
        | first
    ' <<<"${BUILD}"
)"

if [[ -z "${DOWNLOAD}" || "${DOWNLOAD}" == "null" ]]; then
  echo "Couldn't find a server JAR download for build ${UUID}" >&2
  exit 1
fi

DOWNLOAD_URL="$(jq -r '.url // empty' <<<"${DOWNLOAD}")"
FILENAME="$(jq -r '.file // empty' <<<"${DOWNLOAD}")"

mkdir -p ${OUT_DIR}

curl -fsSL -o "${OUTPUT}" "${DOWNLOAD_URL}"

echo "Saved ${SERVER_TYPE} ${MC_VERSION} (build ${UUID}) to ${OUTPUT}"
