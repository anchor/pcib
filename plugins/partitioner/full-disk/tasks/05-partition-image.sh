sfdisk -f -u S "$BLOCK_DEVICE" &>/dev/null <<EOF
2048,,83
EOF

declare -A PARTITIONS

PARTITIONS[/]="$BLOCK_DEVICE"p1
