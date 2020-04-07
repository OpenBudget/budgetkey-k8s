#!/usr/bin/env bash

usage() {
    echo "Usage: ./run_docker_ops.sh <ENVIRONMENT_NAME> [SCRIPT:bash] [OPS_DOCKER_IMAGE:orihoch/sk8s-ops] <OPS_REPO_SLUG> <OPS_REPO_BRANCH:master> <RANCHER_ENDPOINT> <RANCHER_TOKEN> [DOCKER_RUN_PARAMS]"
}

ENVIRONMENT_NAME="${1}"
SCRIPT="${2}"
OPS_DOCKER_IMAGE="${3}"
OPS_REPO_SLUG="${4}"
OPS_REPO_BRANCH="${5}"
RANCHER_ENDPOINT="${6}"
RANCHER_TOKEN="${7}"
DOCKER_RUN_PARAMS="${8}"

echo "ENVIRONMENT_NAME=${ENVIRONMENT_NAME}"
echo "OPS_DOCKER_IMAGE=${OPS_DOCKER_IMAGE}"
echo "OPS_REPO_SLUG=${OPS_REPO_SLUG}"
echo "OPS_REPO_BRANCH=${OPS_REPO_BRANCH}"
echo "DOCKER_RUN_PARAMS=${DOCKER_RUN_PARAMS}"

[ -z "${ENVIRONMENT_NAME}" ] && usage && exit 1
[ -z "${OPS_REPO_SLUG}" ] && usage && exit 1
[ -z "${RANCHER_ENDPOINT}" ] && usage && exit 1
[ -z "${RANCHER_TOKEN}" ] && usage && exit 1

[ -z "${SCRIPT}" ] && SCRIPT="bash"
[ -z "${OPS_DOCKER_IMAGE}" ] && OPS_DOCKER_IMAGE="orihoch/budgetkey-sk8s-ops-kamatera@sha256:a1ecdb2779c1bfc211b8442d497abd53de869d4af640a5f478951040e756ae72" \
                             && echo "OPS_DOCKER_IMAGE=${OPS_DOCKER_IMAGE}"
[ -z "${OPS_REPO_BRANCH}" ] && OPS_REPO_BRANCH="master" \
                            && echo "OPS_REPO_BRANCH=${OPS_REPO_BRANCH}"

! docker run -it -e "OPS_REPO_SLUG=${OPS_REPO_SLUG}" \
                 -e "OPS_REPO_BRANCH=${OPS_REPO_BRANCH}" \
                 -e "RANCHER_TOKEN=${RANCHER_TOKEN}" \
                 -e "RANCHER_ENDPOINT=${RANCHER_ENDPOINT}" \
                 $DOCKER_RUN_PARAMS \
                 "${OPS_DOCKER_IMAGE}" \
                 -c "source ~/.bashrc && source switch_environment.sh ${ENVIRONMENT_NAME}; ${SCRIPT}" \
    && echo "failed to run SCRIPT" && exit 1

echo "Great Success!"
exit 0
