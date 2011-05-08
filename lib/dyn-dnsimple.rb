class DynDNSimple
  def self.refresh!
    return unless self.refreshable?

    DNSimple::Client.username = $settings.username
    DNSimple::Client.password = $settings.password

    EM::HttpRequest.new('http://icanhazip.com').get.callback { |http|
      $settings.current_ip = http.response.strip!
      $settings.save_to_config!

      $log.info "DynDNSimple: Current External IP is #{$settings.current_ip}"

      records = DNSimple::Record.all($settings.domain)

      records.each do |record|
        #only update if the record is an A Record and the IP is different from the current external IP
        if self.need_to_update?(record)
          self.update!
        end
      end
    }
  end

  def self.refreshable?
    !$settings.username.nil? && !$settings.password.nil? && !$settings.domain.nil? && !$settings.hostname.nil?
  end

  def self.need_to_update?(record)
    record.name == $settings.hostname && record.record_type == "A" && record.content != $settings.current_ip
  end

  def self.update!
    record.content = $settings.current_ip #"1.2.3.4"
    record.save
    $log.info "DynDNSimple: New External IP is #{record.content}"
  end
end