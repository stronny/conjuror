module Conjuror
	private

	def self.signame(sig = nil); LibRiverine::Traps.signame(sig); end

	def self.down(sig = nil)
		puts("Going down on #{signame(sig)}")
		Process.kill(SIGINT, @child.pid)
		@dropdead = true
	end

	def self.coup_de_grace(sig = nil)
		puts("Just before the end on #{signame(sig)}")
	end

	def self.signals(sig = nil)

		return(true) unless @options['signals']

		if @options['signals']['HUP'] then

			for action in @options['signals']['HUP'] do
				case action['type']
					when 'write' then
						p(@child.stdin.write(action['data'] + "\n"))
					when 'kill' then
						Process.kill(action['data'], @child.pid)
				end
			end

		end

	end

	def self.spawn_child(sig = nil)
		if @dropdead then
			debug("Asked to spawn the child on #{signame(sig)}, but the ending is near, so doing nothing")
			return(true)
		end
		@child = Child.new(@options)
		puts("Invoked a new child #{@child.pid} on #{signame(sig)}")
#		@sockets = {
#			$stdin        => method(:from_in),
#			@child.stdout => method(:from_out),
#			@child.stderr => method(:from_err)
#		}
	end

end
