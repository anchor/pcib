echo stty com0 115200 >> ${TARGET}/etc/boot.conf
sed -i 's,^tty00 .*,tty00 "/usr/libexec/getty std.115200" xterm on  secure,' ${TARGET}/etc/ttys
