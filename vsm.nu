#!/usr/bin/env nu

export def "vsm list" [] {
	let installed = ls /etc/sv/ | each {|x| { name:($x.name | path basename) } }

	let enabled = sudo sv status /var/service/*
	| parse '{status}: {path}: {details}'
	| upsert name {|s| $s.path | path basename }
	| upsert pid {|s| if $s.status == 'run' { $s.details | parse '(pid {pid}){rest}' | first | get pid } }
	| upsert uptime {|s| if $s.status == 'run' { ($s.details | parse '(pid {pid}) {uptime}s{rest}' | first | get uptime) + 's' } }
	| upsert error {|s| if $s.status == 'fail' { $'(ansi red)($s.details)(ansi reset)' } }
	| upsert status {|s| match $s.status {
		'run' => $'(ansi green)running(ansi reset)',
		'fail' => $'(ansi red)fail(ansi reset)',
		'down' => $'(ansi blue)down(ansi reset)',
		_ => $s.status
		}
	}
	| reject details
	| reject path

	print ($enabled | join -o $installed name | upsert status {|x| if $x.status == null { 'installed' } else { $x.status } })
}

export def "vsm enable" [name: string] {
	let $target = '/etc/sv/' | path join $name
	if not ($target | path exists) { error make { msg: $"Can't find installed service with name ($name)" } }
	sudo ln -s $target /var/service/
}

export def "vsm disable" [name: string] {
	let $target = '/var/service/' | path join $name
	if not ($target | path exists) { error make { msg: $"Can't find enabled service with name ($name)" } }
	sudo rm $target
}
