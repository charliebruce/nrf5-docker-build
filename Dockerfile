FROM ubuntu:20.04
MAINTAINER Charlie Bruce <charliebruce@gmail.com>
LABEL org.opencontainers.image.source https://github.com/charliebruce/nrf5-docker-build

# tzdata presents an interactive prompt to set time zone.
ENV DEBIAN_FRONTEND=noninteractive

ARG TARGETARCH

# Download tools and prerequisites
RUN apt-get update && \
apt-get install -y curl git unzip bzip2 build-essential srecord pkg-config python libusb-1.0.0 && \
apt-get clean all 

# Download and install the toolchain
RUN echo "Host architecture: $TARGETARCH" && \
case $TARGETARCH in \
    "amd64") \
        TOOLCHAIN_URL="https://developer.arm.com/-/media/Files/downloads/gnu-rm/9-2020q2/gcc-arm-none-eabi-9-2020-q2-update-x86_64-linux.tar.bz2?revision=05382cca-1721-44e1-ae19-1e7c3dc96118&rev=05382cca172144e1ae191e7c3dc96118&hash=3ACFE672E449EBA7A21773EE284A88BC7DFA5044" \
        ;; \
    "arm64") \
        TOOLCHAIN_URL="https://developer.arm.com/-/media/Files/downloads/gnu-rm/9-2020q2/gcc-arm-none-eabi-9-2020-q2-update-aarch64-linux.tar.bz2?revision=7166404a-b4f5-4598-ac75-e5f8b90abb09&rev=7166404ab4f54598ac75e5f8b90abb09&hash=07EE5CACCCE77E97A1A8C049179D77EACA5AD4E5" \
        ;; \
    *) \
        echo "Unsupported TARGETARCH: \"$TARGETARCH\"" >&2 && \
        exit 1 ;; \
esac && \
curl -SL "${TOOLCHAIN_URL}" > /tmp/toolchain.tar.bz2 && \
tar xvjf /tmp/toolchain.tar.bz2 -C /usr/local/ && \
rm /tmp/toolchain.tar.bz2

# Download NRF5 SDK v17.1.0 and extract nRF5 SDK to /nrf5/nRF5_SDK_17.1.0
RUN curl -SL https://developer.nordicsemi.com/nRF5_SDK/nRF5_SDK_v17.x.x/nRF5_SDK_17.1.0_ddde560.zip > /tmp/SDK_17.1.0.zip && \
mkdir -p /nrf5 && \
unzip -q /tmp/SDK_17.1.0.zip -d /nrf5/ && \
mv /nrf5/nRF5_SDK_17.1.0_ddde560 /nrf5/nRF5_SDK_17.1.0 && \
rm /tmp/SDK_17.1.0.zip

# Add micro-ecc to SDK and build it
RUN curl -SL https://github.com/kmackay/micro-ecc/archive/v1.0.zip > /tmp/micro-ecc_v1.0.zip && \
unzip -q /tmp/micro-ecc_v1.0.zip -d /nrf5/nRF5_SDK_17.1.0/external/micro-ecc && \
mv /nrf5/nRF5_SDK_17.1.0/external/micro-ecc/micro-ecc-1.0 /nrf5/nRF5_SDK_17.1.0/external/micro-ecc/micro-ecc && \
make -C /nrf5/nRF5_SDK_17.1.0/external/micro-ecc/nrf51_armgcc/armgcc && \
make -C /nrf5/nRF5_SDK_17.1.0/external/micro-ecc/nrf51_iar/armgcc && \
make -C /nrf5/nRF5_SDK_17.1.0/external/micro-ecc/nrf51_keil/armgcc && \
make -C /nrf5/nRF5_SDK_17.1.0/external/micro-ecc/nrf52hf_armgcc/armgcc && \
make -C /nrf5/nRF5_SDK_17.1.0/external/micro-ecc/nrf52hf_iar/armgcc && \
make -C /nrf5/nRF5_SDK_17.1.0/external/micro-ecc/nrf52hf_keil/armgcc && \
make -C /nrf5/nRF5_SDK_17.1.0/external/micro-ecc/nrf52nf_armgcc/armgcc && \
make -C /nrf5/nRF5_SDK_17.1.0/external/micro-ecc/nrf52nf_iar/armgcc && \
make -C /nrf5/nRF5_SDK_17.1.0/external/micro-ecc/nrf52nf_keil/armgcc && \
rm /tmp/micro-ecc_v1.0.zip

# nRF Tools v6.1.1 and later require Python 3.7 or later. 
# Previous versions of the nRF Tools can't be installed because a dependency (pc_ble_driver_py) was renamed and can no longer be found.
# Ubuntu 20.04 comes with Python 3.8 (at the time of writing)
#RUN apt-get update && apt-get install -y python3 python3-pip

# Install nRF Tools (makes it easy to build a DFU package)
#RUN pip install nrfutil==6.1.3

