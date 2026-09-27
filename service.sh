#!/system/bin/sh
# Runs after boot — re-ensure symlink and .profile survive reboots
MOD="/data/adb/modules/rexshell"

# Don't run if module dir is gone (mid-uninstall, etc.)
[ -d "$MOD" ] || exit 0

KSU_BIN="/data/adb/ksu/bin"
MOD_LIB="$MOD/lib"
if [ -d "$KSU_BIN" ]; then
  ln -sf "$MOD/files/bin/resh" "$KSU_BIN/resh"
  chmod 755 "$KSU_BIN/resh"

  # Wrap any system binary that may be broken due to missing/outdated
  # system libs — our bundled libs in $MOD_LIB take precedence via
  # LD_LIBRARY_PATH, but the binary itself still comes from /system/bin.
  # Add more tools to this list as needed.
  for tool in curl wget ssh git; do
    bin="/system/bin/$tool"
    [ -x "$bin" ] || continue
    [ -f "$KSU_BIN/$tool" ] && continue  # already wrapped or overridden
    cat > "$KSU_BIN/$tool" << WRAPPER
#!/system/bin/sh
export LD_LIBRARY_PATH="$MOD_LIB:/system/lib64:/vendor/lib64"
exec $bin "\$@"
WRAPPER
    chmod 755 "$KSU_BIN/$tool"
  done
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
