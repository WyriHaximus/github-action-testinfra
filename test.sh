#!/bin/bash
#
# A simple script to start a Docker container
# and run Testinfra in it
# Original script: https://gist.github.com/renatomefi/bbf44d4e8a2614b1390416c6189fbb8e
# Original Author: @renatomefi https://github.com/renatomefi
# Current for this repository Author: @WyriHaximus https://github.com/WyriHaximus
#

set -eEuo pipefail

# The first parameter is a Docker tag or image id
declare -r DOCKER_TAG="$1"
declare -r TESTS_PATH="$2"
declare -r DOCKER_CMD="$3"
declare -r DOCKER_ADDITIONAL_FLAGS="$4"
declare -r JUNIT_PATH="$5"
declare -r TEST_SUITE="$6"
declare -r TEST_INFRA_DOCKER_IMAGE_VERSION="2025.02.06" # renovate.docker ghcr.io/wyrihaximusnet/testinfra

declare -r JUNIT_FILE="$JUNIT_PATH/$TEST_INFRA_DOCKER_IMAGE_VERSION-$(echo "$TEST_SUITE" | tr '[:upper:]' '[:lower:]' | tr " " "-").xml" # renovate.docker ghcr.io/wyrihaximusnet/testinfra

printf "Starting a container for '%s'\\n" "$DOCKER_TAG"

DOCKER_CONTAINER=$(docker run --rm -q -t -d $DOCKER_ADDITIONAL_FLAGS $(echo "$DOCKER_TAG" | tr '[:upper:]' '[:lower:]') "$DOCKER_CMD")
readonly DOCKER_CONTAINER

# Let's register a trap function, if our tests fail, finish or the script gets
# interrupted, we'll still be able to remove the running container
function tearDown {
    docker rm -f "$DOCKER_CONTAINER" &>/dev/null &
}
trap tearDown EXIT TERM ERR

docker ps

docker run --rm -t \
    -v "$TESTS_PATH:/tests" \
    -v "$JUNIT_PATH:/$JUNIT_PATH" \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    "ghcr.io/wyrihaximusnet/testinfra:$TEST_INFRA_DOCKER_IMAGE_VERSION" \
    -m "$TEST_SUITE" \
    --disable-pytest-warnings  \
    --verbose \
    --junit-xml="$JUNIT_FILE" \
    -o junit_suite_name="$TEST_SUITE" \
    --hosts="docker://$DOCKER_CONTAINER"
