module Conjuror
	private

	def self.signame(sig = nil); LibRiverine::Traps.signame(sig); end

	def self.down(sig = nil)
		notice("Going down on #{signame(sig)}")
		@child.kill(SIGINT) if @child
		@dropdead = true
	end

	def self.coup_de_grace(sig = nil)
		debug("Just before the end on #{signame(sig)}")
	end

	def self.signals(sig = nil)
		return(true) unless @options['signals']
		if @options['signals']['HUP'] then
			for action in @options['signals']['HUP'] do
				case action['type']
					when 'write' then
						p(@child.stdin.write(action['data'] + "\n"))
					when 'kill' then
						@child.kill(action['data']) if @child
				end
			end
		end
	end

	#
	# Reap the dead child, getting its exit status. Exit also if conditions are met.
	def self.reap_child(sig = nil)
		return(nil) unless @child
		Process.waitpid(@child.pid, Process::WNOHANG)
		uptime = Time.now() - @child.time_started
		status = $?.exitstatus
		notice("Reaped the child #{@child.pid} \##{@serial} $?=#{status} alive for #{uptime}s.")
		if (@incantation.allow_to_die_peacefully and (0 == status)) then
			notice("Exiting with the child.")
			exit(0)
		end
		spawn_child()
	end
end
