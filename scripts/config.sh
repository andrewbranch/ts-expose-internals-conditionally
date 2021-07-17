set -e

# #################################################################################################################### #
# Vars
# #################################################################################################################### #

SCRIPT=$(readlink -f "$0")
SCRIPT_PATH=$(dirname "$SCRIPT")
ROOT_PATH=$(cd "$SCRIPT_PATH/.."; pwd)


# #################################################################################################################### #
# Config
# #################################################################################################################### #

OUT_DIR="${ROOT_PATH}/out"

# Minimum git version 3.8
GIT_TAG_REGEX='^v([3]\\.[8-9]|[4-9]\\.|\\d{2,}).+$'

# Skip version tags (these won't compile)
SKIP_VERSIONS="v3.9-beta v3.9-rc v3.9.2 v3.9.3 v3.9.5 v3.9.8 v3.9.9 v3.9.10 v4.0.8 v4.1.6 v4.3.3 v4.3.4 v4.3.5"


# #################################################################################################################### #
# Exports
# #################################################################################################################### #

export SCRIPT_PATH
export ROOT_PATH
export OUT_DIR
export GIT_TAG_REGEX
export SKIP_VERSIONS
