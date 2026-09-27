#!/system/bin/sh
MOD="/data/adb/modules/rexshell"

[ -d "$MOD" ] || exit 0

KSU_BIN="/data/adb/ksu/bin"
if [ -d "$KSU_BIN" ]; then
  ln -sf "$MOD/files/bin/resh" "$KSU_BIN/resh"
  chmod 755 "$KSU_BIN/resh"
  # LD_LIBRARY_PATH set in resh covers all child processes — no wrapping needed
fi

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
