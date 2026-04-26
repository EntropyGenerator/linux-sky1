# Changelog

All notable changes to the Sky1 kernel patch set.

## [7.0.1] - 2026-04-25

### Added
- Add support for MS-R1
- Add workflow to build kernel

## [6.19.4-1] - 2026-02-27

### Changed
- Rebased LTS to Linux 6.18.14 stable (126 patches)
- Rebased Latest to Linux 6.19.4 stable (127 patches)

### Added
- drm/trilin-dptx: Tear down DP core on HPD disconnect — calls `trilin_dp_core_off()` and clears `DP_STATE_ENABLED` in disconnect handler for clean PHY state on replug
- drm/trilin-dptx: Reset `active_stream_cnt` on HPD disconnect — prevents stale stream count from causing DP TX misconfiguration (black screen) after USB-C replug
- phy: cix: usbdp: Default to DP mode for static outputs without mode-switch

### Notes
- All tracks updated: LTS 126, Latest 127, RC 30, Next 30 patches
- DP hotplug fixes cherry-picked to all tracks (main, rc, next)

## [6.18.10-2] - 2026-02-13

### Added
- drm/panthor: ACE-Lite bus coherency on Sky1 — GPU L2 evictions now route through the CHI fabric Home Node (HN-F) and System Level Cache (SLC), restoring write-back caching while maintaining display correctness. Matches vendor kbase driver configuration.
- drm/panthor: Shareable Cache Support (AMBA_ENABLE bit 5) enabled when hardware reports support
- soc: cix: ACPI scan handler to override GPU `_CCA` to non-coherent on Sky1 (DT parity)

### Fixed
- drm/panthor: Upstream coherency register bug — `GPU_COHERENCY_PROT_BIT(ACE_LITE)` expanded to BIT(0)=1 (ACE) instead of 0 (ACE_LITE). Fixed by writing protocol index directly.
- drm: linlon-dp: DPU render node removed (conflicted with Panthor GPU), fbdev always enabled, pm_restore uses device_property API for ACPI, reset controls acquired in ACPI parse path

### Notes
- ACE-Lite alone is not sufficient to prevent display corruption — GPU L2 may not evict to SLC in time for the DPU. NC memattr is still forced as a safety fallback when no IOMMU is present.
- LTS: 117 patches (up from 114), Latest: 118 patches (up from 115)

## [6.18.10-1] - 2026-02-12

### Changed
- Rebased to Linux 6.18.10 stable (113 patches)
- Dropped redundant "reset: restore lookup table API" patch — already present in 6.18.x upstream (only needed on 6.19+ where it was removed)

### Added
- USB3 SuperSpeed under ACPI: deferred PHY probe ordering, ACPI device matching for CDNSP
- USB Attached SCSI (UAS) enabled in config for improved USB storage throughput
- ACPI USB scan handler (PNP0D10) to block premature XHCI probe before PHY ready
- Full PHY reset under ACPI (phy-cix-usbdp)

### Fixed
- HDA Realtek alc269: resolved context conflict with upstream Yoga 9i fixup addition

## [6.19-1] - 2026-02-11

### Added
- **New track**: Latest stable (v6.19.x) — first release
- reset: Restore reset_control_lookup table API (removed upstream in 6.19, needed for ACPI reset consumers)

### Notes
- Linux 6.19 released, RC track promoted to Latest
- All 108 LTS patches carried forward, plus reset API restoration (109 total)
- RC track dormant until v7.0-rc1

## [6.18.9-1] - 2026-02-11

### Changed
- Rebased to Linux 6.18.9 stable (108 patches, up from 42 in 6.18.8-4)

