#!/system/bin/sh
# Bind our big hosts over the system hosts (KernelSU Next won't magic-mount a single /system/etc file reliably)
MODDIR=${0%/*}
HOSTS="$MODDIR/system/etc/hosts"
[ -f "$HOSTS" ] || exit 0
chmod 644 "$HOSTS"
chcon u:object_r:system_file:s0 "$HOSTS" 2>/dev/null
mountpoint -q /system/etc/hosts && umount -l /system/etc/hosts 2>/dev/null
mount -o bind "$HOSTS" /system/etc/hosts
