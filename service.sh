#!/system/bin/sh
# Runs after boot — re-ensure symlink and .profile survive reboots
MOD="/data/adb/modules/rexshell"

# Don't run if module dir is gone (mid-uninstall, etc.)
[ -d "$MOD" ] || exit 0

KSU_BIN="/data/adb/ksu/bin"
if [ -d "$KSU_BIN" ]; then
  ln -sf "$MOD/files/bin/resh" "$KSU_BIN/resh"
  chmod 755 "$KSU_BIN/resh"
fi

# Re-write .profile only if it's missing or no longer contains our hook
SSH_HOME="/data/adb/ssh/root"
PROFILE="$SSH_HOME/.profile"
if ! grep -q "rexshell" "$PROFILE" 2>/dev/null; then
  mkdir -p "$SSH_HOME"
  cat > "$PROFILE" << 'PROFILE'
#!/bin/sh
[ -n "$REXSHELL_ACTIVE" ] && return 0
export REXSHELL_ACTIVE=1
exec /data/adb/modules/rexshell/files/bin/resh
PROFILE
  chmod 644 "$PROFILE"
fi
