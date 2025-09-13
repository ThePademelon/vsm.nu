#!/usr/bin/env nu

export def "vsm list" [
	--colorless (-c) # Prints the status without ANSI colors
] {
	let enabled = vsm list enabled --colorless=$colorless
	let enabled_names = $enabled | each { $in.name }

	let installed = vsm list installed | where { $enabled_names not-has $in.name }

	$enabled | append $installed
}

# Lists services that are enabled (this is distinct from 'up')
export def "vsm list enabled" [
	--colorless (-c) # Prints the status without ANSI colors
] {
	sudo sv status /var/service/*
	| parse '{status}: {path}: {unparsed}'
	| each {|x| match $x.status {
			'run' => {
				let run_parse = $x.unparsed | parse '(pid {pid}) {uptime}s{rest}' | first;
				{
					status: ($'(ansi green)running(ansi reset)'),
					name: ($x.path | path basename),
					pid: $run_parse.pid,
					uptime: ($run_parse.uptime + "sec" | into duration)
				}
			},
			'fail' => {
				{
					status: ($'(ansi red)fail(ansi reset)'),
					name: ($x.path | path basename),
					error: ($'(ansi red)($x.unparsed)(ansi reset)')
				}
			},
			'down' => {
				{
					status: ($'(ansi blue)down(ansi reset)'),
					name: ($x.path | path basename),
				}
			},
		}
	}
	| if $colorless { $in | update status { ansi strip } } else $in
}

# Lists all installed services
export def "vsm list installed" [] {
	ls /etc/sv/ | each {|x| {
			status:'installed'
			name:($x.name | path basename)
		}
	}
}

# Enables a service by name
export def "vsm enable" [name: string] {
	if ($name | str trim | is-empty) { error make { msg: 'Name was empty' } }
	let $target = '/etc/sv/' | path join $name
	if not ($target | path exists) { error make { msg: $"Can't find installed service with name ($name)" } }
	if ('/var/service/' | path join $name | path exists) { error make { msg: "Service is already enabled" } }
	sudo ln -s $target /var/service/
}

# Disables a service by name
export def "vsm disable" [name: string] {
	if ($name | str trim | is-empty) { error make { msg: 'Name was empty' } }
	let $target = '/var/service/' | path join $name
	if not ($target | path exists) { error make { msg: $"Can't find enabled service with name ($name)" } }
	sudo rm $target
}
