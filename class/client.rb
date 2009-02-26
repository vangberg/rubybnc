# Copyright (C) 2003 Harry Vangberg <harry@minignom.dk>
# This is free software publised under the GNU GPL. See the bundled 'COPYING'
# for more details.

class Client
	def initialize(server, log, settings)
		@server = server
		@log = log
		@settings = settings
		@conn = nil
		@firstconn = true
		@authed = false
	end
	def put(text)
		@conn.puts text
	end
	def connected?
		if @conn && !@conn.closed? && authed? then
			true
		else
			false
		end
	end
	def auth(passwd)
		if @settings.password == passwd then
			@authed = true
		else
			@authed = false
		end
	end
	def authed?
		@authed
	end
	def listen
		@clisten = TCPServer.open(@settings.bncport)	
		while true
			@conn = @clisten.accept
			validate()
		end
	end
	def validate	
		@firstconn = true
		@authed = false

		while line = @conn.gets
			line.chomp!("\r\n")
			if @firstconn 
				if line =~ /^PASS (\S+)/
					if auth($1) then
						put ":rubybnc.localhost 001 #{@settings.nick} :Welcome to RubyBNC proxy #{@settings.nick}"
						put ":rubybnc.localhost 002 #{@settings.nick} :Your host is rubybnc.localhost, running #{$version}"	
						put ":rubybnc.localhost 003 #{@settings.nick} :This server was created someday :D"
						put ":rubybnc.localhost 004 #{@settings.nick} :rubybnc.localhost #{$version} aAbBcCdDeEfFGhHiIjkKlLmMnNopPQrRsStUvVwWxXyYzZ0123459*@ bcdefFhiIklmnoPqstv"
						put ":rubybnc.localhost 375 #{@settings.nick} :- rubybnc.localhost Message of the Day"
							
							motd = File.open("motd", "r")
						
							motd.each { |x| put ":rubybnc.localhost 372 #{@settings.nick} :- #{x}" }
							motd.close
						put ":rubybnc.localhost 376 #{@settings.nick} :End of MOTD command."
						@settings.channels_each { |x|
							put ":#{@settings.nick}!(null) JOIN #{x}"
							@server.put "topic #{x}"	
							@server.put "names #{x}"	
						}
						Kernel.sleep 2
						@settings.channels_each { |x| put ":-RubyBNC!(null) PRIVMSG #{x} :== spawning log ==" }
						@log.each { |x| put x }	
						@settings.channels_each { |x| put ":-RubyBNC!(null) PRIVMSG #{x} :== log finished ==" }
						@firstconn = false
					else
						put "Wrong password. Disconnecting."
						close
						break
					end	
				else
					put "No password specified. Disconnectiong."
					close
					break
				end
			else
				if authed?
					case line
					when /^QUIT :disc/i
						@server.close
						Kernel.exit
					when /^QUIT/i
						put "ERROR :Closing Link: #{@settings.nick}(Client Quit)"
						close
						break
					else	
						@server.put line
					end
				end
			end
		end
		@log.empty unless !authed?
	end
	def close
		@conn.close
	end
end
