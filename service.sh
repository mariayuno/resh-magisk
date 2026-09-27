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

  # Wrap every ELF binary in /system/bin that fails to execute due to
  # missing/outdated system libs. Our bundled libs load first via
  # LD_LIBRARY_PATH — the real system binary still runs underneath.
  for bin in /system/bin/*; do
    tool="$(basename "$bin")"
    [ -f "$KSU_BIN/$tool" ] && continue   # already have an override
    # probe: if the binary links fine, skip it; only wrap broken ones
    LD_LIBRARY_PATH="$MOD_LIB:/system/lib64:/vendor/lib64"       "$bin" --version >/dev/null 2>&1 && continue || true
    # double-check it IS an ELF (skip scripts, etc.)
    file "$bin" 2>/dev/null | grep -q ELF || continue
    printf '#!/system/bin/sh
export LD_LIBRARY_PATH="%s:/system/lib64:/vendor/lib64"
exec "%s" "$@"
'       "$MOD_LIB" "$bin" > "$KSU_BIN/$tool"
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
