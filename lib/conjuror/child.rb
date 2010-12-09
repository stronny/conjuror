module Conjuror
	class Child
		class << self
			include LibRiverine::Output::Methods
		end
		attr_reader(:pid, :stdout, :stderr)

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
				# In a parent. Record the child's PID, manage the streams and detach() the child.
				@pid = pid
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
				#
				# Detach to avoid children's zombification
				Process.detach(pid)
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
				case testclass = command.class
					when String then
						debug("Running exec() with a string [#{command}]")
						exec(command)
					when Array then
						debug("Running exec() with an array #{command.inspect}")
						exec(*command)
					else
						error!("Wrong type of a command: #{testclass}, must be either String or Array")
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

	end
end
