#!/system/bin/sh
# Runs after boot — re-ensure symlink survives reboots
MOD="/data/adb/modules/rexshell"
ln -sf "$MOD/files/bin/resh" /data/adb/ksu/bin/resh
chmod 755 /data/adb/ksu/bin/resh

# Re-write .profile in case it was wiped
SSH_HOME="/data/adb/ssh/root"
if ! grep -q rexshell "$SSH_HOME/.profile" 2>/dev/null; then
  cat > "$SSH_HOME/.profile" << 'PROFILE'
#!/bin/sh
[ -n "$REXSHELL_ACTIVE" ] && return 0
export REXSHELL_ACTIVE=1
exec /data/adb/modules/rexshell/files/bin/resh
PROFILE
  chmod 644 "$SSH_HOME/.profile"
fi
