#!/usr/bin/env ruby

require 'sinatra'
require 'sinatra/cross_origin'

configure {
  enable :cross_origin
  set :server, :puma
}

class Pumatra < Sinatra::Base
  before do
    headers 'Access-Control-Allow-Origin' => '*'
  end

  get '/hello' do
    "<h1>Hello world!</h1><p>Time is now: #{Time.new}</p>"
  end

  post '/update-blog-stats' do
    token = request.env.dig("rack.request.form_hash", "token")
    return status(400) unless token == SUPER_SECRET_TOKEN

    ip = request.env["HTTP_FORWARDED"]&.gsub("for=", "")
    ua = request.env["HTTP_USER_AGENT"]
    url = request.env.dig("rack.request.form_hash", "url")

    hit = Hits.new(created_at: Time.now, ip: ip, user_agent: ua, url: url)
    if hit.valid?
      hit.save
      status 200
    else
      status 400
    end
  end

  options "*" do
    response.headers["Allow"] = "HEAD,GET,PUT,POST,DELETE,OPTIONS"
    response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept"

    200
  end

  run! if app_file == $0
end
