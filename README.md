# linux-sky1

Linux kernel patches and configuration for CIX Sky1 SoC (Radxa Orion O6 and compatible boards).

## Overview

This repository contains the Sky1 kernel patch set and configuration for 4 kernel tracks:

| Track | Patches | Config | Base | APT Component |
|-------|---------|--------|------|---------------|
| LTS | `patches/` | `config.sky1` | v6.18.x | `main` |
| Latest | `patches-latest/` | `config.sky1-latest` | v6.19.x | `latest` |
| RC | `patches-rc/` | `config.sky1-rc` | v6.X-rcN | `rc` |
| Next | `patches-next/` | `config.sky1-next` | origin/master | `next` |

## Repository Structure

```
linux-sky1/
├── patches/                    # LTS track (6.18.x)
│   ├── 0001-*.patch
│   └── ...
├── patches-latest/             # Latest stable track (6.19.x)
├── patches-rc/                 # RC track (pre-release)
├── patches-next/               # Next track (origin/master)
├── config/
│   ├── config.sky1             # LTS config
│   ├── config.sky1-latest      # Latest config
│   ├── config.sky1-rc          # RC config
│   ├── config.sky1-next        # Next config
│   ├── diff-kernel-config.sh   # Config comparison tool
│   └── README.md               # Config documentation
└── CHANGELOG.md                # Patch set version history
```

## Supported Hardware

- **SoC**: CIX CD8180 (Sky1)
- **Boards**: Radxa Orion O6, Radxa Orion O6N (micro-ITX)
- **GPU**: Mali-G720-Immortalis (via Panthor driver)
- **Display**: DisplayPort via linlon-dp/trilin-dpsub

## Using These Patches

### Apply to Kernel Source

```bash
# Download kernel
wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.18.9.tar.xz
tar xf linux-6.18.9.tar.xz
cd linux-6.18.9

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

| # | Patch | Description |
|---|-------|-------------|
| 01 | arm64: dts: cix | Sky1 SoC and Radxa Orion O6/O6N device trees |
| 02 | pci: cadence | PCIe host controller, ATU, MSI, hotplug, I/O windows |
| 03 | arm64: cix: infrastructure | SCMI, mailbox, pinctrl, clock, reset, hwspinlock, eFuse, SoC info |
| 04 | usb: phy | CDNSP, RTS5453 Type-C PD, USBDP PHYs |
| 05 | drm: cix: display | linlon-dp, trilin-dpsub display drivers |
| 06 | drm/panthor | GPU support for Mali-G720-Immortalis |
| 07 | sound: audio | HDA, DMA-350, DSP drivers |
| 08 | net | Realtek RTL8126 5GbE and RTL8125 2.5GbE drivers |
| 09 | misc: armchina-npu | Zhouyi NPU driver |
| 10 | media: cix: vpu | Video codec (amvx) driver |
| 11 | irqchip, iommu, perf | PDC, SMMU boot-active streams, ARM SPE heterogeneous CPU |
| 12 | arm64: cix: misc | Thermal, PWM, watchdog, DDR LP, bus DVFS, CPU IPA, cpufreq |
| 13 | scripts | Sky1 kernel development tools |

## Installing Pre-built Packages

Pre-built kernel packages are available from the Sky1 Linux apt repository:

```bash
# Add repository key
wget -qO- https://sky1-linux.github.io/apt/key.gpg | sudo tee /usr/share/keyrings/sky1-linux.asc > /dev/null

# Add repository (LTS only — default)
echo "deb [signed-by=/usr/share/keyrings/sky1-linux.asc] https://sky1-linux.github.io/apt sid main" | \
    sudo tee /etc/apt/sources.list.d/sky1-linux.list

# Or add additional tracks:
#   sid main latest          — LTS + Latest stable
#   sid main latest rc       — LTS + Latest + RC testing
#   sid main latest rc next  — All tracks (bleeding edge)

# Install kernel
sudo apt update
sudo apt install linux-image-sky1 sky1-firmware
```

## Verifying Your Config

If you're building a custom kernel, verify your config has all required options:

```bash
curl -fsSL https://raw.githubusercontent.com/Sky1-Linux/linux-sky1/main/config/diff-kernel-config.sh | bash
```

This checks for missing required options and shows differences from the Sky1 default.

## Documentation

- [Kernel Configuration Guide](config/README.md) - Essential vs optional configs for Sky1

## Related Repositories

- [sky1-linux-build](https://github.com/Sky1-Linux/sky1-linux-build) - Build tooling for kernel packages
- [apt](https://github.com/Sky1-Linux/apt) - APT repository
- [sky1-firmware](https://github.com/Sky1-Linux/sky1-firmware) - Firmware packages


## License

- Kernel patches: GPL-2.0 (same as Linux kernel)
