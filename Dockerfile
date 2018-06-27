FROM google/cloud-sdk:alpine

RUN apk --update --no-cache add bash jq py2-pip openssl curl && pip install --upgrade pip && pip install python-dotenv
RUN gcloud --quiet components install kubectl
RUN curl -L https://raw.githubusercontent.com/hasadna/hasadna-k8s/master/apps_travis_script.sh | bash /dev/stdin install_helm && rm ./get_helm.sh
RUN apk --update --no-cache add git && pip install pyyaml
RUN apk --update --no-cache add mysql-client

RUN mkdir /ops

WORKDIR /ops

RUN echo '[ -f /k8s-ops/secret.json ] && gcloud auth activate-service-account --key-file=/k8s-ops/secret.json' >> ~/.bashrc

COPY . /ops

ENTRYPOINT ["bash"]
