# Copyright (C) 2003 Harry Vangberg <harry@minignom.dk>
# This is free software publised under the GNU GPL. See the bundled 'COPYING'
# for more details.

class Log
	def initialize(maxsize)
		@log = Array.new
		@maxsize = maxsize.to_i
	end
	def push(text)
		if @log.size >= @maxsize then
			@log.delete_at(0)
			@log.push text
		else
			@log.push text
		end
	end
	def each(&block)
		@log.each(&block)
	end
	def empty
		@log = Array.new
	end
end
