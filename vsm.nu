#!/usr/bin/env nu

export def "vsm list" [] {
	# TODO: Join with below list
	let installed = ls /etc/sv/

	let enabled = sudo sv status /var/service/*
	| parse '{status}: {path}: {details}'
	| upsert name {|s| $s.path | path basename }
	| upsert pid {|s| if $s.status == 'run' { $s.details | parse '(pid {pid}){rest}' | first | get pid } else 'N/A' }
	| upsert uptime {|s| if $s.status == 'run' { ($s.details | parse '(pid {pid}) {uptime}s{rest}' | first | get uptime) + 's' } else 'N/A' }
	| upsert error {|s| if $s.status == 'fail' { $'(ansi red)($s.details)(ansi reset)' } else 'N/A' }
	| upsert status {|s| match $s.status {
		'run' => $'(ansi green)running(ansi reset)',
		'fail' => $'(ansi red)fail(ansi reset)',
		'down' => $'(ansi blue)down(ansi reset)',
		_ => $s.status
		}
	}
	| reject details
	| reject path

	print $enabled
}
