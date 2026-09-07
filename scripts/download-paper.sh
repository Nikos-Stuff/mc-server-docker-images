set -euo pipefail

MC_VERSION=${1:?Usage: $0 <minecraft-version> <output>}
OUTPUT=${2:?Usage: $0 <minecraft-version> <output>}

PROJECT="paper"
API="https://fill.papermc.io/v3/projects/${PROJECT}"
OUT_DIR="$(dirname "${OUTPUT}")"

curl -fsSL -o /dev/null "${API}/versions/${MC_VERSION}" || {
  echo "Couldn't reach ${API}/versions/${MC_VERSION}" >&2
  echo "Couldn't find Minecraft version ${MC_VERSION}" >&2
  exit 1
}

# Try channels in priority order: RECOMMENDED is what
# we want by default falling over to other channels only
# if the preferred one has nothing published yet
# within a channel take the highest build id

# NOTE: Was not tested against RECOMMENDED channel
# since paper seems to have stopped uploading
# recommended builds
BEST_BUILD=""
for CHANNEL in RECOMMENDED STABLE BETA ALPHA; do
  RESULT="$(curl -fsSL "${API}/versions/${MC_VERSION}/builds?channel=${CHANNEL}" \
    | jq -c 'if length > 0 then (sort_by(.id) | last) else empty end' 2>/dev/null || true)"

  if [ -n "${RESULT}" ] && [ "${RESULT}" != "null" ]; then
    echo "Found a ${CHANNEL} build"
    BEST_BUILD="${RESULT}"
    break
  fi

  echo "No ${CHANNEL} build available, trying next channel"
done

if [ -z "${BEST_BUILD}" ]; then
  echo "No build on any known channel, falling back to the latest build overall"
  BEST_BUILD="$(curl -fsSL "${API}/versions/${MC_VERSION}/builds/latest")" || {
    echo "No builds found for Minecraft version ${MC_VERSION}" >&2
    exit 1
  }
fi

BUILD_ID="$(echo "${BEST_BUILD}" | jq -r '.id // empty')"
if [ -z "${BUILD_ID}" ]; then
  echo "Couldn't find a build id for Minecraft ${MC_VERSION}" >&2
  exit 1
fi

echo "Using build ${BUILD_ID}"

DOWNLOAD="$(echo "${BEST_BUILD}" | jq -c '
  .downloads
  | to_entries
  | map(select(.value.name | test("\\.jar$")))
  | first
')"

DOWNLOAD_URL="$(echo "${DOWNLOAD}" | jq -r '.value.url // empty')"
FILENAME="$(echo "${DOWNLOAD}" | jq -r '.value.name // empty')"

if [ -z "${DOWNLOAD_URL}" ]; then
  echo "Couldn't find a server jar download for build ${BUILD_ID}" >&2
  exit 1
fi

echo "Downloading ${FILENAME}"
mkdir -p "${OUT_DIR}"
curl -fsSL -o "${OUTPUT}" "${DOWNLOAD_URL}"

echo -n "${BUILD_ID}" > "${OUT_DIR}/build.txt"

echo "Saved Paper ${MC_VERSION} (build ${BUILD_ID}) to ${OUTPUT}"
