# Changelog

All notable changes to the Sky1 kernel patch set.

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
