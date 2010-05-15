require 'rubygems'

gem 'dnssd'
gem 'dmap-ng'
require 'dmap'
require 'dnssd'

$:.unshift(File.join(File.dirname(__FILE__), 'daapr'))
require 'library'
require 'song'
Thread.abort_on_exception = true
trap 'INT'  do exit end
trap 'TERM' do exit end
  
  
class DAAPR
  
  class << self
    def monitor
      browser = DNSSD::Service.new
      services = {}
      browser.browse '_daap._tcp' do |reply|
        services[reply.fullname] = reply
        next if reply.flags.more_coming?

        services.sort_by do |_, service|
          [(service.flags.add? ? 0 : 1), service.fullname]
        end.each do |_, service|
          
          library = Library.new(service)          
          service.flags.add? ? @@register.call(library) : @@unregister.call(library)
        end

        services.clear
      end

    end
    
    def register(&block)
      @@register = block
    end
    
    def unregister(&block)
      @@unregister = block
    end
  end
  
  
end

DAAPR.register do |library|
  library.songs do |s|
    puts s.title
  end
end

DAAPR.unregister do |library|
  
end
DAAPR.monitor