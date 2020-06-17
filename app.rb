#!/usr/bin/env ruby

require 'sinatra'
require 'sinatra/cross_origin'

configure {
  enable :cross_origin
  set :server, :puma
}

class Pumatra < Sinatra::Base
   configure :production, :development do
     enable :logging
   end

  before do
    # TODO
    headers 'Access-Control-Allow-Origin' => '*'
  end

  get '/hello' do
    return "<h1>Hello world!</h1><p>Time is now: #{Time.new}</p>"
  end

  post '/update-blog-stats' do
    ip = request.env["HTTP_FORWARDED"]&.gsub("for=", "")
    ua = request.env["HTTP_USER_AGENT"]
    url = request.env.dig("rack.request.form_hash", "url")
    DB[:hits].insert(created_at: Time.now.utc, ip: ip, user_agent: ua, url: url)

    status 200
  end

  options "*" do
    response.headers["Allow"] = "HEAD,GET,PUT,POST,DELETE,OPTIONS"
    response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept"

    200
  end

  run! if app_file == $0
end
