module Conjuror
	private

	def self.route_in(buf)
		@child.write(buf)
		# FIXME all the others too
	end

	def self.route_out(buf)
		$stdout.write(buf)
		# FIXME all the others too
	end

	def self.route_err(buf)
		$stderr.write(buf)
		# FIXME all the others too
	end
end
