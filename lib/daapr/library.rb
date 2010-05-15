require 'net/http'
class DAAPR
  class Library
    attr_reader :service, :host, :port
    
    def initialize(service)
      @service = service
      resolver = DNSSD::Service.new
      resolver.resolve service do |r|
        @host = r.target
        @port = r.port        
        break unless r.flags.more_coming?
      end
    end
    
    def songs(&block)
      r = get('/databases?session-id=' + session_id)
      return "Error fetching data" if r.code != '200'  
    
      db_list = DMAP.parse(r.body)
      db_index = db_list.mlcl[0].miid

      r = get("/databases/#{db_index}/items?meta=dmap.itemname,dmap.itemid,daap.songartist,daap.songalbum,dmap.containeritemid,com.apple.itunes.has-video,dmap.persistentid&session-id=#{session_id}")
      
      DMAP.parse(r.body).mlcl.each do |item|
        yield Song.new(item)
      end
    end
    
    def get(path)
      @net ||= begin
        n = Net::HTTP.new(host, port)
        n.set_debug_output $stderr
        n
      end
      @net.start do |s|
        s.get(path, {
          'Special-Client' => '2',
          'User-Agent' => 'Remote/1.3.3'
        })
      end
    end
    
    def session_id
      @session_id ||= begin
        r = get('/login?l=9517D5B528E11DFBDEAE12E1C50ADAAF&k=130CC11311FC384A91B39D5DB8C15491')
        s_id = DMAP.parse(r.body).mlid.to_s
        puts "Session ID: #{s_id}"
        s_id
      end
    end
    
    
    
    
    def name
      service.name
    end
    
  end
end