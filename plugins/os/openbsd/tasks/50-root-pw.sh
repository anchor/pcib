#usermod -p $(echo "root" | encrypt -b 6) root
run_in_target usermod -p - root
