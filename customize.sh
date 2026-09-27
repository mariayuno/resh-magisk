# KernelSU customize.sh — runs at flash time
SKIPUNZIP=1

# Guard against Magisk/KSU not providing MODPATH — never operate on /
if [ -z "$MODPATH" ]; then
  ui_print "ERROR: MODPATH is empty — aborting"
  exit 1
fi
MOD="$MODPATH"

ui_print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
ui_print "  rexshell"
ui_print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

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
