module Conjuror
	class IncantationFailure < Exception; end
	class Incantation
		attr_reader(:sleep, :command, :allow_to_die_peacefully)

		def initialize(incantation)
			raise IncantationFailure("Please provide a Hash, not a #{incantation.class}") unless Hash == incantation.class
			raise IncantationFailure('Please specify a command to execute') unless incantation['command']
			@command = incantation['command']
			@sleep = (incantation['sleep'] or 0.1)

			@allow_to_die_peacefully = false
			@allow_to_die_peacefully = incantation['allow_to_die_peacefully']





		end
	end
end
