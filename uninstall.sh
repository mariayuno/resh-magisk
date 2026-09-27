#!/system/bin/sh
# Runs on module removal — clean up files written outside $MODPATH
rm -f /data/adb/ksu/bin/resh
rm -f /data/adb/ssh/root/.profile
