# linux-sky1

Linux kernel packages for CIX Sky1 SoC (Radxa Orion O6 and compatible boards).

## Overview

This repository contains:
- 55 patches on top of Linux 6.18.1 LTS for CIX Sky1 SoC support
- Debian packaging to build kernel .deb packages
- Kernel configuration for arm64

## Supported Hardware

- **SoC**: CIX CD8180 (Sky1)
- **Board**: Radxa Orion O6
- **GPU**: Mali-G720-Immortalis (via Panthor driver)
- **Display**: DisplayPort via linlon-dp/trilin-dpsub

## Packages

| Package | Description |
|---------|-------------|
| `linux-image-6.18-sky1` | Kernel image and modules |
| `linux-headers-6.18-sky1` | Headers for DKMS module builds |
| `linux-dtbs-6.18-sky1` | Device tree blobs |

## Building

### Prerequisites

```bash
sudo apt install build-essential bc bison flex libelf-dev libssl-dev
```

### Build Packages

```bash
# Download kernel source
wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.18.1.tar.xz

# Build
dpkg-buildpackage -us -uc -b
```

### Quick Local Build (without packaging)

```bash
# Clone with patches applied
git clone --depth=1 https://github.com/sky1-linux/linux-sky1.git
cd linux-sky1

# Extract and patch
tar xf linux-6.18.1.tar.xz
cd linux-6.18.1
for p in ../debian/patches/*.patch; do patch -p1 < "$p"; done
cp ../debian/config/arm64/config .config

# Build
make ARCH=arm64 olddefconfig
make ARCH=arm64 -j$(nproc) Image modules dtbs
```

## Patch Categories

| Category | Patches | Description |
|----------|---------|-------------|
| Platform | 0001-0002 | DTS, SCMI, mailbox |
| PCIe | 0003-0011, 0054 | Cadence controller, ATU, MSI quirks, hotplug |
| Display | 0012-0013 | linlon-dp, trilin-dpsub, USBDP PHYs |
| USB | 0014-0017 | CDNSP, RTS5453 Type-C PD |
| GPU | 0018-0021, 0043, 0051-0053 | Panthor Sky1 support |
| Audio | 0022-0040 | HDA, DMA-350, DSP |
| Misc | 0041-0042, 0044-0050, 0055 | PDC, hwspinlock, eFuse, SoC info, WiFi |

## Installation

```bash
# Add repository key
wget -qO- https://sky1-linux.github.io/apt/key.gpg | sudo tee /usr/share/keyrings/sky1-linux.asc > /dev/null

# Add repository
echo "deb [signed-by=/usr/share/keyrings/sky1-linux.asc] https://sky1-linux.github.io/apt sid main non-free-firmware" | sudo tee /etc/apt/sources.list.d/sky1-linux.list

# Install
sudo apt update
sudo apt install linux-image-6.18-sky1 linux-headers-6.18-sky1 sky1-firmware
```

## License

- Kernel patches: GPL-2.0 (same as Linux kernel)
- Packaging: GPL-2.0

## Links

- [APT Repository](https://github.com/Sky1-Linux/apt)
- [Issue Tracker](https://github.com/Sky1-Linux/linux-sky1/issues)
