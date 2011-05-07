class DynDNSimple
  def self.refresh!
    @settings = Settings.new
  
    DNSimple::Client.username = @settings.dnsimple_username
    DNSimple::Client.password = @settings.dnsimple_password

    @log = Logger.new( File.join(APP_ROOT, 'log', 'dyn-dnsimple.log'), 'daily' )
    @log.level = Logger::INFO

    EM::HttpRequest.new('http://icanhazip.com').get.callback { |http|
      @settings.current_ip = http.response.strip!
      @settings.save_to_config!

      @log.info "DynDNSimple: Current External IP is #{@settings.current_ip}"

      records = DNSimple::Record.all(@settings.domain)

      records.each do |record|
        #only update if the record is an A Record and the IP is different from the current external IP
        if self.need_to_update?(record)
          self.update!
        end
      end
    }
  end

  def self.need_to_update?(record)
    @settings = Settings.new
    record.name == @settings.hostname && record.record_type == "A" && record.content != @settings.current_ip
  end

  def self.update!
    @settings = Settings.new
    record.content = @settings.current_ip #"1.2.3.4"
    record.save
    @log.info "DynDNSimple: New External IP is #{record.content}"
  end
end