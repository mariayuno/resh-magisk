# KernelSU customize.sh — runs at flash time
SKIPUNZIP=1

if [ -z "$MODPATH" ]; then
  ui_print "ERROR: MODPATH is empty — aborting"
  exit 1
fi
MOD="$MODPATH"

RESH="/data/media/0/resh"
TPFX="$RESH/usr"

ui_print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
ui_print "  rexshell"
ui_print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Full persistent prefix under /data/media/0/resh (real ext4, exec-capable)
mkdir -p \
  "$RESH/bin" "$RESH/tmp" \
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

# Install keyring so first 'resh-pkg update' works without --allow-insecure
KEYRING_SRC="$MOD/files/etc/termux-keyring.gpg"
KEYRING_DST="$TPFX/etc/apt/trusted.gpg.d/termux-keyring.gpg"
[ -f "$KEYRING_SRC" ] && [ ! -f "$KEYRING_DST" ] && cp "$KEYRING_SRC" "$KEYRING_DST" && ui_print "  ✓ keyring installed"

ui_print "  ✓ persistent prefix: $RESH"

unzip -o "$ZIPFILE" 'files/*' 'system/*' 'service.sh' 'module.prop' -d "$MOD" >&2
chmod -R 755 "$MOD/files/bin"

# SSH auto-launch
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

KSU_BIN="/data/adb/ksu/bin"
if [ -d "$KSU_BIN" ]; then
  ln -sf "$MOD/files/bin/resh" "$KSU_BIN/resh"
  chmod 755 "$KSU_BIN/resh"
  ui_print "  ✓ resh → $KSU_BIN/resh"
else
  ui_print "  ⚠ $KSU_BIN not found — skipping symlink"
fi

ui_print "  ✓ SSH auto-launch via .profile"

# Seed user config stub
USER_ZSH="$RESH/config/user.zsh"
mkdir -p "$RESH/config"
if [ ! -f "$USER_ZSH" ]; then
  cat > "$USER_ZSH" << 'STUB'
# /data/media/0/resh/config/user.zsh  (also visible at /sdcard/resh/config/user.zsh)
# Persists across resh updates and reflashes.
#
# Examples:
#   alias ll='eza -la'
#   export EDITOR=nvim
#   resh-pkg install neovim
#
# Drop scripts in /data/media/0/resh/bin/ — they're in PATH automatically.
STUB
  ui_print "  ✓ user config: $USER_ZSH"
fi

ui_print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
