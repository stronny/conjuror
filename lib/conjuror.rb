require('yaml')
require('libriverine')

module Conjuror
	include LibRiverine::Traps::Constants
end

require('conjuror/signals')
require('conjuror/routes')
require('conjuror/streams')
require('conjuror/incantation')
require('conjuror/child')
require('conjuror/invoke')
