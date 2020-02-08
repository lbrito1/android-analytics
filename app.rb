#!/usr/bin/env ruby

require 'sinatra'

configure {
  set :server, :puma
}

class Pumatra < Sinatra::Base
  get '/' do
    return "This is Puma through nginx. Time now: #{Time.new}"
  end

  run! if app_file == $0
end
