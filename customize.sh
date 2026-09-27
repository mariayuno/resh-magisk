# KernelSU customize.sh — runs at flash time
SKIPUNZIP=1
MOD="$MODPATH"

ui_print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
ui_print "  rexshell"
ui_print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Extract all required module files.
# SKIPUNZIP=1 means Magisk/KSU won't touch the zip — we own everything.
# module.prop MUST land in $MODPATH or KSU refuses to register the module.
unzip -o "$ZIPFILE" 'files/*' 'system/*' 'service.sh' 'module.prop' -d "$MOD" >&2
chmod -R 755 "$MOD/files/bin"

# Write .profile SSH hook
SSH_HOME="/data/adb/ssh/root"
mkdir -p "$SSH_HOME"
[ -f "$SSH_HOME/.profile" ] && ! grep -q rexshell "$SSH_HOME/.profile" && \
  cp "$SSH_HOME/.profile" "$SSH_HOME/.profile.bak"

cat > "$SSH_HOME/.profile" << 'PROFILE'
#!/bin/sh
[ -n "$REXSHELL_ACTIVE" ] && return 0
export REXSHELL_ACTIVE=1
exec /data/adb/modules/rexshell/files/bin/resh
PROFILE
chmod 644 "$SSH_HOME/.profile"

# Symlink resh into KSU bin (already in PATH for all root shells)
ln -sf "$MOD/files/bin/resh" /data/adb/ksu/bin/resh
chmod 755 /data/adb/ksu/bin/resh

ui_print "  ✓ resh → /data/adb/ksu/bin/resh (in PATH now)"
ui_print "  ✓ SSH auto-launch via .profile"
ui_print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
