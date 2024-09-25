FROM nvcr.io/nvidia/paddlepaddle:24.01-py3
ENV MAXIT_INSTALL_DIR=/home/apps/maxit/11.200
ENV INSTALLDIR=/home/apps/
ENV HELIXFOLD3DIR=${INSTALLDIR}/PaddleHelix/apps/protein_folding/helixfold3
ENV PATH="${HELIXFOLD3DIR}/conda/condabin:${PATH}"


RUN apt-get update && apt-get install -y \
    wget \
    git \
    vim \
    sudo \
    build-essential \
    bison \
    flex

RUN wget https://sw-tools.rcsb.org/apps/MAXIT/maxit-v11.200-prod-src.tar.gz
RUN tar zxvf maxit-v11.200-prod-src.tar.gz
RUN cd maxit-v11.200-prod-src && \
  # MAXIT_INSTALL_DIRをRCSBROOTとして固定するためのハック
  sed -i -e "s|char\* rcsbroot = getenv(\"RCSBROOT\");|const char\* rcsbroot = \"$MAXIT_INSTALL_DIR\";|" maxit-v10.1/src/maxit.C  && \
  sed -i -e "s|char\* rcsbroot = getenv(\"RCSBROOT\");|const char\* rcsbroot = \"$MAXIT_INSTALL_DIR\";|" maxit-v10.1/src/process_entry.C  && \
  sed -i -e "s|char\* rcsbroot = getenv(\"RCSBROOT\");|const char\* rcsbroot = \"$MAXIT_INSTALL_DIR\";|" maxit-v10.1/src/generate_assembly_cif_file.C  && \
  # コンパイル（必ず並列数は1にする。並列コンパイルは失敗する。）
  make binary -j1 && \
  # インストール
  mkdir -p $MAXIT_INSTALL_DIR && \
  mv bin data $MAXIT_INSTALL_DIR && \
  # インストールしたユーザー以外のアカウントから使いたい場合はパーミッションを適切に設定する
  # 初期状態では他のユーザーアカウントからは実行できない
  chmod 755 $MAXIT_INSTALL_DIR/data && \
  chmod 755 $MAXIT_INSTALL_DIR/data/binary && \
  chmod 755 $MAXIT_INSTALL_DIR/data/ascii && \
  chmod 644 $MAXIT_INSTALL_DIR/data/binary/* && \
  chmod 644 $MAXIT_INSTALL_DIR/data/ascii/* && \
  wget https://files.rcsb.org/download/3QUG.pdb && \
  $MAXIT_INSTALL_DIR/bin/maxit -input 3QUG.pdb -output 3qug.cif -o 1 -log maxit.log && \
  head 3qug.cif

RUN set -eux \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
        curl \
        aria2 \
        hmmer \
        kalign \
        hhsuite \
        openbabel

RUN set -eux \
 && cd /opt \
 && curl -LR https://github.com/PaddlePaddle/PaddleHelix/archive/refs/heads/dev.tar.gz | tar -zxf - \
 && ln -s PaddleHelix-dev PaddleHelix \
 && cd PaddleHelix/apps/protein_folding/helixfold3 \
 && python3 -m pip install -r requirements.txt

WORKDIR /opt/PaddleHelix/apps/protein_folding/helixfold3
