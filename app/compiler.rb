require_relative '../config/db'
require 'digest'
require 'geocoder'
require 'csv'
require 'time'
require 'byebug'

class Compiler
  HEADERS = %i(ip created_at request status body_bytes_sent url user_agent
    http_x_forwarded_for request_time)
  OUTPUT_FILE = './log/compiler.output'
  API_SLEEP = 0.5
  IP_REGEX = /((^\s*((([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5]))\s*$)|(^\s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?\s*$))/

  def initialize(path)
    Geocoder.configure(timeout: 10, ip_lookup: :ipapi_com)
    @path = path
    @cached_geo_by_ip = {}
  end

  def process
    write_to_output("Started processing #{@path}.")
    return write_to_output("No logs found.") if csv.none?

    errors = []
    db_rows = 0
    csv.each do |row|
      hash = row.to_h.slice(:ip, :created_at, :url, :user_agent)
      hash[:created_at] = Time.strptime((hash[:created_at].to_f * 1000).to_s, '%Q')

      geo = geo_info(hash[:ip])
      hash.merge!(geo) if geo
      # TODO: OS, device
      hash[:ip] = Digest::MD5.hexdigest(hash[:ip]) # anonnymize IP

      hit = Hits.new(hash)
      if hit.valid?
        hit.save
        db_rows += 1
      else
        errors << hit.errors.full_messages
      end
    end

    if errors.any?
      errors = errors.join("\n")
      error_msg = "There were errors. \n#{errors}"
      write_to_output(error_msg)
    end

    write_to_output("Proccessed #{csv.count} rows, created #{db_rows} DB rows.\n")
  end

  private

  def geo_info(ip)
    return unless valid_ip?(ip)

    cached = @cached_geo_by_ip[ip]
    return cached if cached

    return unless (geo = Geocoder.search(ip).first)

    sleep API_SLEEP

    @cached_geo_by_ip[ip] = {
      country:  geo.country,
      region:  geo.region,
      city:  geo.city,
      lat:  geo.latitude,
      long:  geo.longitude,
    }
  end

  def valid_ip?(ip)
    ip.match?(IP_REGEX)
  end

  def csv
    @csv ||= begin
      logs = File.read(@path)
      CSV.new(logs, headers: HEADERS).to_a
    end
  end

  def write_to_output(string)
    File.open(OUTPUT_FILE, 'a') { |f| f.write("\n#{Time.now} - #{string}") }
  end
end


