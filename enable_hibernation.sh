#!/bin/bash

# Activate real hibernation in Arch Linux with LXDE
# Requires: zenity, sudo privileges, active swap, GRUB

# --- Permission check ---
if [ "$EUID" -ne 0 ]; then
  echo "This script must be run as root."
  exit 1
fi

# --- Zenity check ---
if ! command -v zenity &>/dev/null; then
  echo "zenity is not installed. Required for graphical dialogs."
  read -p "Do you want to install zenity now? [Y/n]: " answer
  answer=${answer:-Y}
  if [[ "$answer" =~ ^[Yy]$ ]]; then
    pacman -Sy --noconfirm zenity || {
      echo "Failed to install zenity. Exiting."
      exit 1
    }
    USE_ZENITY=true
  else
    echo "zenity not installed. Falling back to terminal messages."
    USE_ZENITY=false
  fi
else
  USE_ZENITY=true
fi

# --- Swap check ---
SWAP_DEV=$(swapon --noheadings --show=NAME | head -n 1)

if [ -z "$SWAP_DEV" ]; then
  $USE_ZENITY && zenity --error --text="No active swap partition detected.\nHibernation cannot be configured." || echo "ERROR: No active swap partition detected."
  exit 1
fi

UUID=$(blkid -s UUID -o value "$SWAP_DEV")

if [ -z "$UUID" ]; then
  $USE_ZENITY && zenity --error --text="Failed to obtain the UUID of the swap partition: $SWAP_DEV" || echo "ERROR: Could not obtain swap UUID."
  exit 1
fi

RESUME_PARAM="resume=UUID=$UUID"

# --- Modify /etc/default/grub ---
GRUB_FILE="/etc/default/grub"
cp "$GRUB_FILE" "${GRUB_FILE}.bak"

if grep -q "$RESUME_PARAM" "$GRUB_FILE"; then
  echo "resume=UUID already present in GRUB. Skipping modification."
elif grep -q 'GRUB_CMDLINE_LINUX_DEFAULT="' "$GRUB_FILE"; then
  echo "Adding $RESUME_PARAM to GRUB_CMDLINE_LINUX_DEFAULT..."
  sed -i "/^GRUB_CMDLINE_LINUX_DEFAULT=/ s/"$/ $RESUME_PARAM"/" "$GRUB_FILE"
else
  $USE_ZENITY && zenity --error --text="Could not find GRUB_CMDLINE_LINUX_DEFAULT in $GRUB_FILE" || echo "ERROR: GRUB_CMDLINE_LINUX_DEFAULT not found."
  exit 1
fi

# --- Modify /etc/mkinitcpio.conf ---
MKINIT_FILE="/etc/mkinitcpio.conf"
cp "$MKINIT_FILE" "${MKINIT_FILE}.bak"

if grep -q 'resume' "$MKINIT_FILE"; then
  echo "resume hook already present. Skipping modification."
else
  echo "Adding resume hook..."
  sed -i '/^HOOKS=/ s/block /block resume /' "$MKINIT_FILE"
fi

# --- Regenerate GRUB ---
if grub-mkconfig -o /boot/grub/grub.cfg; then
  echo "GRUB successfully updated."
else
  $USE_ZENITY && zenity --error --text="Failed to regenerate GRUB." || echo "ERROR: Failed to regenerate GRUB."
  exit 1
fi

# --- Regenerate initramfs ---
if mkinitcpio -P; then
  echo "initramfs successfully regenerated."
else
  $USE_ZENITY && zenity --error --text="Failed to regenerate initramfs." || echo "ERROR: Failed to regenerate initramfs."
  exit 1
fi

# --- Final message ---
$USE_ZENITY && zenity --info --text="✅ Hibernation successfully configured.\n\nYou may now reboot and test with:\n\nsystemctl hibernate" || {
  echo -e "\n✅ Hibernation successfully configured."
  echo -e "You may now reboot and test with: systemctl hibernate"
}