### Added — ACPI Boot Support
- firmware: arm_scmi: Full ACPI boot support — shared memory discovery, mailbox channel validation, transport driver macro, protocol auto-enumeration
- mailbox: cix-mailbox: ACPI build support, fwnode channel lookup, register offset cleanup
- clk: ACPI clock infrastructure — CLKT table parsing, clkdev registration, SCMI clock global lookup
- clk: sky1-audss: ACPI regmap fallback, CLKA table parsing for audio clock consumers
- soc: cix: ACPI resource lookup driver (CIXA1019) — RSTL reset, RSNL resource naming, DLKL device links
- pmdomain: fwnode-based genpd provider for ACPI power domain consumers
- pmdomain: SCMI power and perf domain registration under ACPI
- drm/panthor: ACPI support for GPU power-on (raw SMC SCMI call) and DVFS with 6 OPP levels
- drm/panthor: ACPI device table (CIXH5000) with positional IRQ lookup
- drm/cix/linlon-dp: ACPI probe logging cleanup and NULL match guard
- PCI: sky1: MCFG quirk for initial ACPI ECAM support
- PCI: sky1: Vendor scan handler (block PNP0A08, probe CIXH2020 with full init sequence)
- PCI: sky1: ACPI probe with RSTL reset, regulator support, fw_devlink bypass
- misc: armchina-npu: ACPI DVFS via fwnode genpd provider (OPP 72MHz–1GHz)
- remoteproc: cix_dsp_rproc: ACPI boot support (syscon, clock, reset, memremap fallbacks)
- audio: HDMI/DisplayPort audio output under ACPI (I2S5-I2S9, DMA-350, sky1-card CIXH6070)
- xhci: plat: Auto-detect USB3 LPM from HCSPARAMS3 for ACPI controllers
- usb: cdns3: Harden cdnsp-sky1 probe for ACPI, skip destructive reinit, serialize drd_init
- gpio: cadence: ACPI device IDs (CIXH1002, CIXH1003), edge IRQ, PM, wake support
- mfd: syscon: ACPI platform driver (CIXHA018)
- pstore: ramoops: device_property API for ACPI support
- sound: hda: cix-ipbloq: ACPI DMA range map and reserved memory support
- ACPI: property: Restore string-path traversal for graph references
- treewide: ACPI device IDs for 14 CIX Sky1 peripherals (I2C, I3C, SPI, DMA, network, display, audio)
- scripts: sky1_lib: DMI board detection fallback for ACPI boot

### Added — New Drivers
- hwmon: CIX Sky1 fan controller driver (CIXHA024) — PWM speed control, tachometer RPM
- clocksource: CIX Sky1 GPT timer driver (CIXH1007) — 64-bit clocksource + clock event device

### Added — Features
- PCI: cadence: sky1: ASPM control (per-controller L0s/L1 via max-aspm-support), TLP filter for LTR/PTM, wake GPIO wakeup source
- PCI: ASPM quirks for Phison E13T and Kingston NVMe drives (link instability)
- iommu/arm-smmu-v3: PCIe ATS override for Sky1 DTI translated TLPs
- net: realtek: r8125/r8126: Wake-on-LAN magic packet, Receive Side Scaling
- net: realtek: r8125/r8126: IRQ affinity hint for performance cores on big.LITTLE
- usb: Runtime PM by default for Sky1 USB controllers (OTG only, host stays D0)
- thermal: cix: IPA power integration for cpufreq_cooling (real-time power data)
- cpufreq: cppc: Skip redundant frequency updates for slow PCC mailboxes
- rtc: hym8563: Second-level wake-up precision via timer function
- drm: cix: dptx: PSR improvements (fast training, 2ppc disable, idle patterns)
- drm: cix: dptx: Freezable workqueue for HPD events during suspend
- arm64: dts: cix: Thermal zone rename to tz-* pattern, add switch_on trip at 60C

### Fixed
- clk: sky1-acpi: Use CLKT consumer reference for clkdev (wrong clock causing SError)
- PCI: cadence: sky1: Skip regulator lookup under ACPI (spurious dummy warnings)
- PCI: Silence I/O BAR assignment failures when no I/O windows exist
- Bluetooth: btrtl: NULL pointer dereference on USB disconnect during init
- phy: cix-usbdp: Skip PHY reset under ACPI (stale GOP state killing active USB)
- phy: cix-usbdp: Guard syscon regmap for ACPI boot (NULL pointer crash)
- drm: cix: dptx: Suspend/resume deadlock (mutex held during cancel_delayed_work_sync)
- drm: cix: dptx: Hotplug state machine on repeated resets (HDMI signal loss)
- drm: cix: dptx: Skip compute_config on non-modeset commits (fbcon feedback loop)
- drm: cix: linlon-dp: Handle vblank event on flip timeout (reduced from 60 to 3 frames)
- gpio: cadence: IRQ storm fix (missing flow handlers, pre-registration IRQ disable, ack callback)
- usb: cdns3: Runtime PM only for OTG ports (host-only stayed in D3, no hotplug)
- net: realtek: r8125/r8126: Missing RSS object files in Makefile
- mailbox: cix-mailbox: Remove debug prints, use_shmem offset hack
- pwm: sky1: Remove clock auto-enable and probe reset (UEFI backlight interference)
- ASoC: CIX Phecda HDA fixup, I2S FIFO drain, 192KHz mclk_fs, trigger ordering
- drivers: Fix 6 ACPI boot failures (GPT timer clocks, HDA reserved mem, SCMI genpd, PWM backlight, ramoops, regulator-fixed)
- treewide: Debug cleanup for Sky1 peripherals (DMA-350 remote device SError, audss prints)
- scripts: kernel-track-status: Handle major version bumps (6.19→7.0)
- update-dev-boot: Handle .rN revision suffix in kernel names

