sources_list="$TARGET"/etc/apt/sources.list

cat >"$sources_list" <<EOF
deb ${OPTS[apt-mirror]} $release_name main
deb ${OPTS[apt-mirror]} $release_name-updates main
deb http://security.debian.org/ $release_name/updates main
EOF
