FROM jenkins/ssh-agent

ENV KUBECTL_VERSION=v1.26.0
ENV QBEC_VERSION=v0.15.2

RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce docker-ce-cli

RUN usermod -aG docker jenkins

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl --output-dir /usr/local/bin && \
    chmod +x /usr/local/bin/kubectl

RUN mkdir /opt/qbec && \
    curl -SL https://github.com/splunk/qbec/releases/download/$QBEC_VERSION/qbec-linux-amd64.tar.gz | tar -zxC /opt/qbec && \
    ln -s /opt/qbec/qbec /usr/local/bin/qbec && ln -s /opt/qbec/jsonnet-qbec /usr/local/bin

RUN apt-get clean
