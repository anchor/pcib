# Plugin management functions for PCIB.
#
#   This program is free software; you can redistribute it and/or modify it
#   under the terms of the GNU General Public License version 3, as
#   published by the Free Software Foundation.
#
#   This program is distributed in the hope that it will be useful, but
#   WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#   General Public License for more details.
#
#   You should have received a copy of the GNU General Public License along
#   with this program; if not, see <http://www.gnu.org/licences/>
#

# Load a plugin.
#
# Specify the path to the plugin relative to the `plugins` directory, like
# this:
#
#    load_plugin_or_die "cloud/ec2"
#
# If the specified plugin does not exist, then this function will print a
# fatal error and exit.  If you'd prefer to load the plugin and handle
# failure yourself, try load_plugin_if_exists() instead.
#
load_plugin_or_die() {
	local plugin="$1"
	
	if ! plugindir "$plugin" >/dev/null; then
		fatal "Plugin $plugin does not exist."
	fi
	
	load_plugin_if_exists "$plugin"

	if ! [ -e "$(plugindir "$plugin")/init.sh" ]; then
		fatal "Failed to load plugin ${plugin}: init.sh not found."
	fi
}

# Try to load a plugin, but don't get pissy if we can't.
#
# Specify the path to the plugin relative to the `plugins` directory, like
# this:
#
#    load_plugin_if_exists "cloud/ec2"
#
load_plugin_if_exists() {
	local plugin="$1"
	
	debug "Loading plugin $1"
	
	if [ "${PLUGINS[$plugin]+x}" ]; then
		debug "Plugin $plugin has been loaded already"
		return 0
	fi
	
	local plugindir="$(plugindir "$plugin")"
	
	if [ -e "${plugindir}/init.sh" ]; then
		. "${plugindir}/init.sh"
		register_plugin_tasks "$plugin"
	else
		debug "Plugin '$plugin' not found"
	fi
}

# Determine where a plugin lives on disk.
#
# Echoes the absolute directory where the given plugin could be found, if
# the plugin exists, or else echo nothing and return 1 (false).
#
# Usage:
#
#    plugindir <pluginname>
#
plugindir() {
	local plugin="$1"
	
	if [ -z "$plugin" ]; then
		fatal "No plugin name passed to plugindir().  This is a bug and should be reported."
	fi

	local plugindir="${ROOT}/plugins/${plugin}"
	
	if [ -d "$plugindir" ] && [ -e "${plugindir}/init.sh" ]; then
		echo "$plugindir"
		return 0
	else
		return 1
	fi
}

# Get the name of a plugin from a path.
#
# Echoes the name of the plugin referred to by the given path.
#
# Usage:
#
#    plugin_from_path <path>
#
# If the path given is not recognised as one which refers to a known plugin
# or a file therein, this function will trigger a fatal error.
#
plugin_from_path() {
	local path="$1"
	
	while ! [ -e "${path}/init.sh" ] && [ "$path" != "/" ] && [ "$path" != "/" ]; do
		debug "plugin_from_path: Checking $path for init.sh"
		path="$(dirname "$path")"
	done
	
	if [ "$path" = "/" ] || [ "$path" = "." ]; then
		fatal "$1 was not recognised as a path in a PCIB plugin."
	fi
	
	echo "$path" | sed "s%^$ROOT/plugins/%%"
}

# Get the full path to a file within a plugin.
#
# Usage:
#
#    plugin_file <plugin> <file>
#
# The <file> should be relative to the `files` subdirectory within the
# plugin.  If the file does not exist, a freak out will occur.
#
plugin_file() {
	file="${ROOT}/plugins/$1/files/$2"
	
	if ! [ -e "$file" ]; then
		fatal "plugin_file called for non-existent file: $file"
	fi
	
	echo "$file"
}
