#! /bin/sh
### BEGIN INIT INFO
# Provides:          lxc-mountall
# Required-Start:    $local_fs
# Required-Stop:     $local_fs
# X-Start-Before:    postgresql apache apache2
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Mount all filesystems in an LXC container.
# Description:
### END INIT INFO

PATH=/sbin:/bin

case "$1" in
  start|"")
	mount -a
	;;
  restart|reload|force-reload)
	echo "Error: argument '$1' not supported" >&2
	exit 3
	;;
  stop)
	umount -a
	;;
  *)
	echo "Usage: $0 [start|stop]" >&2
	exit 3
	;;
esac

