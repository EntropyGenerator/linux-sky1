# linux-sky1

Linux kernel patches and configuration for CIX Sky1 SoC (Radxa Orion O6 and compatible boards).

## Overview

This repository contains the Sky1 kernel patch set:
- **61 patches** on top of Linux 6.18.x for CIX Sky1 SoC support
- **Kernel configuration** for arm64

## Repository Structure

```
linux-sky1/
├── patches/           # Git-formatted kernel patches
│   ├── 0001-*.patch
│   └── ...
├── config/
│   ├── config.sky1    # Production kernel config
│   └── README.md      # Config documentation
└── CHANGELOG.md       # Patch set version history
```

## Supported Hardware

- **SoC**: CIX CD8180 (Sky1)
- **Board**: Radxa Orion O6
- **GPU**: Mali-G720-Immortalis (via Panthor driver)
- **Display**: DisplayPort via linlon-dp/trilin-dpsub

## Using These Patches

### Apply to Kernel Source

```bash
# Download kernel
wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.18.2.tar.xz
tar xf linux-6.18.2.tar.xz
cd linux-6.18.2

# Apply patches
for p in /path/to/linux-sky1/patches/*.patch; do
    patch -p1 < "$p"
done

# Use config
cp /path/to/linux-sky1/config/config.sky1 .config
make ARCH=arm64 olddefconfig
```

### Build Kernel

```bash
make ARCH=arm64 -j$(nproc) Image modules dtbs
```

## Patch Categories

| Category | Patches | Description |
|----------|---------|-------------|
| Platform | 0001-0002 | DTS, SCMI, mailbox |
| PCIe | 0003-0011, 0054, 0061 | Cadence controller, ATU, MSI quirks, hotplug, I/O windows |
| Display | 0012-0013 | linlon-dp, trilin-dpsub, USBDP PHYs |
| USB | 0014-0017 | CDNSP, RTS5453 Type-C PD |
| GPU | 0018-0021, 0043, 0051-0053 | Panthor Sky1 support |
| Audio | 0022-0040 | HDA, DMA-350, DSP |
| Misc | 0041-0042, 0044-0050, 0055-0060 | PDC, hwspinlock, eFuse, SoC info, cpufreq, SMMU, SPE, DTS |

## Installing Pre-built Packages

Pre-built kernel packages are available from the Sky1 Linux apt repository:

```bash
# Add repository key
wget -qO- https://sky1-linux.github.io/apt/key.gpg | sudo tee /usr/share/keyrings/sky1-linux.asc > /dev/null

# Add repository
echo "deb [signed-by=/usr/share/keyrings/sky1-linux.asc] https://sky1-linux.github.io/apt sid main" | \
    sudo tee /etc/apt/sources.list.d/sky1-linux.list

# Install kernel
sudo apt update
sudo apt install linux-image-6.18.2-sky1 linux-headers-6.18.2-sky1 sky1-firmware
```

## Documentation

- [Kernel Configuration Guide](config/README.md) - Essential vs optional configs for Sky1

## Related Repositories

- [sky1-linux-build](https://github.com/Sky1-Linux/sky1-linux-build) - Build tooling for kernel packages
- [apt](https://github.com/Sky1-Linux/apt) - APT repository
- [sky1-firmware](https://github.com/Sky1-Linux/sky1-firmware) - Firmware packages
- [sky1-drivers-dkms](https://github.com/Sky1-Linux/sky1-drivers-dkms) - DKMS drivers (VPU, NPU, 5GbE)

## License

- Kernel patches: GPL-2.0 (same as Linux kernel)
