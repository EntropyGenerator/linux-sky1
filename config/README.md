# Sky1 Kernel Configuration Guide

This documents non-default kernel options enabled for CIX Sky1/Radxa Orion O6.

## Config Files

Four track-specific configs are maintained, one per kernel build track:

| File | Track | Kernel |
|------|-------|--------|
| `config.sky1` | LTS | v6.18.x (stable) |
| `config.sky1-latest` | Latest | v6.19.x (newest stable) |
| `config.sky1-rc` | RC | v6.X-rcN (release candidates) |
| `config.sky1-next` | Next | origin/master (bleeding edge) |

All configs share the same Sky1-specific options. Differences are limited to
upstream kernel version changes (new options, changed defaults).

## Config Management Tools

### Compare your config against Sky1 default

```bash
# Download and run (no installation needed)
curl -fsSL https://raw.githubusercontent.com/Sky1-Linux/linux-sky1/main/config/diff-kernel-config.sh | bash

# Or with a specific config file
curl -fsSL https://raw.githubusercontent.com/Sky1-Linux/linux-sky1/main/config/diff-kernel-config.sh | bash -s /path/to/your/.config
```

The script will:
- Compare your config against the Sky1 default
- Flag any **missing required options** that may cause boot failures
- Warn about **missing recommended options** for specific hardware features
- Show all differences between your config and the default

### Cross-track reconciliation (developers)

```bash
# Check all track configs for policy violations and divergence
~/mainline-linux/scripts/reconcile-configs.py

# Auto-fix policy violations
~/mainline-linux/scripts/reconcile-configs.py --fix

# Review config changes after rebasing to a new kernel version
~/mainline-linux/scripts/reconcile-configs.py --review .config.pre-rebase .config
```

### Config policy

`config-policy.ini` defines options that must be consistent across all track
configs. This includes all Sky1-specific driver options and core infrastructure.
Board-specific options (e.g. R8126 for O6, R8125 for O6N) are excluded since
they vary by hardware.

## Essential Platform Support

These are required for Sky1 hardware to function:

| Config | Type | Purpose |
|--------|------|---------|
| `ARCH_CIX` | bool | CIX SoC architecture support |
| `PCI_SKY1` | bool | PCIe host controller |
| `PCIE_CADENCE_HOST` | bool | Cadence PCIe IP (used by Sky1) |
| `PINCTRL_SKY1_BASE` | bool | Pin controller base |
| `PINCTRL_SKY1` | bool | Sky1 pin muxing |
| `RESET_SKY1` | bool | Reset controller |
| `CLK_SKY1_AUDSS` | bool | Audio subsystem clocks |
| `CIX_MBOX` | bool | SCMI mailbox (power/thermal) |
| `GPIO_CADENCE` | bool | Cadence GPIO IP |

## Thermal & Power Management

Thermal management and power allocation are handled by mainline kernel (SCMI cpufreq driver).
No vendor-specific thermal drivers are needed.

## USB Support

| Config | Type | Purpose |
|--------|------|---------|
| `USB_CDNS_SUPPORT` | bool | Cadence USB IP support |
| `USB_CDNS3` | bool | USB3 controller |
| `USB_CDNSP` | bool | USB4/SuperSpeedPlus |
| `USB_CDNSP_HOST` | bool | Host mode |
| `USB_CDNSP_GADGET` | bool | Gadget mode (OTG) |
| `USB_CDNSP_SKY1` | bool | Sky1 platform glue |
| `TYPEC` | bool | USB Type-C support |
| `TYPEC_RTS5453` | bool | Realtek PD controller (Orion O6) |

## PHY Drivers

| Config | Type | Purpose |
|--------|------|---------|
| `PHY_CIX_PCIE` | bool | PCIe PHY |
| `PHY_CIX_USB2` | bool | USB 2.0 PHY |
| `PHY_CIX_USB3` | bool | USB 3.0 PHY |
| `PHY_CIX_USBDP` | bool | USB-DP combo PHY (Type-C DP alt-mode) |

## Display (optional but recommended)

| Config | Type | Purpose |
|--------|------|---------|
| `DRM_CIX` | module | CIX DRM subsystem |
| `DRM_LINLONDP` | module | Linlon Display Processor (DPU) |
| `DRM_TRILIN_DPSUB` | module | DP TX subsystem |
| `DRM_TRILIN_DP_CIX` | module | CIX DP glue |
| `DRM_CIX_EDP_PANEL` | module | eDP panel support |
| `DRM_CIX_VIRTUAL` | module | Virtual connector (headless) |

## Audio (optional)

