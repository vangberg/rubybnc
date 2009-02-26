# Copyright (C) 2003 Harry Vangberg <harry@minignom.dk>
# This is free software publised under the GNU GPL. See the bundled 'COPYING'
# for more details.

require "rexml/document"
include REXML

class Settings
	def initialize(configfile)
		@channels = Array.new
		config = (Document.new File.new(configfile)).root
		@bncport = config.elements["/root/rubybnc"].attributes["port"]
		@password = config.elements["/root/rubybnc/password"].text
		@versionreply = config.elements["/root/rubybnc/versionreply"].text
		@nick = config.elements["/root/irc/nick"].text
		@realname = config.elements["/root/irc/nick"].attributes["realname"]
		@server = config.elements["/root/irc/server"].text
		@port = config.elements["/root/irc/server"].attributes["port"]
		temp = config.elements.to_a("/root/irc/channels/channel")
		temp.each { |x| @channels.push(x.text) }
		@logmaxsize = config.elements["/root/log/maxsize"].text
	end
	
	attr_reader :nick, :channels, :server, :port, :bncport, :password, :versionreply, :realname, :logmaxsize

	attr_writer :nick

	def channels_each(&block)
		@channels.each(&block)
	end

	def channels_push(channel)
		@channels.push(channel) unless @channels.include?(channel)
	end

	def channels_del(channel)
		@channels.delete($1)
	end
end
