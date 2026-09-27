# KernelSU customize.sh — runs at flash time
SKIPUNZIP=1

# Guard against Magisk/KSU not providing MODPATH — never operate on /
if [ -z "$MODPATH" ]; then
  ui_print "ERROR: MODPATH is empty — aborting"
  exit 1
fi
MOD="$MODPATH"

RESH_HOME="/sdcard/resh"

ui_print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
ui_print "  rexshell"
ui_print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Persistent user dir — never wiped on update
mkdir -p "$RESH_HOME/config" "/data/media/0/resh/bin"

# Private rexshell package prefix — survives module updates
RESH_PKG="/data/adb/resh"
# Termux .deb packages embed paths like /data/data/com.termux/files/usr/...
# We redirect their instdir to $RESH_PKG so that layout is preserved correctly.
TPFX="$RESH_PKG/data/data/com.termux/files/usr"
mkdir -p \
  "$RESH_PKG/bin" "$RESH_PKG/lib" "$RESH_PKG/tmp" \
  "$TPFX/bin" "$TPFX/lib" \
  "$TPFX/etc/apt/apt.conf.d" \
  "$TPFX/etc/apt/sources.list.d" \
  "$TPFX/etc/apt/trusted.gpg.d" \
  "$TPFX/var/lib/apt/lists/partial" \
  "$TPFX/var/lib/apt/lists/auxfiles" \
  "$TPFX/var/cache/apt/archives/partial" \
  "$TPFX/var/lib/dpkg/info" \
  "$TPFX/var/lib/dpkg/updates" \
  "$TPFX/var/lib/dpkg/alternatives" \
  "$TPFX/var/log/apt"
[ -f "$TPFX/var/lib/dpkg/status" ]    || touch "$TPFX/var/lib/dpkg/status"
[ -f "$TPFX/var/lib/dpkg/available" ] || touch "$TPFX/var/lib/dpkg/available"

# Install keyring from module bundle (if present) so 'resh-pkg update' works immediately
KEYRING_SRC="$MOD/files/etc/termux-keyring.gpg"
KEYRING_DST="$TPFX/etc/apt/trusted.gpg.d/termux-keyring.gpg"
if [ -f "$KEYRING_SRC" ] && [ ! -f "$KEYRING_DST" ]; then
  cp "$KEYRING_SRC" "$KEYRING_DST"
  ui_print "  ✓ termux keyring installed"
fi

ui_print "  ✓ persistent prefix: $RESH_PKG"
ui_print "  ✓ user config dir:   $RESH_HOME"

# Extract all required module files.
# SKIPUNZIP=1 means Magisk/KSU won't touch the zip — we own everything.
# module.prop MUST land in $MODPATH or KSU refuses to register the module.
unzip -o "$ZIPFILE" 'files/*' 'system/*' 'service.sh' 'module.prop' -d "$MOD" >&2
chmod -R 755 "$MOD/files/bin"

# Write .profile SSH hook — back up any pre-existing one that isn't ours
SSH_HOME="/data/adb/ssh/root"
mkdir -p "$SSH_HOME"
PROFILE="$SSH_HOME/.profile"
if [ -f "$PROFILE" ] && ! grep -q "rexshell" "$PROFILE" 2>/dev/null; then
  cp "$PROFILE" "${PROFILE}.bak"
fi

cat > "$PROFILE" << 'PROFILE'
#!/bin/sh
[ -n "$REXSHELL_ACTIVE" ] && return 0
export REXSHELL_ACTIVE=1
exec /data/adb/modules/rexshell/files/bin/resh
PROFILE
chmod 644 "$PROFILE"

# Symlink resh into KSU bin — verify target path is sane before linking
KSU_BIN="/data/adb/ksu/bin"
if [ -d "$KSU_BIN" ]; then
  ln -sf "$MOD/files/bin/resh" "$KSU_BIN/resh"
  chmod 755 "$KSU_BIN/resh"
  ui_print "  ✓ resh → $KSU_BIN/resh (in PATH now)"
else
  ui_print "  ⚠ $KSU_BIN not found — skipping symlink (KSU not installed?)"
fi

ui_print "  ✓ SSH auto-launch via .profile"
ui_print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Seed user config stub if it doesn't exist yet
USER_ZSH="$RESH_HOME/config/user.zsh"
if [ ! -f "$USER_ZSH" ]; then
  cat > "$USER_ZSH" << 'STUB'
# /sdcard/resh/config/user.zsh
# Your personal config — persists across resh updates and reflashes.
# Sourced after all module config, so you can override anything.
#
# Examples:
#   alias ll='eza -la'
#   export EDITOR=nvim
#   resh-pkg install neovim        # install extra packages
#
# Drop personal scripts in /sdcard/resh/bin/ (via file manager) — they're executable
# because resh accesses them at /data/media/0/resh/bin/ (real ext4, bypasses FUSE).
# Survive everything including /data wipes.
STUB
  ui_print "  ✓ user config stub: $USER_ZSH"
fi
