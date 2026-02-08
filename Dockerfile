# Single Stage Image Build for "firmware-mod-kit" 
FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Los_Angeles

RUN apt-get update && apt-get install -y git \
                build-essential \
                liblzo2-dev \
                lzop \
                zlib1g-dev \
                liblzma-dev \
                python3-dev \
                python3-pip \
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
                && rm -rf /var/lib/apt/lists/*

COPY requirements.txt ./

RUN pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip install --no-cache-dir -r requirements.txt 

WORKDIR /home

RUN git clone https://github.com/rampageX/firmware-mod-kit.git .

WORKDIR src

RUN make

CMD ["/bin/bash"]
