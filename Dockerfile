FROM nvcr.io/nvidia/paddlepaddle:24.01-py3

ARG PADDLEHELIX_VERSION=dev

ENV RCSBROOT=/usr/local/maxit
ENV PATH="${RCSBROOT}/bin:${PATH}"

RUN set -eux \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
    bison \
    flex

RUN set -eux \
 && cd /usr/local \
 && curl -LR https://sw-tools.rcsb.org/apps/MAXIT/maxit-v11.200-prod-src.tar.gz | tar -zxf - \
 && ln -s maxit-v11.200-prod-src maxit \
 && cd maxit \
 && make -j1 binary \
 && chmod 644 data/*/*

RUN set -eux \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
        curl \
        aria2 \
        hmmer \
        kalign \
        hhsuite \
        openbabel

ADD https://github.com/PaddlePaddle/PaddleHelix.git#${PADDLEHELIX_VERSION} /opt/PaddleHelix

RUN set -eux \
 && cd /opt/PaddleHelix/apps/protein_folding/helixfold3 \
 && python3 -m pip install -r requirements.txt

WORKDIR /opt/PaddleHelix/apps/protein_folding/helixfold3
