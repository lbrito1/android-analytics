require 'digest'
require 'geocoder'
require_relative '../config/db'
require_relative './models/hits'

class Compiler
  def self.update_geo_info
    query = Hits.where(country: nil)
    count = query.count
    i = 0
    query.each do |hit|
      puts "Updating hit from #{hit.ip}... (#{i += 1}/#{count})"
      next unless geo_info = Geocoder.search(hit.ip).first

      geo_info = geo_info.data.slice(%w(country region city))
      anonnymized_ip = Digest::MD5.hexdigest(hit.ip)

      hit.update(geo_info.merge(ip: anonnymized_ip))
    end
  end
end
