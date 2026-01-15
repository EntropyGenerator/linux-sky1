#!/bin/bash
# diff-kernel-config.sh - Compare local kernel config against Sky1 Linux default
#
# Usage: diff-kernel-config.sh [local-config-path]
#
# If no path provided, searches standard locations:
#   /proc/config.gz, /boot/config-$(uname -r), /boot/config

set -euo pipefail

SKY1_CONFIG_URL="https://raw.githubusercontent.com/Sky1-Linux/linux-sky1/main/config/config.sky1"
TMPDIR="${TMPDIR:-/tmp}"
WORK_DIR="$TMPDIR/diff-kernel-config.$$"

# Required options for Sky1/Orion O6 to function
# From: https://github.com/Sky1-Linux/linux-sky1/blob/main/config/README.md
REQUIRED_PLATFORM=(
    "ARCH_CIX"
    "PCI_SKY1"
    "PCIE_CADENCE_HOST"
    "PINCTRL_SKY1_BASE"
    "PINCTRL_SKY1"
    "RESET_SKY1"
    "CLK_SKY1_AUDSS"
    "CIX_MBOX"
    "GPIO_CADENCE"
    "HWSPINLOCK_SKY1"
)

REQUIRED_USB=(
    "USB_CDNS_SUPPORT"
    "USB_CDNS3"
    "USB_CDNSP"
    "USB_CDNSP_HOST"
    "USB_CDNSP_SKY1"
    "TYPEC"
    "PHY_CIX_USB2"
    "PHY_CIX_USB3"
    "PHY_CIX_USBDP"
)

REQUIRED_STORAGE=(
    "BLK_DEV_NVME"
    "PHY_CIX_PCIE"
)

RECOMMENDED_DISPLAY=(
    "DRM_CIX"
    "DRM_LINLONDP"
    "DRM_TRILIN_DPSUB"
    "DRM_TRILIN_DP_CIX"
)

RECOMMENDED_AUDIO=(
    "SND_HDA_CIX_IPBLOQ"
    "SND_HDA_CODEC_REALTEK"
    "SND_SOC_CIX"
    "SND_SOC_SKY1_SOUND_CARD"
)

RECOMMENDED_WIFI=(
    "RTW89_8852BE"
)

RECOMMENDED_PERIPHERALS=(
    "PWM_SKY1"
    "SKY1_WATCHDOG"
    "NVMEM_SKY1"
    "CIX_SKY1_SOCINFO"
)

cleanup() {
    rm -rf "$WORK_DIR"
}
trap cleanup EXIT

die() {
    echo "Error: $1" >&2
    exit 1
}

