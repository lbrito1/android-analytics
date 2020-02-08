#!/usr/bin/env ruby

require 'sinatra'

configure {
  set :server, :puma
}

class Pumatra < Sinatra::Base
  get '/' do
    return "<h1>Hello world!</h1><p>This is Puma through nginx. Time is now: #{Time.new}</p>"
  end

  run! if app_file == $0
end
