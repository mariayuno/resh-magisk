#!/system/bin/sh
# Runs on module removal — clean up files written outside $MODPATH
# Safe: checks ownership before touching anything

# Remove symlink only if it points into our module dir
SYMLINK="/data/adb/ksu/bin/resh"
if [ -L "$SYMLINK" ]; then
  target=$(readlink "$SYMLINK" 2>/dev/null || true)
  case "$target" in
    /data/adb/modules/rexshell/*) rm -f "$SYMLINK" ;;
    *) echo "uninstall: $SYMLINK points to $target — not ours, leaving it" ;;
  esac
fi

# Restore pre-existing .profile if we backed it up;
# otherwise only remove if the file is actually ours
PROFILE="/data/adb/ssh/root/.profile"
BACKUP="${PROFILE}.bak"
if [ -f "$BACKUP" ]; then
  mv "$BACKUP" "$PROFILE"
elif [ -f "$PROFILE" ] && grep -q "rexshell" "$PROFILE" 2>/dev/null; then
  rm -f "$PROFILE"
fi