# Check for required tools
check_deps() {
    local missing=()
    for cmd in diff sort grep; do
        command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
    done

    # Need either curl or wget
    if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
        missing+=("curl or wget")
    fi

    if [ ${#missing[@]} -gt 0 ]; then
        die "Missing required tools: ${missing[*]}"
    fi
}

# Download file with curl or wget
download() {
    local url="$1"
    local output="$2"

    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$url" -o "$output" 2>/dev/null
    elif command -v wget >/dev/null 2>&1; then
        wget -q "$url" -O "$output" 2>/dev/null
    fi
}

# Find local kernel config
find_local_config() {
    local config_path="$1"

    # If user provided a path, use it
    if [ -n "$config_path" ]; then
        if [ -f "$config_path" ]; then
            echo "$config_path"
            return 0
        else
            die "Specified config file not found: $config_path"
        fi
    fi

    # Search standard locations
    local locations=(
        "/proc/config.gz"
        "/boot/config-$(uname -r)"
        "/boot/config"
        "/usr/src/linux/.config"
        "/usr/src/linux-headers-$(uname -r)/.config"
    )

    for loc in "${locations[@]}"; do
        if [ -f "$loc" ]; then
            echo "$loc"
            return 0
        fi
    done

    die "Could not find kernel config. Tried: ${locations[*]}
Please provide path as argument, or ensure CONFIG_IKCONFIG is enabled in your kernel."
}

# Check if option is enabled (=y or =m)
is_enabled() {
    local config_file="$1"
    local option="$2"
    grep -qE "^CONFIG_${option}=[ym]" "$config_file"
}

# Check required/recommended options and report missing
check_options() {
    local config_file="$1"
    local category="$2"
    local level="$3"  # "REQUIRED" or "RECOMMENDED"
    shift 3
    local options=("$@")

    local missing=()
    for opt in "${options[@]}"; do
        if ! is_enabled "$config_file" "$opt"; then
            missing+=("$opt")
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        if [ "$level" = "REQUIRED" ]; then
            echo "  [MISSING] $category:"
            for opt in "${missing[@]}"; do
                echo "    - CONFIG_$opt"
            done
        else
            echo "  [WARNING] $category:"
            for opt in "${missing[@]}"; do
                echo "    - CONFIG_$opt"
            done
        fi
        return 1
    fi
    return 0
}

# Extract config options (handles .gz files)
extract_config() {
    local input="$1"
    local output="$2"

    if [[ "$input" == *.gz ]]; then
        zcat "$input" 2>/dev/null | grep '^CONFIG_' | sort > "$output"
    else
        grep '^CONFIG_' "$input" | sort > "$output"
    fi
}

# Main
main() {
    local user_config_path="${1:-}"

    check_deps
    mkdir -p "$WORK_DIR"

    echo "Sky1 Linux Kernel Config Comparison Tool"
    echo "========================================="
    echo ""

    # Find local config
    echo "Finding local kernel config..."
    local local_config
    local_config=$(find_local_config "$user_config_path")
    echo "  Found: $local_config"

    # Find Sky1 default config (local first, then download)
    local sky1_config="$WORK_DIR/sky1.config"
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local local_sky1_config="$script_dir/config.sky1"

    if [ -f "$local_sky1_config" ]; then
        echo "Using local Sky1 config..."
        cp "$local_sky1_config" "$sky1_config"
        echo "  Found: $local_sky1_config"
    else
        echo "Downloading Sky1 default config..."
        if ! download "$SKY1_CONFIG_URL" "$sky1_config"; then
            die "Failed to download Sky1 config from $SKY1_CONFIG_URL"
        fi
        echo "  Downloaded from: $SKY1_CONFIG_URL"
    fi

    # Extract and sort configs
    echo "Comparing configs..."
    echo ""

    local local_sorted="$WORK_DIR/local.sorted"
    local sky1_sorted="$WORK_DIR/sky1.sorted"

    extract_config "$local_config" "$local_sorted"
    extract_config "$sky1_config" "$sky1_sorted"

    local local_count sky1_count
    local_count=$(wc -l < "$local_sorted")
    sky1_count=$(wc -l < "$sky1_sorted")

    echo "Local config:  $local_count options"
    echo "Sky1 default:  $sky1_count options"
    echo ""

    # Find differences
    local only_local="$WORK_DIR/only_local"
    local only_sky1="$WORK_DIR/only_sky1"
    local changed="$WORK_DIR/changed"

    comm -23 "$local_sorted" "$sky1_sorted" > "$only_local"
    comm -13 "$local_sorted" "$sky1_sorted" > "$only_sky1"

    # Find options with different values
    echo "=== Options with DIFFERENT VALUES ==="
    echo "(Your value -> Sky1 default)"
    echo ""

    local count=0
    while IFS='=' read -r opt local_val; do
        local sky1_line
        sky1_line=$(grep "^${opt}=" "$sky1_sorted" 2>/dev/null || true)
        if [ -n "$sky1_line" ]; then
            local sky1_val="${sky1_line#*=}"
            if [ "$local_val" != "$sky1_val" ]; then
                echo "  $opt: $local_val -> $sky1_val"
                ((count++)) || true
            fi
        fi
    done < "$local_sorted"

    if [ "$count" -eq 0 ]; then
        echo "  (none)"
    fi
    echo ""
    echo "Total options with different values: $count"
    echo ""

    # Options only in local
    local only_local_count
    only_local_count=$(wc -l < "$only_local")
    echo "=== Options ONLY in your config (not in Sky1 default) ==="
    echo "Total: $only_local_count"
    if [ "$only_local_count" -gt 0 ] && [ "$only_local_count" -le 50 ]; then
        cat "$only_local" | sed 's/^/  /'
    elif [ "$only_local_count" -gt 50 ]; then
        echo "(showing first 20)"
        head -20 "$only_local" | sed 's/^/  /'
        echo "  ..."
    fi
    echo ""

    # Options only in Sky1
    local only_sky1_count
    only_sky1_count=$(wc -l < "$only_sky1")
    echo "=== Options ONLY in Sky1 default (missing from your config) ==="
    echo "Total: $only_sky1_count"
    if [ "$only_sky1_count" -gt 0 ] && [ "$only_sky1_count" -le 50 ]; then
        cat "$only_sky1" | sed 's/^/  /'
    elif [ "$only_sky1_count" -gt 50 ]; then
        echo "(showing first 20)"
        head -20 "$only_sky1" | sed 's/^/  /'
        echo "  ..."
    fi
    echo ""

    # Check required and recommended options
    echo "=== REQUIRED OPTIONS CHECK ==="
    echo "(Missing any of these may cause boot failure or broken functionality)"
    echo ""

    local has_missing=0

    check_options "$local_sorted" "Platform/SoC Support" "REQUIRED" "${REQUIRED_PLATFORM[@]}" || has_missing=1
    check_options "$local_sorted" "USB Support" "REQUIRED" "${REQUIRED_USB[@]}" || has_missing=1
    check_options "$local_sorted" "Storage (NVMe/PCIe)" "REQUIRED" "${REQUIRED_STORAGE[@]}" || has_missing=1

    if [ "$has_missing" -eq 0 ]; then
        echo "  [OK] All required options are enabled"
    fi
    echo ""

    echo "=== RECOMMENDED OPTIONS CHECK ==="
    echo "(Missing these may disable specific hardware features)"
    echo ""

    local has_warnings=0

    check_options "$local_sorted" "Display/GPU" "RECOMMENDED" "${RECOMMENDED_DISPLAY[@]}" || has_warnings=1
    check_options "$local_sorted" "Audio" "RECOMMENDED" "${RECOMMENDED_AUDIO[@]}" || has_warnings=1
    check_options "$local_sorted" "WiFi (RTW89)" "RECOMMENDED" "${RECOMMENDED_WIFI[@]}" || has_warnings=1
    check_options "$local_sorted" "Peripherals" "RECOMMENDED" "${RECOMMENDED_PERIPHERALS[@]}" || has_warnings=1

    if [ "$has_warnings" -eq 0 ]; then
        echo "  [OK] All recommended options are enabled"
    fi
    echo ""

    # Summary
    if [ "$has_missing" -eq 1 ]; then
        echo "*** WARNING: Missing REQUIRED options - your system may not boot or function correctly! ***"
        echo ""
    fi

    echo "Comparison complete."
}

main "$@"
