FROM nvidia/cuda:12.2.2-runtime-ubuntu22.04
ENV MAXIT_INSTALL_DIR=/home/apps/maxit/11.200
ENV INSTALLDIR=/home/apps/
ENV HELIXFOLD3DIR=${INSTALLDIR}/PaddleHelix/apps/protein_folding/helixfold3

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

RUN mkdir -p ${INSTALLDIR} && \
  cd ${INSTALLDIR} && \
  git clone https://github.com/PaddlePaddle/PaddleHelix.git && \
  cd ${HELIXFOLD3DIR} && \
  wget -q -P . https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
  bash ./Miniconda3-latest-Linux-x86_64.sh -b -p ${HELIXFOLD3DIR}/conda && \
  rm Miniconda3-latest-Linux-x86_64.sh && \
  . "${HELIXFOLD3DIR}/conda/etc/profile.d/conda.sh"

WORKDIR /opt
