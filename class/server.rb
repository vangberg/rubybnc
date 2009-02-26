# Copyright (C) 2003 Harry Vangberg <harry@minignom.dk>
# This is free software publised under the GNU GPL. See the bundled 'COPYING'
# for more details.

class Server
	def initialize(log, settings)
		@log = log
		@settings = settings
		@conn = nil
	end
	def setclient(client)
		@client = client
	end
	def put(text)
		@conn.puts text
	end
	def connect
		@conn = TCPSocket.open(@settings.server, @settings.port)
		put "NICK #{@settings.nick}"
		put "USER #{@settings.nick} rubybnc #{@settings.nick} :#{@settings.realname}"	
		validate()
	end
	def validate
		while line = @conn.gets
			line.chomp!("\r\n")

			if !@client.connected? then
				if line =~ /^:\S+ 433 .*/i
					alt = @settings.nick + "_"
					put "NICK #{alt}"
					@settings.nick = alt
				end
			end
			
			case line 
			when /^:\S+ (376|422) #{@settings.nick}/i
				@settings.channels_each { |x| put "JOIN #{x}" }	
			when /^:#{@settings.nick}!\S+@\S+ JOIN :(\S+)/i
				@settings.channels_push($1)
			when /^:#{@settings.nick}!\S+@\S+ PART (\S+)/i
				@settings.channels_del($1)
			when /^:#{@settings.nick}!\S+@\S+ NICK (\S+)/i
				temp = $1.delete ":"
				@settings.nick = temp
			when /^:(\S+)!\S+@\S+ PRIVMSG #{@settings.nick} :\001VERSION\001/
				put "NOTICE #{$1} :\001VERSION #{@settings.versionreply}\001"
			when /^PING (\S+)/i
				put "PONG #{$1}"
			end

			if @client.connected?
				@client.put line
			else
				@log.push line
			end
		end
	end
	def close
		@conn.close
	end
end
