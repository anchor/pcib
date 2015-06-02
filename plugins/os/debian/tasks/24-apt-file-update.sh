install_packages_in_target apt-file 2>&1 | spin "Installing apt-file"

run_in_target apt-file update 2>&1 | \
     spin "Updating apt-file cache for build sources.list"
