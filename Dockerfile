FROM ubuntu:latest
ARG S6_VERSION=v2.2.0.3
ARG S6_ARCH=amd64
ARG DEBIAN_FRONTEND=noninteractive
ARG USER_NAME=pagermaid
ARG WORK_DIR=/pagermaid/workdir
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    SHELL=/bin/bash \
    LANG=zh_CN.UTF-8 \
    PS1="\u@\h:\w \$ " \
    RUN_AS_ROOT=true
SHELL ["/bin/bash", "-c"]
WORKDIR $WORK_DIR
RUN source ~/.bashrc \
    ## 安装运行环境依赖
    && apt-get update \
    && apt-get upgrade -y \
    #&& apt install software-properties-common -y \
    #&& apt-add-repository ppa:deadsnakes/ppa -y \
    && apt-get install --no-install-recommends -y \
        python3 \
        python3-pip \
        tesseract-ocr \
        tesseract-ocr-eng \
        tesseract-ocr-chi-sim \
        language-pack-zh-hans \
        sudo \
        git \
        openssl \
        ## 权限原因不支持 redis 数据库
        redis-server \
        curl \
        wget \
        neofetch \
        imagemagick \
        ffmpeg \
        fortune-mod \
        figlet \
        libmagic1 \
        libzbar0 \
        iputils-ping \
    ## 安装s6
    && curl -L -o /tmp/s6-overlay-installer https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/s6-overlay-${S6_ARCH}-installer \
    && chmod +x /tmp/s6-overlay-installer \
    && /tmp/s6-overlay-installer / \
    ## 安装编译依赖
    && apt-get update \
    && apt-get install --no-install-recommends -y \
        build-essential \
        apt-utils \
        python3-dev \
        libxslt1-dev \
        libxml2-dev \
        libssl-dev \
        libffi-dev \
        zlib1g-dev \
        tcl8.6-dev \
        tk8.6-dev \
        libimagequant-dev \
        libraqm-dev \
        libjpeg-dev \
        libtiff5-dev \
        libopenjp2-7-dev \
        libfreetype6-dev \
        liblcms2-dev \
        libwebp-dev \
        python3-tk \
        libharfbuzz-dev \
        libfribidi-dev \
        libxcb1-dev \
        pkg-config \
    ## 设置时区
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    ## python软链接
    && ln -sf /usr/bin/python3 /usr/bin/python \
    ## 升级pip
    && python -m pip install --upgrade pip \
    ## 添加用户
    && useradd $USER_NAME -u 917 -U -r -m -d /$USER_NAME -s /bin/bash \
    && usermod -aG sudo,users $USER_NAME \
    && echo "$USER_NAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USER_NAME \
    ## 克隆仓库
    && git clone -b master https://gitlab.com/Xtao-Labs/pagermaid-modify.git $WORK_DIR \
    && git config --global pull.ff only \
    ## 复制s6启动脚本（权限原因不使用s6，使用heroku.yml中的run运行）
    # && cp -r s6/* / \
    ## pip install
    && pip install -r requirements.txt
## 添加 workdir
ADD workdir $WORK_DIR
## pip install 插件
RUN pip install -r plugins/requirements.txt
ENTRYPOINT ["/init"]
