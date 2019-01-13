# Multistage docker build, requires docker 17.05

# builder stage
FROM nvidia/cuda:10.0-devel as builder

RUN set -ex && \
    apt-get update && \
    apt-get --no-install-recommends --yes install \
        libncurses5-dev \
        libncursesw5-dev \
        cmake \
        git \
        curl \
        libssl-dev \
        pkg-config


RUN curl https://sh.rustup.rs -sSf | sh -s -- -y

ENV PATH="/root/.cargo/bin:$PATH"
RUN USER=root cargo new --bin grin-miner

WORKDIR /grin-miner
COPY ./Cargo.lock ./Cargo.lock
COPY ./Cargo.toml.docker ./Cargo.toml
COPY ./src ./src
COPY ./util ./util
COPY ./plugin ./plugin
COPY ./config ./config
COPY ./cuckoo-miner ./cuckoo-miner
COPY ./ocl_cuckaroo ./ocl_cuckaroo
COPY ./ocl_cuckatoo ./ocl_cuckatoo
RUN git submodule update --init --recursive
RUN cargo build --release

# runtime stage
FROM nvidia/cuda:10.0-base

RUN set -ex && \
    apt-get update && \
    apt-get --no-install-recommends --yes install \
    libncurses5 \
    libncursesw5

WORKDIR /grin-miner

COPY --from=builder /grin-miner/target/release/grin-miner ./grin-miner
COPY --from=builder /grin-miner/target/release/plugins/* ./plugins/
COPY ./grin-miner.toml.template ./grin-miner.toml.template
COPY ./start.sh ./start.sh

ENTRYPOINT ["sh", "start.sh"]
