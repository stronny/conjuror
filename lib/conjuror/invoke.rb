module Conjuror
	def self.invoke!(incantationfn)
		LibRiverine::Traps.install!(
			method(:signals) => [SIGHUP, SIGUSR1, SIGUSR2],
			method(:reap_child) => SIGCHLD,
			method(:down) => [SIGINT, SIGTERM, SIGQUIT],
			method(:coup_de_grace) => SIGEXIT
		)
		begin
			incantation = YAML.load_file(incantationfn)
		rescue Errno::ENOENT => e
			warn('Error reading the incantation: %s' % e.message)
			exit!(1)
		end
		@serial = 0
		@incantation = Incantation.new(incantation)
		@dropdead = false
		spawn_child()
		#
		# Main cycle

		@inbound = [$stdin] # FIXME

		until @dropdead do
			sleep(@incantation.sleep)
			for stream in @inbound do
				if buf = Streams.read(stream) then
					route_in(buf)
				end
			end unless @inbound.empty?
			if buf = Streams.read(@child.stdout) then
				route_out(buf)
			end
			if buf = Streams.read(@child.stderr) then
				route_err(buf)
			end
		end
	end
end
