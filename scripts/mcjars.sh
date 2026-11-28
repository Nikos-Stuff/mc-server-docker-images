set -euo pipefail

SERVER_TYPE=${1:?Usage: $0 <server-type> <minecraft-version> <output>}
MC_VERSION=${2:?Usage: $0 <server-type> <minecraft-version> <output>}
OUTPUT=${3:?Usage: $0 <server-type> <minecraft-version> <output>}

API="https://mcjars.app/api/v3"
OUT_DIR="$(dirname "${OUTPUT}")"

SERVER_TYPE=$(echo "$SERVER_TYPE" | tr '[:lower:]' '[:upper:]')

URL="${API}/builds/types/${SERVER_TYPE}/versions/${MC_VERSION}/latest"

RESPONSE="$(curl -fsSL "${URL}")" || {
  echo "Couldn't reach ${URL}" >&2
  echo "Couldn't find ${SERVER_TYPE} build for Minecraft version ${MC_VERSION}" >&2
  exit 1
}

BUILD="$(echo "${RESPONSE}" | jq -c '.build // empty')"

if [ -z "${BUILD}" ]; then
  echo "No build found for ${SERVER_TYPE} ${MC_VERSION}" >&2
  exit 1
fi

EXPERIMENTAL="$(echo "${BUILD}" | jq -r '.experimental // false')"

if [ "${EXPERIMENTAL}" == "true" ]; then
    echo "Latest ${SERVER_TYPE} build for Minecraft ${MC_VERSION} is experimental" >&2
fi

UUID="$(echo "${BUILD}" | jq -r '.uuid // empty')"

echo "Using build ${UUID}"

DOWNLOAD="$(
    echo "${BUILD}" | jq -c '
        [
          .installation[][]
          | select(.type? == "download")
        ]
        | first
    '
)"

if [ -z "${DOWNLOAD}" ] || [ "${DOWNLOAD}" == "null" ]; then
  echo "Couldn't find a server JAR download for build ${UUID}" >&2
  exit 1
fi

DOWNLOAD_URL="$(echo "${DOWNLOAD}" | jq -r '.url // empty')"
FILENAME="$(echo "${DOWNLOAD}" | jq -r '.file // empty')"

mkdir -p ${OUT_DIR}

curl -fsSL -o "${OUTPUT}" "${DOWNLOAD_URL}"

echo "Saved ${SERVER_TYPE} ${MC_VERSION} (build ${UUID}) to ${OUTPUT}"
