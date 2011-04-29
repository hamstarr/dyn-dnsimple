require 'rubygems'
require 'dnsimple'
require "net/https"
require "uri"
require 'logger'

@config = YAML.load_file(File.join(File.dirname(__FILE__), '../config', 'config.yml'))

@log = Logger.new( File.join(File.dirname(__FILE__), '../log', 'dyn-dnsimple.log'), 'daily' )
@log.level = Logger::INFO

def external_ip
  uri = URI.parse("http://icanhazip.com")
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Get.new(uri.request_uri)
  request.initialize_http_header({"User-Agent" => "DynDNSimple"})

  response = http.request(request)
  return response.body.strip!
end

def set_new_ip
  DNSimple::Client.username = @config['dnsimple']['username']
  DNSimple::Client.password = @config['dnsimple']['password']

  new_ip = external_ip

  records = DNSimple::Record.all(@config['domain'])

  records.each do |record|
    #only update if the record is different from the current external IP
    if record.name == @config['hostname'] && record.content != new_ip
      @log.info "DynDNSimple: External IP is #{new_ip}"
      record.content = new_ip.to_s
      #record.content = "1.2.3.4"
      record.save
      @log.info "DynDNSimple: New IP is #{record.content}"
    end
  end
end

loop do
  set_new_ip
  sleep(@config['update_frequency'])
end