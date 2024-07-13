ARG BASE_IMAGE=alpine:3.20

FROM ${BASE_IMAGE} AS base

ARG TARGETARCH

RUN apk -U upgrade && apk add --no-cache \
    bash \
    ca-certificates \
    curl \
    git \
    jq \
    openssh-client \
    openssh-keygen \
    python3 \
    tzdata

RUN [ -e /usr/bin/python ] || ln -s python3 /usr/bin/python

# Download infracost
ADD "https://github.com/infracost/infracost/releases/latest/download/infracost-linux-${TARGETARCH}.tar.gz" /tmp/infracost.tar.gz
RUN tar -xzf /tmp/infracost.tar.gz -C /bin && \
    mv "/bin/infracost-linux-${TARGETARCH}" /bin/infracost && \
    chmod 755 /bin/infracost && \
    rm /tmp/infracost.tar.gz

# Download Terragrunt.
ADD "https://github.com/gruntwork-io/terragrunt/releases/latest/download/terragrunt_linux_${TARGETARCH}" /bin/terragrunt
RUN chmod 755 /bin/terragrunt

# -- add -- Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/${TARGETARCH}/kubectl" \
    && mv kubectl /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl

# -- add -- Install Helm
RUN curl -LO https://get.helm.sh/helm-$(curl -s https://api.github.com/repos/helm/helm/releases/latest | jq -r .tag_name)-linux-${TARGETARCH}.tar.gz \
&& tar -zxvf helm-$(curl -s https://api.github.com/repos/helm/helm/releases/latest | jq -r .tag_name)-linux-${TARGETARCH}.tar.gz \
&& mv linux-${TARGETARCH}/helm /usr/local/bin/helm \
&& chmod +x /usr/local/bin/helm \
&& rm helm-$(curl -s https://api.github.com/repos/helm/helm/releases/latest | jq -r .tag_name)-linux-${TARGETARCH}.tar.gz

# -- add -- Install Teleport (tbot)
ARG TELEPORT_PKG=teleport
ARG BINDIR=/usr/local/bin
ARG VARDIR=/var/lib/teleport
ARG TELEPORT_VERSION=16.0.4

RUN TELEPORT_VERSION=$(curl -sL https://api.github.com/repos/gravitational/teleport/releases/latest | jq -r '.tag_name' | cut -c 2-)
RUN curl -O https://cdn.teleport.dev/${TELEPORT_PKG}-v${TELEPORT_VERSION}-linux-${TARGETARCH}-bin.tar.gz
RUN tar -xvf ${TELEPORT_PKG}-v${TELEPORT_VERSION}-linux-${TARGETARCH}-bin.tar.gz
RUN mkdir -p $VARDIR $BINDIR
RUN cp -f ${TELEPORT_PKG}/tbot $BINDIR/ || exit 1
RUN rm ${TELEPORT_PKG}-v${TELEPORT_VERSION}-linux-${TARGETARCH}-bin.tar.gz
RUN rm -rf ${TELEPORT_PKG}

RUN echo "hosts: files dns" > /etc/nsswitch.conf \
    && adduser --disabled-password --uid=1983 spacelift

FROM base AS aws

COPY --from=ghcr.io/spacelift-io/aws-cli-alpine /usr/local/aws-cli/ /usr/local/aws-cli/
COPY --from=ghcr.io/spacelift-io/aws-cli-alpine /aws-cli-bin/ /usr/local/bin/

RUN aws --version && \
    terragrunt --version && \
    python --version && \
    infracost --version && \
    kubectl version --client=true && \
    tbot version

USER spacelift

FROM base AS gcp

RUN gcloud components install gke-gcloud-auth-plugin

RUN gcloud --version && \
    terragrunt --version && \
    python --version && \
    infracost --version && \
    kubectl version --client=true && \
    tbot version

USER spacelift

FROM base AS azure

RUN az aks install-cli
# "/tmp/tmp0tiux2zq/kubelogin.zip" from "https://github.com/Azure/kubelogin/releases/download/v0.1.4/kubelogin.zip"
# RUN curl -LO "https://github.com/Azure/kubelogin/releases/download/$(curl -sL https://api.github.com/repos/Azure/kubelogin/releases/latest | jq -r .tag_name)/kubelogin.zip" \
#     && unzip kubelogin.zip \
#     && mv bin/linux_${TARGETARCH}/kubelogin /bin/kubelogin \
#     && chmod +x /bin/kubelogin \
#     && rm kubelogin.zip

RUN az --version && \
    terragrunt --version && \
    python --version && \
    infracost --version && \
    kubectl version --client=true && \
    helm version && \
    tbot version

USER spacelift