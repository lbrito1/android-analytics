require 'byebug'
require 'csv'
require 'digest'
require 'geocoder'
require_relative '../config/db'
require_relative './models/hits'

Hits.where(country: nil).each do |hit|
  next unless geo_info = Geocoder.search(hit.ip).first

  geo_info = geo_info.data.slice(%w(country region city)
  anonnymized_ip = Digest::MD5.hexdigest(hit.ip)

  hit.update(geo_info.merge(ip: anonnymized_ip))
end
