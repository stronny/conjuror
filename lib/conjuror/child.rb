module Conjuror

	private

	def self.spawn_child()
		if @dropdead then
			debug('Asked to spawn the child, but the ending is near, so doing nothing')
			return(true)
		end
		@serial += 1
		@child = Child.new(@incantation.command)
		notice("Invoked a new child #{@child.pid} \##{@serial}")
	end

	class Child
		include LibRiverine::Output::Methods
		attr_reader(:pid, :stdout, :stderr, :time_started)

		# Command may be either an array or a string. See Kernel.exec to know the difference.
		#
		def initialize(command)
			#
			# Make the intertubes.
			@stdin = {}
			@stdin[:r], @stdin[:w] = IO.pipe()
			@stdout = {}
			@stdout[:r], @stdout[:w] = IO.pipe()
			@stderr = {}
			@stderr[:r], @stderr[:w] = IO.pipe()
			#
			# Fork the child.
			if pid = fork() then
				#
				# In a parent. Record the child's PID and started time, then manage the streams.
				@pid = pid
				@time_started = Time.now()
				#
				# Close the ends of the pipes we don't need
				for stream in [@stdin[:r], @stdout[:w], @stderr[:w]] do
					stream.close()
				end
				#
				# Save the ends of the pipes we do need
				@stdin = @stdin[:w]
				@stdout = @stdout[:r]
				@stderr = @stderr[:r]
				#
				# Make sure the child's STDIN is not buffered
				@stdin.sync = true
			else
				#
				# In a child. First manage the streams.
				for stream in [@stdin[:w], @stdout[:r], @stderr[:r]] do
					stream.close()
				end
				$stdin.reopen(@stdin[:r])
				$stdout.reopen(@stdout[:w])
				$stderr.reopen(@stderr[:w])
				$stdout.sync = true
				$stderr.sync = true
				#
				# And then run exec() with a class check.
				case command.class
					when String then
						debug("Running exec() with a string [#{command}]")
						exec(command)
					when Array then
						debug("Running exec() with an array #{command.inspect}")
						exec(*command)
					else
						exit!(Process.pid)
#						error!("Wrong class of a command: #{command.class}, must be either String or Array")
				end
			end
		end

		# Writes a string to child's STDIN
		#
		def write(buf)
			buf = buf.to_s unless String == buf.class
			@stdin.write(buf)
		end

		# Writes a string and a newline
		#
		def writeln(buf)
			write(buf)
			write("\n")
		end

		# Sends a specified signal to the child (TERM by default)
		#
		def kill(sig = SIGTERM)
			begin
				Process.kill(sig, @pid)
			rescue Errno::ESRCH
			end
		end

	end
end
