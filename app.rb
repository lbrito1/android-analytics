#!/usr/bin/env ruby

require 'sinatra'
require 'byebug'
require 'awesome_print'

require_relative 'constants'
require_relative 'config/db'

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
    ip = request.env["HTTP_FORWARDED"]&.gsub("for=", "")
    ua = request.env["HTTP_USER_AGENT"]
    url = request.env.dig("rack.request.form_hash", "url")
    DB[:hits].insert(created_at: Time.now.utc, ip: ip, user_agent: ua, url: url)

    status 200
  end

  run! if app_file == $0
end
