class App < Sinatra::Base
  require 'haml'
  set :haml, :format => :html5
  set :static, true

  set :root, File.join(File.dirname(__FILE__), "..") 
  set :views, Proc.new { File.join(root, "app", "views") }
  set :public, Proc.new { File.join(root, "public") }

  get '/' do
    @settings = Settings.new
    haml :index
  end

  get '/settings' do
    @settings_form = Settings.new
    haml :settings
  end

  post '/settings' do
    @settings_form = Settings.new(params)

    if @settings_form.valid?
      @settings_form.save_to_config!
      #DynDNSimple.refresh
      # flash that settings have been updated
      redirect '/'
    end
    haml :settings
  end

  get '/refresh' do
    DynDNSimple.refresh!
    redirect '/'
  end
end

@settings = Settings.new
App.run!({:port => @settings.http_port})