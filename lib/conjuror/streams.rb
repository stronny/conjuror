module Conjuror
	module Streams
		def self.read(stream)
			buf = nil
			return(buf) unless stream.kind_of?(IO)
			selected = select([stream], nil, nil, 0);
			if selected then
				begin
					buf = stream.readpartial(2 ** 16)
				rescue EOFError
				end
			end
			buf
		end
	end
end