| Config | Type | Purpose |
|--------|------|---------|
| `SND_HDA_CIX_IPBLOQ` | module | HDA controller |
| `SND_HDA_CODEC_REALTEK` | module | Realtek codec (Orion O6) |
| `SND_SOC_CIX` | module | ASoC machine driver |
| `SND_SOC_SKY1_SOUND_CARD` | module | Sky1 sound card |
| `SND_SOC_CDNS_I2S_MC` | module | Cadence I2S multi-channel |
| `SND_SOC_CDNS_I2S_SC` | module | Cadence I2S single-channel |
| `SND_SOC_SOF_CIX_*` | module | Sound Open Firmware (DSP audio) |

## Peripherals

| Config | Type | Purpose |
|--------|------|---------|
| `PWM_SKY1` | bool | PWM controller (fans, backlight) |
| `SKY1_WATCHDOG` | bool | Watchdog timer |
| `HWSPINLOCK_SKY1` | bool | Hardware spinlocks |
| `NVMEM_SKY1` | bool | eFuse/OTP access |
| `CIX_SKY1_SOCINFO` | bool | SoC info (sysfs) |
| `RESET_SKY1_AUDSS` | bool | Audio subsystem reset controller |
| `SKY1_PDC` | bool | Power Domain Controller |
| `CIX_BUS_PERF` | bool | Bus frequency scaling (CI700/NI700) |
| `CIX_CPU_IPA` | bool | CPU Intelligent Power Allocation |
| `CIX_DDR_LP` | bool | DDR low-power management |

## Video Processing (optional)

| Config | Type | Purpose |
|--------|------|---------|
| `VIDEO_LINLON` | module | Linlon VPU video codec (H.264/H.265/AV1/VP9 HW encode/decode) |
| `VIDEO_LINLON_FTRACE` | bool | VPU ftrace debug logging (development only) |
| `VIDEO_LINLON_PRINT_FILE` | bool | VPU log file/line annotations |

## NPU (optional)

| Config | Type | Purpose |
|--------|------|---------|
| `ARMCHINA_NPU` | module | ArmChina Zhouyi NPU accelerator |
| `ARMCHINA_NPU_ARCH_V3` | bool | Zhouyi V3 architecture (Sky1) |
| `ARMCHINA_NPU_SOC_SKY1` | bool | Sky1 SoC support |

## Ethernet

| Config | Type | Purpose |
|--------|------|---------|
| `R8126` | module | Realtek RTL8126 5GbE (Orion O6) |
| `R8125` | module | Realtek RTL8125 2.5GbE (Orion O6N) |

## DSP/Firmware (optional)

| Config | Type | Purpose |
|--------|------|---------|
| `CIX_DSP` | module | DSP IPC driver |
| `CIX_DSP_RPROC` | module | Remote processor for DSP |
| `DMABUF_HEAPS_DSP` | module | DSP DMA buffers |

## Device-Specific (Orion O6 / O6N)

| Config | Type | Purpose |
|--------|------|---------|
| `BLK_DEV_NVME` | bool | NVMe SSD support |
| `RTW89_8852BE` | module | Realtek WiFi (RTL8852BE) |

## Debug Options (development only)

These increase kernel size and reduce performance. Disable for production:

| Config | Purpose |
|--------|---------|
| `DYNAMIC_DEBUG` | Runtime debug message control |
| `FTRACE` | Function tracer |
| `FUNCTION_TRACER` | Trace function calls |
| `FUNCTION_GRAPH_TRACER` | Trace call graphs |
| `IRQSOFF_TRACER` | IRQ latency tracing |
| `SCHED_TRACER` | Scheduler tracing |
| `TRACER_SNAPSHOT` | Trace snapshots |
| `PANIC_ON_OOPS` | Panic instead of continuing after oops |
| `FW_LOADER_DEBUG` | Firmware loading debug |
| `IWLWIFI_DEVICE_TRACING` | Intel WiFi tracing (not needed) |

## Minimal Config

For a minimal bootable Sky1 system:

```
# Platform (required)
ARCH_CIX, PCI_SKY1, PCIE_CADENCE_HOST
PINCTRL_SKY1_BASE, PINCTRL_SKY1, RESET_SKY1
CIX_MBOX, GPIO_CADENCE

# USB (keyboard/storage)
USB_CDNS_SUPPORT, USB_CDNS3, USB_CDNSP, USB_CDNSP_HOST
USB_CDNSP_SKY1, PHY_CIX_USB2, PHY_CIX_USB3

# Storage
BLK_DEV_NVME

# Ethernet (pick one based on board)
R8126      # Orion O6 (5GbE)
R8125      # Orion O6N (2.5GbE)
```

Add display, audio, WiFi, VPU, NPU, etc. as needed for your use case.