## [6.18.8-4] - 2026-02-04

### Added
- iommu/arm-smmu-v3: Add SMMUv3.2 event definitions (F_TRANSL_FORBIDDEN, C_BAD_ATS_TREQ)
- DTS: dma-coherent on all SMMU nodes (enables coherent page table walks)
- DTS: msi-parent on PCIe SMMU (enables MSI-based event delivery)
- DTS: arm,boot-active-sids on PCIe SMMU (bypass STEs for PCIe root port SIDs)

### Fixed
- DTS: O6N DP PHY set to pure DisplayPort mode (usbc_phy3 default_conf)
- DTS: O6 USB overcurrent and NVMe wake GPIO mappings
- DTS: O6N power tree and USB-C PD conversion to TCPCI
- SMMU event 0x07 (F_TRANSL_FORBIDDEN) no longer prints as "UNKNOWN"
- PCIe SMMU event spam when smmu_pciehub is enabled

## [6.18.8-1] - 2026-02-01

### Changed
- Rebased to Linux 6.18.8 stable
- Consolidated patch set from 78 granular patches to 13 subsystem-grouped patches
- Previous 78-patch history preserved in `original-patches` branch

### Patch structure
- 0001: Device trees (SoC + O6/O6N boards)
- 0002: PCIe host controller
- 0003: Infrastructure drivers (SCMI, mailbox, pinctrl, clock, reset, hwspinlock, eFuse, SoC info)
- 0004: USB and PHY drivers
- 0005: Display drivers (linlon-dp, trilin-dpsub)
- 0006: GPU (Panthor Mali-G720)
- 0007: Audio (HDA, DMA-350, DSP)
- 0008: Networking (RTL8126 5GbE, RTL8125 2.5GbE)
- 0009: NPU (armchina Zhouyi)
- 0010: VPU (amvx video codec)
- 0011: IRQ, IOMMU, perf (PDC, SMMU, ARM SPE)
- 0012: Misc platform (thermal, PWM, watchdog, DDR LP, bus DVFS, CPU IPA, cpufreq)
- 0013: Dev scripts

## [6.18.7-2] - 2026-01-30

### Added
- media: In-tree VPU driver (amvx) — replaces DKMS sky1-vpu-dkms
- misc: In-tree NPU driver (armchina-npu) — replaces DKMS cix-npu-driver
- net: In-tree Realtek RTL8126 5GbE and RTL8125 2.5GbE drivers — replaces DKMS

### Fixed
- armchina-npu: Fix iommu_dma_cookie struct layout for kernel 6.18 (boot panic)

### Changed
- config: Enable in-tree VPU/NPU/r8126/r8125, disable R8169 to avoid conflicts

## [6.18.7-1] - 2026-01-28

### Changed
- Rebased to Linux 6.18.7 stable (73 patches)

## [6.18.4-2] - 2026-01-14

### Fixed
- DTS: Disable IOMMU for display controllers (fixes ACE errors during compositor transitions)
- LPU Address Cache Engine caches IOVA→PA translations independently from SMMU TLB
- When IOVAs are recycled during GDM→KWin handoffs, ACE has stale entries causing MERR/FERR

## [6.18.4-1] - 2026-01-10

### Changed
- Rebased to Linux 6.18.4 stable

