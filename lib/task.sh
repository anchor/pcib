# Task management functions for PCIB.
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

# Register a new task from a plugin.
#
# Pass this function the name of a plugin and a task and it will be added to
# the list of tasks that will be run.
#
# Usage:
#
#    register_task <plugin> <task>
#
# Note that <task> must be of the form "NN<name>", where each `N` is a
# digit from 0 to 9, and <name> is any string.  There must exist a file
# within the specified plugin's directory named "tasks/<task>", which will
# be sourced when the task is run.
#
# Note also that <task> must be unique within all registered tasks; if a
# task with the same name already exists, it is a fatal error.  You *can*
# have multiple tasks with the same <name>, as long as their ordering is
# different.
#
register_task() {
	local plugin="$1"
	local task="$2"
	
	if [ -z "$plugin" ]; then
		fatal "No plugin name passed to register_task.  Please report a bug."
	fi
	
	if [ -z "$task" ]; then
		fatal "No task name specified.  Please report a bug."
	fi
	
	if ! [[ "$task" =~ ^[0-9][0-9][A-Za-z0-9_-]+\.sh$ ]]; then
		fatal "Task name '$task' is not valid.  Please report a bug."
	fi
	
	local taskfile="$(plugindir "$plugin")/tasks/$task"
	
	debug "Registering '$taskfile' to run '$task'"
	
	if ! [ -e "$taskfile" ]; then
		fatal "Task filename '$taskfile' does not exist.  Please report a bug."
	fi

	if [ -n "${TASKS["$task"]}" ]; then
		error "A task named '$task' has already been registered."
		fatal "This may be a bug, or you may need to revise the set of plugins you have loaded."
	fi
	
	TASKS["$task"]="$taskfile"
}

# Register all of the task files in the specified plugin.
#
# Usage:
#
#    register_plugin_tasks <plugin>
#
# Given a plugin name, <plugin>, which is located in `plugins/<plugin>`,
# register all regular files in `plugins/<plugin>/tasks` which look like
# `[0-9][0-9]*.sh` as tasks.
#
register_plugin_tasks() {
	local plugin="$1"
	local plugindir="$(plugindir "$plugin")" || true
	
	debug "register_plugin_tasks $plugin"
	debug "Looking for tasks in ${plugindir}/tasks"
	
	if [ -z "$plugindir" ]; then
		fatal "Unknown plugin '$plugin' passed to register_plugin_tasks.  Please report a bug."
	fi
	
	for file in "${plugindir}/tasks/"[0-9][0-9]*.sh; do
		if [ -f "$file" ]; then
			register_task "$plugin" "$(basename "$file")"
		fi
	done
}

# Check if a task with a given name is already registered.
#
# Usage:
#
#    task_is_registered <name>
#
# Returns 0 (true) if a task with the given name (that is, the name of the
# task without the leading NN) already exists, or 1 (false) if it doesn't.
#
task_is_registered() {
	echo "${!TASKS[*]}" | egrep -q "(^| )[0-9][0-9]${1}( |$)"
}

# Run all of the registered tasks.  We need to sort them first, because the
# tasks have just been jammed into the TASKS hash willy-nilly.
#
# Usage:
#
#    run_tasks
#
run_tasks() {
	for t in $(tasklist); do
		local taskfile="${TASKS[$t]}"
		
		if [ -z "$taskfile" ]; then
			fatal "Can't happen: didn't get a task file for '$t' out of \$TASKS.  Please report a bug."
		fi
		
		if ! [ -e "$taskfile" ]; then
			fatal "Shouldn't happen: task file '$taskfile' does not exist.  Please report a bug."
		fi
		
		info "Running task: $(basename "$taskfile")"
		debug "Task file is $taskfile"
		. "$taskfile"
	done
}

# Produce the list of task names to be run, in order of their desired execution.
#
# The function of a thousane uses.
#
# Usage:
#
#    tasklist
#
tasklist() {
	for t in "${!TASKS[@]}"; do echo "$t"; done | sort
}
