class DynDNSimple
  def self.refresh!
    return unless self.refreshable?

    DNSimple::Client.username = $settings.username
    DNSimple::Client.password = $settings.password

    EM::HttpRequest.new('http://icanhazip.com').get.callback do |http|
      $settings.current_ip = http.response.strip!
      $settings.save!

      $log.info "DynDNSimple: Current External IP is #{$settings.current_ip}"
      self.update!
    end
  end

  def self.refreshable?
    !$settings.username.nil? && 
    !$settings.password.nil? && 
    !$settings.domain.nil? && 
    !$settings.hostname.nil?
  end

  def self.need_to_update?(record)
    record.name == $settings.hostname && 
    record.record_type == "A" && 
    record.content != $settings.current_ip
  end

  def self.update!
    domain = DNSimple::Domain.new(:name => $settings.domain)
    records = DNSimple::Record.all(domain)

    records.each do |record|
      next unless self.need_to_update?(record)
      #only update if the record is an A Record and the IP is different from the current external IP
      record.content = $settings.current_ip #"1.2.3.4"
      record.save
      $log.info "DynDNSimple: New External IP is #{record.content}"
    end
  end
end