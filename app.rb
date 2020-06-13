#!/usr/bin/env ruby

require 'sinatra'
require 'byebug'
require 'awesome_print'

require_relative 'constants'
require_relative 'db'

configure {
  set :server, :puma
}

class Pumatra < Sinatra::Base
  before do
    # TODO
    headers 'Access-Control-Allow-Origin' => '*'
  end

  get '/' do
    return "<h1>Hello world!</h1><p>This is Puma through nginx. Time is now: #{Time.new}</p>"
  end

  post '/' do
    puts params
    byebug
    DB[:test_entry].insert(:test_string => word)
    return "Inserted #{word}"
  end

  run! if app_file == $0
end
