FROM alpine@sha256:b276d875eeed9c7d3f1cfa7edb06b22ed22b14219a7d67c52c56612330348239

RUN apk --update --no-cache add bash jq py2-pip openssl curl git docker \
    && pip install --upgrade pip \
    && pip install python-dotenv[cli] pyyaml

RUN wget https://releases.rancher.com/cli2/v2.3.2/rancher-linux-amd64-v2.3.2.tar.gz &&\
    tar -xzvf rancher-linux-amd64-v2.3.2.tar.gz &&\
    mv ./rancher-v2.3.2/rancher /usr/local/bin/ &&\
    rm -rf ./rancher-v2.3.2 rancher-linux-amd64-v2.3.2.tar.gz

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl &&\
    chmod +x ./kubectl &&\
    mv ./kubectl /usr/local/bin/

RUN apk --update --no-cache add sudo && echo "Set disable_coredump false" >> /etc/sudo.conf

RUN echo 'rancher login --token $RANCHER_TOKEN $RANCHER_ENDPOINT --context c-vrqxr:p-wk9df' >> ~/.bashrc
RUN echo 'rancher kubectl config view --raw | grep -v certificate-authority-data: > /.kubeconfig' >> ~/.bashrc
RUN echo 'export KUBECONFIG=/.kubeconfig' >> ~/.bashrc
RUN echo 'kubectl config set-context --current --namespace=oknesset' >> ~/.bashrc
RUN echo '[ "${OPS_REPO_SLUG}" != "" ] && ! [ -d /ops ] && git clone --depth 1 --branch ${OPS_REPO_BRANCH:-master} https://github.com/${OPS_REPO_SLUG}.git /ops' >> ~/.bashrc
RUN echo '[ -d /ops ] && cd /ops' >> ~/.bashrc

ENTRYPOINT ["bash"]