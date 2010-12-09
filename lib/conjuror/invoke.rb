module Conjuror
	def self.invoke!(incantation)
		LibRiverine::Traps.install!(
			method(:signals) => [SIGHUP, SIGUSR1, SIGUSR2],
			method(:spaw_child) => SIGCHLD,
			method(:down) => [SIGINT, SIGTERM, SIGQUIT],
			method(:coup_de_grace) => SIGEXIT
		)
		@incantation = Incantation.new(incantation)
		@dropdead = false
		spawn_child()
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
