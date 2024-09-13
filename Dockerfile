FROM nvidia/cuda:12.2.2-runtime-ubuntu22.04
ENV MAXIT_INSTALL_DIR=/home/apps/maxit/11.200
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
RUN cd maxit-v11.200-prod-src
# MAXIT_INSTALL_DIRをRCSBROOTとして固定するためのハック
RUN sed -i -e "s|char\* rcsbroot = getenv(\"RCSBROOT\");|const char\* rcsbroot = \"$MAXIT_INSTALL_DIR\";|" maxit-v10.1/src/maxit.C
RUN sed -i -e "s|char\* rcsbroot = getenv(\"RCSBROOT\");|const char\* rcsbroot = \"$MAXIT_INSTALL_DIR\";|" maxit-v10.1/src/process_entry.C
RUN sed -i -e "s|char\* rcsbroot = getenv(\"RCSBROOT\");|const char\* rcsbroot = \"$MAXIT_INSTALL_DIR\";|" maxit-v10.1/src/generate_assembly_cif_file.C
# コンパイル（必ず並列数は1にする。並列コンパイルは失敗する。）
RUN make binary -j1
# インストール
RUN mkdir -p $MAXIT_INSTALL_DIR
RUN mv bin data $MAXIT_INSTALL_DIR
# インストールしたユーザー以外のアカウントから使いたい場合はパーミッションを適切に設定する
# 初期状態では他のユーザーアカウントからは実行できない
RUN chmod 755 $MAXIT_INSTALL_DIR/data
RUN chmod 755 $MAXIT_INSTALL_DIR/data/binary
RUN chmod 755 $MAXIT_INSTALL_DIR/data/ascii
RUN chmod 644 $MAXIT_INSTALL_DIR/data/binary/*
RUN chmod 644 $MAXIT_INSTALL_DIR/data/ascii/*
RUN wget https://files.rcsb.org/download/3QUG.pdb
RUN $MAXIT_INSTALL_DIR/bin/maxit -input 3QUG.pdb -output 3qug.cif -o 1 -log maxit.log
RUN head 3qug.cif

WORKDIR /opt
