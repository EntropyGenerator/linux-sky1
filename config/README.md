# Sky1 Kernel Configuration Guide

This documents non-default kernel options enabled for CIX Sky1/Radxa Orion O6.

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

## DSP/Firmware (optional)

| Config | Type | Purpose |
|--------|------|---------|
| `CIX_DSP` | module | DSP IPC driver |
| `CIX_DSP_RPROC` | module | Remote processor for DSP |
| `DMABUF_HEAPS_DSP` | module | DSP DMA buffers |

## Device-Specific (Orion O6)

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
```

Add display, audio, WiFi, etc. as needed for your use case.
