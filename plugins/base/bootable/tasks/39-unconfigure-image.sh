rm -f "$TARGET"/etc/sysconfig/network-scripts/ifcfg-eth*

if [ -d "$TARGET"/etc/udev/rules.d ]; then
	>"$TARGET"/etc/udev/rules.d/70-persistent-net.rules
fi

if [ -d "$TARGET"/lib/udev/rules.d ]; then
	>"$TARGET"/lib/udev/rules.d/75-persistent-net-generator.rules
fi

set_hostname avf
