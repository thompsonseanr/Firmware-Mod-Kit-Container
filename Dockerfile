# Single Stage Image Build for "firmware-mod-kit" 
FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Los_Angeles

RUN apt-get update && apt-get install -y git \
                build-essential \
                zlib1g-dev \
                liblzma-dev \
                python3-magic \
                autoconf \
                python-is-python3 \
                zip \
                unzip \
                vim \
                binwalk \
                lzop \
                cramfsswap \
                tree \
                squashfs-tools \
                && rm -rf /var/lib/apt/lists/*

WORKDIR /home

RUN git clone https://github.com/rampageX/firmware-mod-kit.git .

WORKDIR src

RUN make

CMD ["/bin/bash"]
