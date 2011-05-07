class Settings
  attr_accessor :dnsimple_username, :dnsimple_password, :domain, 
                :hostname, :update_frequency, :http_port, :current_ip, :errors

  def initialize(options = {})
    load(options)
    self.errors ||= {}
  end

  def clear
    self.instance_variables.each do |v|
      self.instance_variable_set v, nil
    end
    self.errors ||= {}
  end

  def save_to_config!
    settings = Hash.new
    settings['dnsimple'] = Hash.new
    settings['dnsimple']['username'] = self.dnsimple_username
    settings['dnsimple']['password'] = self.dnsimple_password
    settings['domain'] = self.domain
    settings['hostname'] = self.hostname
    settings['update_frequency'] = self.update_frequency
    settings['http_port'] = self.http_port
    settings['current_ip'] = self.current_ip

    File.open(File.join(APP_ROOT, 'config', 'config.yml'), "w") do |file|
      file.write settings.to_yaml
    end
  end

  def load(options = {})
    settings = YAML.load_file(File.join(APP_ROOT, 'config', 'config.yml'))

    settings = options.any? ? settings.merge(options) : settings

    self.dnsimple_username = settings['dnsimple']['username'] unless settings['dnsimple']['username'] == nil
    self.dnsimple_password = settings['dnsimple']['password'] unless settings['dnsimple']['password'] == nil
    self.domain = settings['domain'] unless settings['domain'] == nil
    self.hostname = settings['hostname'] unless settings['hostname'] == nil
    self.update_frequency = 360
    self.http_port = settings['http_port']
    self.current_ip = settings['current_ip'] unless settings['current_ip'] == nil
  end

  def valid?
    self.errors[:dnsimple_username] = "is required." if self.dnsimple_username.nil? || self.dnsimple_username.strip.empty?
    self.errors[:dnsimple_password] = "is required." if self.dnsimple_password.nil? || self.dnsimple_password.strip.empty?
    self.errors[:domain] = "is required." if self.domain.nil? || self.domain.empty?
    self.errors[:hostname] = "is required." if self.hostname.nil? || self.hostname.empty?
    self.errors.length == 0
  end
end