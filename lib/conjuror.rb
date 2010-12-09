require('yaml')
require('libriverine')

module Conjuror
	class << self
		include LibRiverine::Output::Methods
	end
	include LibRiverine::Traps::Constants
end

require('conjuror/signals')
require('conjuror/routes')
require('conjuror/streams')
require('conjuror/incantation')
require('conjuror/child')
require('conjuror/invoke')
