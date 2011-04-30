class DynDNSimple
  def self.refresh
    DNSimple::Client.username = $config['dnsimple']['username']
    DNSimple::Client.password = $config['dnsimple']['password']

    @log = Logger.new( File.join(APP_ROOT, 'log', 'dyn-dnsimple.log'), 'daily' )
    @log.level = Logger::INFO

    EM::HttpRequest.new('http://icanhazip.com').get.callback { |http|
      $current_ip = http.response.strip!
      puts $current_ip

      records = DNSimple::Record.all($config['domain'])

      records.each do |record|
        #only update if the record is an A Record and the IP is different from the current external IP
        if self.need_to_update?(record)
          @log.info "DynDNSimple: External IP is #{$current_ip}"
          record.content = $current_ip.to_s #"1.2.3.4"
          record.save
          @log.info "DynDNSimple: New IP is #{record.content}"
        end
      end
    }
  end

  def self.need_to_update?(record)
    record.name == $config['hostname'] && record.record_type == "A" && record.content != $current_ip
  end
end