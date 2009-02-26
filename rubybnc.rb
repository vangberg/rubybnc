# RubyBNC Alpha 0.2-cvs - http://rubybnc.sf.net
# Copyright (C) 2003  Harry Vangberg
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

# Settings down here:

# Source - dont edit!
require "socket"
require "class/client.rb"
require "class/server.rb"
require "class/log.rb"
require "class/settings.rb"

$version = "rubybnc-a0.2r1"

Process.fork do
	Process.setsid

	puts ""
	puts "RubyBNC Alpha 0.2-cvs, Copyright (C) 2003 Harry Vangberg
	RubyBNC comes with ABSOLUTELY NO WARRANTY; This is free software, and
	you are welcome to redistribute it under certain conditions; Look in 
	'COPYRIGHT' for details."
	puts ""
	puts "Forking. Press [enter]"

settings = Settings.new("config.xml")
log = Log.new(settings.logmaxsize)

server = Server.new(log, settings)
client = Client.new(server, log, settings)
server.setclient client

serverthread = Thread.new {
	server.connect
}

clientthread = Thread.new {
	client.listen
}

serverthread.join
clientthread.join

end
