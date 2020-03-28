#usermod -p $(echo "root" | encrypt -b 6) root
usermod -p - root
