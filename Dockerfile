FROM ubuntu:18.04
MAINTAINER Charlie Bruce <charliebruce@gmail.com>
LABEL org.opencontainers.image.source https://github.com/charliebruce/nrf5-docker-build

# Download tools and prerequisites
RUN apt-get update && \
apt-get install -y curl git unzip bzip2 build-essential gcc-multilib srecord pkg-config python libusb-1.0.0 && \
apt-get clean all 

# Download and install ARM toolchain matching the SDK
RUN curl -SL https://armkeil.blob.core.windows.net/developer/Files/downloads/gnu-rm/9-2019q4/gcc-arm-none-eabi-9-2019-q4-major-x86_64-linux.tar.bz2 > /tmp/gcc-arm-none-eabi-9-2019-q4-major-linux.tar.bz2 && \
tar xvjf /tmp/gcc-arm-none-eabi-9-2019-q4-major-linux.tar.bz2 -C /usr/local/ && \
rm /tmp/gcc-arm-none-eabi-9-2019-q4-major-linux.tar.bz2

# Download NRF5 SDK v17.0.2 and extract nRF5 SDK to /nrf5/nRF5_SDK_17.0.2
RUN curl -SL https://developer.nordicsemi.com/nRF5_SDK/nRF5_SDK_v17.x.x/nRF5_SDK_17.0.2_d674dde.zip > /tmp/SDK_17.0.2.zip && \
mkdir -p /nrf5 && \
unzip -q /tmp/SDK_17.0.2.zip -d /nrf5/ && \
mv /nrf5/nRF5_SDK_17.0.2_d674dde /nrf5/nRF5_SDK_17.0.2 && \
rm /tmp/SDK_17.0.2.zip

# Patch around what is likely to be an oversight in Nordic's SDK
# https://devzone.nordicsemi.com/f/nordic-q-a/68352/gcc-toolchain-version-for-sdk-17-0-2-on-posix
RUN \
echo "GNU_INSTALL_ROOT ?= /usr/local/gcc-arm-none-eabi-9-2019-q4-major/bin/" > /nrf5/nRF5_SDK_17.0.2/components/toolchain/gcc/Makefile.posix && \
echo "GNU_VERSION ?= 9.2.1" >> /nrf5/nRF5_SDK_17.0.2/components/toolchain/gcc/Makefile.posix && \
echo "GNU_PREFIX ?= arm-none-eabi" >> /nrf5/nRF5_SDK_17.0.2/components/toolchain/gcc/Makefile.posix

# Add micro-ecc to SDK and build it
RUN curl -SL https://github.com/kmackay/micro-ecc/archive/v1.0.zip > /tmp/micro-ecc_v1.0.zip && \
unzip -q /tmp/micro-ecc_v1.0.zip -d /nrf5/nRF5_SDK_17.0.2/external/micro-ecc && \
mv /nrf5/nRF5_SDK_17.0.2/external/micro-ecc/micro-ecc-1.0 /nrf5/nRF5_SDK_17.0.2/external/micro-ecc/micro-ecc && \
make -C /nrf5/nRF5_SDK_17.0.2/external/micro-ecc/nrf51_armgcc/armgcc && \
make -C /nrf5/nRF5_SDK_17.0.2/external/micro-ecc/nrf51_iar/armgcc && \
make -C /nrf5/nRF5_SDK_17.0.2/external/micro-ecc/nrf51_keil/armgcc && \
make -C /nrf5/nRF5_SDK_17.0.2/external/micro-ecc/nrf52hf_armgcc/armgcc && \
make -C /nrf5/nRF5_SDK_17.0.2/external/micro-ecc/nrf52hf_iar/armgcc && \
make -C /nrf5/nRF5_SDK_17.0.2/external/micro-ecc/nrf52hf_keil/armgcc && \
make -C /nrf5/nRF5_SDK_17.0.2/external/micro-ecc/nrf52nf_armgcc/armgcc && \
make -C /nrf5/nRF5_SDK_17.0.2/external/micro-ecc/nrf52nf_iar/armgcc && \
make -C /nrf5/nRF5_SDK_17.0.2/external/micro-ecc/nrf52nf_keil/armgcc && \
rm /tmp/micro-ecc_v1.0.zip

# Install nRF Tools (makes it easy to build a DFU package)
RUN apt-get install -y python-pip && \
pip install nrfutil

