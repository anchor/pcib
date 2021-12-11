echo stty com0 >> $TARGET/etc/boot.conf
echo boot >> $TARGET/etc/boot.conf
sed -i 's,^\(tty00.*\)"/usr.*,\1"/usr/libexec/getty std.9600" xterm on  secure,' $TARGET/etc/ttys
