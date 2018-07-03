#!/usr/bin/env bash

echo "${TRAVIS_COMMIT_MESSAGE}" | grep -- --no-deploy && echo skipping deployment && exit 0

openssl aes-256-cbc -K $encrypted_93b308bc8a42_key -iv $encrypted_93b308bc8a42_iv -in environments/budgetkey/k8s-ops-secret.json.enc -out environments/budgetkey/secret-k8s-ops.json -d
K8S_ENVIRONMENT_NAME="budgetkey"
OPS_REPO_SLUG="OpenBudget/budgetkey-k8s"
OPS_REPO_BRANCH="${TRAVIS_BRANCH}"
./run_docker_ops.sh "${K8S_ENVIRONMENT_NAME}" '
    RES=0;
    curl -L https://raw.githubusercontent.com/hasadna/hasadna-k8s/master/apps_travis_script.sh | bash /dev/stdin install_helm;
    ./kubectl_patch_charts.py "'"${TRAVIS_COMMIT_MESSAGE}"'" --dry-run
    PATCH_RES=$?
    if [ "${PATCH_RES}" != "2" ]; then
        echo detected patches based on commit message
        if [ "${PATCH_RES}" == "0" ]; then
            ! ./kubectl_patch_charts.py "'"${TRAVIS_COMMIT_MESSAGE}"'" && echo failed patches && RES=1
            ! ./helm_healthcheck.sh && echo Failed healthcheck && RES=1
        else
            echo patches dry run failed && RES=1
        fi
    elif ./helm_upgrade_all.sh --install --dry-run --debug; then
        echo Dry run was successfull, performing upgrades
        ! ./helm_upgrade_all.sh --install && echo Failed upgrade && RES=1
        ! ./helm_healthcheck.sh && echo Failed healthcheck && RES=1
    else
        echo Failed dry run
        RES=1
    fi
    sleep 2;
    kubectl get pods;
    kubectl get service;
    exit $RES
' "orihoch/sk8s-ops" "${OPS_REPO_SLUG}" "${OPS_REPO_BRANCH}" "environments/budgetkey/secret-k8s-ops.json"
if [ "$?" == "0" ]; then
    echo travis deployment success
    exit 0
else
    echo travis deployment failed
    exit 1
fi
