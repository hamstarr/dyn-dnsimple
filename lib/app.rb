class App < Sinatra::Base
  get '/' do
    return 'Current IP: ' + $current_ip + '<a href="/refresh">Refresh</a>'
  end
  
  get '/refresh' do
    DynDNSimple.refresh
    redirect '/'
  end
end

App.run!({:port => $config['http_port']})