#!/usr/bin/env ruby

require 'rubygems'
require 'em-http-request'
require 'sinatra/base'
require 'thin'
require 'logger'
require 'yaml'
require 'dnsimple'

APP_ROOT = File.dirname(__FILE__)

$log = Logger.new( File.join(APP_ROOT, 'log', 'dyn-dnsimple.log'), 'daily' )

require File.join(APP_ROOT, 'lib', 'settings.rb')
require File.join(APP_ROOT, 'lib', 'dyn-dnsimple.rb')

EventMachine.run do
  # Refresh the IP upon initial load
  DynDNSimple.refresh!

  # bring in the Sinatra web app
  require File.join(APP_ROOT, 'app', 'app.rb')

  # check for dns changes every $settings.update_frequency times
  EventMachine.add_periodic_timer($settings.update_frequency) {
    DynDNSimple.refresh!
  }
end
