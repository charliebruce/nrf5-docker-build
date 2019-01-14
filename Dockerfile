FROM ubuntu:16.04
MAINTAINER Charlie Bruce <charliebruce@gmail.com>

# Download tools and prerequisites
RUN apt-key update && \
apt-get update && \
apt-get install -y curl git unzip bzip2 build-essential gcc-multilib srecord pkg-config python && \
apt-get clean all

# Download and install ARM toolchain matching the SDK
RUN curl -SL https://launchpad.net/gcc-arm-embedded/4.9/4.9-2015-q3-update/+download/gcc-arm-none-eabi-4_9-2015q3-20150921-linux.tar.bz2 > /tmp/gcc-arm-none-eabi-4_9-2015q3-20150921-linux.tar.bz2 && \
tar xvjf /tmp/gcc-arm-none-eabi-4_9-2015q3-20150921-linux.tar.bz2 -C /usr/local/ && \
rm /tmp/gcc-arm-none-eabi-4_9-2015q3-20150921-linux.tar.bz2

# Download NRF5 SDK v14.2.0 and extract nRF5 SDK to /nrf5/nRF5_SDK_14.2.0
RUN curl -SL https://developer.nordicsemi.com/nRF5_SDK/nRF5_SDK_v14.x.x/nRF5_SDK_14.2.0_17b948a.zip > /tmp/SDK_14.2.0.zip && \
mkdir -p /nrf5 && \
unzip -q /tmp/SDK_14.2.0.zip -d /nrf5 && \
mv /nrf5/nRF5_SDK_14.2.0_17b948a /nrf5/nRF5_SDK_14.2.0 && \
rm /tmp/SDK_14.2.0.zip

# Add micro-ecc to SDK
RUN curl -SL https://github.com/kmackay/micro-ecc/archive/v1.0.zip > /tmp/micro-ecc_v1.0.zip && \
unzip -q /tmp/micro-ecc_v1.0.zip -d /nrf5/nRF5_SDK_14.2.0/external/micro-ecc && \
mv /nrf5/nRF5_SDK_14.2.0/external/micro-ecc/micro-ecc-1.0 /nrf5/nRF5_SDK_14.2.0/external/micro-ecc/micro-ecc && \
make -C /nrf5/nRF5_SDK_14.2.0/external/micro-ecc/nrf52hf_armgcc/armgcc && \
rm /tmp/micro-ecc_v1.0.zip

# Install nRF Tools (makes it easy to build a DFU package)
RUN apt-get install -y python-pip && \
pip install nrfutil