### Added
- Input: gpio_keys driver support for level-triggered interrupts
- DTS: O6N power button uses IRQ_TYPE_LEVEL_LOW (Cadence GPIO compatibility)

### Fixed
- O6N boot failure from gpio-keys edge interrupt (Cadence GPIO only supports level triggers)

## [6.18.3-1] - 2026-01-03

### Changed
- Rebased to Linux 6.18.3 stable

### Fixed
- config: Disable DRM_SIMPLEDRM to fix KDE Plasma (simpledrm conflicted with linlon_dp)

## [6.18.2-3] - 2026-01-03

### Added
- DTS: Radxa Orion O6N device tree (micro-ITX variant with fewer peripherals)
- soc: DDR low power control driver
- soc: Bus performance state (DVFS) driver
- thermal: CPU IPA power monitoring driver

### Fixed
- DTS: O6N modem regulator-boot-on removed (prevents boot hang)
- drm/cix: dptx null pointer dereference in unbind
- wifi: rtw89 power save race causing firmware crash
- soc: DDR LP and bus DVFS initialization order

## [6.18.2-2] - 2025-12-24

### Fixed
- PCIe: Enable I/O and prefetchable memory windows in RC BAR config
- Fixes "bridge window [??? ...]: can't assign" errors for I/O BARs
- Uses correct CIX Sky1 bit positions (20-23) vs Cadence standard (17-20)

### Added
- DTS: CPU cache topology (L2/L3 hierarchy)
- DTS: USB3 LPM (Link Power Management) support
- perf: ARM SPE heterogeneous CPU support (A720+A520)

## [6.18.2-1] - 2025-12-22

### Changed
- Rebased to Linux 6.18.2 stable
- Migrated to new repository structure (patches/ and config/ at top level)
- Removed Debian packaging (now in separate sky1-linux-build repo)

## [6.18.1-9] - 2025-12-21

### Fixed
- Kernel version string consistency (removed CONFIG_LOCALVERSION="-mainline-cix")
- Disabled CONFIG_LOCALVERSION_AUTO for predictable version strings

## [6.18.1-7] - 2025-12-21

### Added
- Initramfs generation hooks for kernel package postinst

## [6.18.1-6] - 2025-12-20

### Fixed
- linux-headers package conflict with linux-libc-dev
- Headers now properly support DKMS module building

## [6.18.1-5] - 2025-12-19

### Changed
- Core Sky1 Kconfig entries changed from tristate to bool
- Core SoC infrastructure must be built-in (mailbox, reset, pinctrl, clk, pci, hwspinlock, PHYs)
- Board-specific drivers remain tristate (PWM, watchdog, socinfo, Type-C)

## [6.18.1-4] - 2025-12-19

### Removed
- Dead thermal drivers (cix_scmi_em, cix_cpu_ipa)
- Mainline SCMI cpufreq handles energy model registration

### Fixed
- linlon-dp include structure for Nix builds

### Added
- Kernel configuration guide (config/README.md)

## [6.18.1-3] - 2025-12-16

### Added
- iommu/arm-smmu-v3: DT support for boot-active stream IDs
- Pre-install bypass STEs for devices active at boot
- Eliminates C_BAD_STREAMID errors from display controller

## [6.18.1-2] - 2025-12-15

### Fixed
- cpufreq: schedutil not using boost frequencies
- Update capacity_freq_ref when boost state changes
- Fixes ~30% performance loss with schedutil governor

## [6.18.1-1] - 2025-12-15

### Changed
- Rebased to Linux 6.18.1 stable (55 Sky1 patches)

### Fixed
- PCIe: portdrv AER/PME IRQ conflicts during hotplug
- WiFi: rtw89 scan offload robustness for hotplug

## [6.18.0-1] - 2025-12-12

### Added
- Initial release for CIX Sky1 SoC (53 patches on Linux 6.18)
- Panthor GPU support (Mali-G720-Immortalis)
- Display: linlon-dp, trilin-dpsub drivers
- PCIe: Cadence controller with MSI-X support
- USB: CDNSP, RTS5453 Type-C PD controller
- Audio: HDA, DMA-350, DSP support
- Power: SCMI domains, PDC IRQ chip
- Misc: hwspinlock, eFuse, SoC info drivers
