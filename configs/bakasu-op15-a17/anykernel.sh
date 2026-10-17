### AnyKernel3 Ramdisk Mod Script
## osm0sis @ xda-developers

### AnyKernel setup
# global properties
properties() { '
kernel.string=Wild Kernels by TheWildJames aka Morgan Weedman
do.devicecheck=0
do.modules=0
do.systemless=0
do.cleanup=1
do.cleanuponabort=0
do.check_boot_version=1
device.name1=
device.name2=
device.name3=
device.name4=
device.name5=
supported.versions=
supported.patchlevels=
supported.vendorpatchlevels=
keycheck.timeout=10
'; } # end properties


### AnyKernel install
## boot shell variables
block=boot
is_slot_device=auto
ramdisk_compression=auto
patch_vbmeta_flag=auto
no_magisk_check=1

# import functions/variables and setup patching - see for reference (DO NOT REMOVE)
. tools/ak3-core.sh

# GKI check
kernel_version=$(cat /proc/version | awk -F '-' '{print $1}' | awk '{print $3}')
case $kernel_version in
    5.10*) ksu_supported=true ;;
    5.15*) ksu_supported=true ;;
    6.1*) ksu_supported=true ;;
    6.6*) ksu_supported=true ;;
    6.12*) ksu_supported=true ;;
    *) ksu_supported=false ;;
esac

ui_print " " "  -> Wild Kernels Supported: $ksu_supported"
$ksu_supported || abort "  -> Non-GKI device, abort."

# boot install
split_boot

# Menu to conditionally patch BBG for abl/efisp whitelisting
##################################################
SELECTED_STR="  [->] Selected:"

show_menu() {
  local selected=1
  local total=$#
  if [ $total -eq 2 ]; then
    while true; do
      handle_input
      KEY_RESULT=$(cat /tmp/ak3_key_result 2>/dev/null)
      case "$KEY_RESULT" in
      "KEY_VOLUMEUP") return 1 ;;
      "KEY_VOLUMEDOWN"|"TIMEOUT") return 2 ;;
      esac
    done
  else
    while true; do
      eval "local current=\"\$$selected\""
      ui_print "➔ $current"
      ui_print " "
      handle_input
      KEY_RESULT=$(cat /tmp/ak3_key_result 2>/dev/null)
      case "$KEY_RESULT" in
      "KEY_VOLUMEUP") 
		selected=$((selected % total + 1))
		;;
      "KEY_VOLUMEDOWN"|"TIMEOUT")
        ui_print "$SELECTED_STR $current"
        return $selected
        ;;
      esac
    done
  fi
}

MENU_OPTIONS="Yes No"

PATCH_CMDLINE=0
ui_print " "
ui_print "=========================================="
ui_print " Are you using efisp exploit and require "
ui_print " whitelisting abl and efisp partitions?   "
ui_print "------------------------------------------"
ui_print " 1. Yes. Whitelist abl and efisp!        "
ui_print " 2. No. Keep as is!                      "
ui_print "                                         "
ui_print "        [VOL+] - Yes | [VOL-] - No       "
ui_print "=========================================="
ui_print " "
show_menu $MENU_OPTIONS
case $? in
    1) PATCH_CMDLINE=1 ;;
    2) PATCH_CMDLINE=0 ;;
esac

if [ $PATCH_CMDLINE == 1 ]; then
    ui_print "Patching cmdline to allow abl and efisp flashing!!!"
    patch_cmdline "oplusboot.secure_user_mode" "oplusboot.secure_user_mode=0"
else
    ui_print "Flashing the kernel as is with full BBG security!!!"
    patch_cmdline "oplusboot.secure_user_mode" ""
fi
##################################################

if [ -f "$SPLITIMG/ramdisk.cpio" ]; then
    unpack_ramdisk
    write_boot
else
    flash_boot
fi

ui_print " "
ui_print "WildKernels Telegram Channel:"
ui_print "https://t.me/WildKernelsTG"
ui_print " "
ui_print "WildKernels Website:"
ui_print "https://wildkernels.dev"
ui_print " "
ui_print "GKI_KernelSU_SUSFS GitHub Repository:"
ui_print "https://github.com/WildKernels/GKI_KernelSU_SUSFS"
ui_print "GKI kernels with KernelSU and SUSFS."
ui_print " "
ui_print "OnePlus_KernelSU_SUSFS GitHub Repository:"
ui_print "https://github.com/WildKernels/OnePlus_KernelSU_SUSFS"
ui_print "OnePlus kernels with KernelSU and SUSFS."
ui_print " "
ui_print "Samsung_KernelSU_SUSFS GitHub Repository:"
ui_print "https://github.com/WildKernels/Samsung_KernelSU_SUSFS"
ui_print "Samsung kernels with KernelSU and SUSFS."
ui_print " "
ui_print "If you have any questions or need support, feel free to join our Telegram channel!" 
ui_print " "
ui_print "Thank you for using Wild Kernels! - TheWildJames"
ui_print " "