FROM ubuntu:18.04
MAINTAINER Charlie Bruce <charliebruce@gmail.com>

# Download tools and prerequisites
RUN apt-get update && \
apt-get install -y curl git unzip bzip2 build-essential gcc-multilib srecord pkg-config python libusb-1.0.0 && \
apt-get clean all 

# Download and install ARM toolchain matching the SDK
RUN curl -SL https://developer.arm.com/-/media/Files/downloads/gnu-rm/7-2018q2/gcc-arm-none-eabi-7-2018-q2-update-linux.tar.bz2?revision=bc2c96c0-14b5-4bb4-9f18-bceb4050fee7?product=GNU%20Arm%20Embedded%20Toolchain,64-bit,,Linux,7-2018-q2-update > /tmp/gcc-arm-none-eabi-7-2018-q2-update-linux.tar.bz2 && \
tar xvjf /tmp/gcc-arm-none-eabi-7-2018-q2-update-linux.tar.bz2 -C /usr/local/ && \
rm /tmp/gcc-arm-none-eabi-7-2018-q2-update-linux.tar.bz2

# Download NRF5 SDK v17.0.0 and extract nRF5 SDK to /nrf5/nRF5_SDK_17.0.0
RUN curl -SL https://developer.nordicsemi.com/nRF5_SDK/nRF5_SDK_v17.x.x/nRF5_SDK_17.0.0_9d13099.zip > /tmp/SDK_17.0.0.zip && \
mkdir -p /nrf5 && \
unzip -q /tmp/SDK_17.0.0.zip -d /nrf5/ && \
mv /nrf5/nRF5_SDK_17.0.0_9d13099 /nrf5/nRF5_SDK_17.0.0 && \
rm /tmp/SDK_17.0.0.zip

# Add micro-ecc to SDK and build it
RUN curl -SL https://github.com/kmackay/micro-ecc/archive/v1.0.zip > /tmp/micro-ecc_v1.0.zip && \
unzip -q /tmp/micro-ecc_v1.0.zip -d /nrf5/nRF5_SDK_17.0.0/external/micro-ecc && \
mv /nrf5/nRF5_SDK_17.0.0/external/micro-ecc/micro-ecc-1.0 /nrf5/nRF5_SDK_17.0.0/external/micro-ecc/micro-ecc && \
make -C /nrf5/nRF5_SDK_17.0.0/external/micro-ecc/nrf51_armgcc/armgcc && \
make -C /nrf5/nRF5_SDK_17.0.0/external/micro-ecc/nrf51_iar/armgcc && \
make -C /nrf5/nRF5_SDK_17.0.0/external/micro-ecc/nrf51_keil/armgcc && \
make -C /nrf5/nRF5_SDK_17.0.0/external/micro-ecc/nrf52hf_armgcc/armgcc && \
make -C /nrf5/nRF5_SDK_17.0.0/external/micro-ecc/nrf52hf_iar/armgcc && \
make -C /nrf5/nRF5_SDK_17.0.0/external/micro-ecc/nrf52hf_keil/armgcc && \
make -C /nrf5/nRF5_SDK_17.0.0/external/micro-ecc/nrf52nf_armgcc/armgcc && \
make -C /nrf5/nRF5_SDK_17.0.0/external/micro-ecc/nrf52nf_iar/armgcc && \
make -C /nrf5/nRF5_SDK_17.0.0/external/micro-ecc/nrf52nf_keil/armgcc && \
rm /tmp/micro-ecc_v1.0.zip

# Install nRF Tools (makes it easy to build a DFU package)
RUN apt-get install -y python-pip && \
pip install nrfutil

