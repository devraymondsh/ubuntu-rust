# syntax=docker/dockerfile:1
FROM ubuntu:focal

ENV CARGO_HOME=/usr/local/cargo
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH=/usr/local/cargo/bin:$PATH
ENV RUSTUP_HOME=/usr/local/rustup

WORKDIR /.installer
ADD ./install.sh ./install.sh
RUN chmod +x ./install.sh && ./install.sh
WORKDIR /
