run_in_target apt-get update 2>&1 | spin "Updating package lists"
run_in_target apt-get -y upgrade 2>&1 | spin "Installing available package updates"

