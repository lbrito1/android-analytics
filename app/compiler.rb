require 'byebug'
require 'csv'
require 'digest'
require 'geocoder'
require_relative '../config/db'

OUTPUT_FILE = './log/output'

MAIN_LOG_FILE_PATH = './log/nginx.access.log'
BACKUP_LOG_FILE_PATH = './log/nginx.access.log.bak'
HEADERS = %i(ip remote_user created_at request status body_bytes_sent url
  user_agent http_x_forwarded_for request_time upstream_response_time)

def write_to_output(string)
  File.open(OUTPUT_FILE, 'a') { |f| f.write("\n#{Time.now} - #{string}") }
end

logs = File.read(MAIN_LOG_FILE_PATH)
csv = CSV.new(logs, headers: HEADERS)

return write_to_output("No logs found.") if logs.size.zero?
csv_count = 0
csv.each do |row|
  db_entry = row.to_h.slice(:ip, :created_at, :url, :user_agent)
  ip = db_entry[:ip]

  if (geo_info = Geocoder.search(ip).first)
    db_entry[:country] = geo_info.country
    db_entry[:region] = geo_info.region
    db_entry[:city] = geo_info.city
  end
  # TODO: OS, device
  db_entry[:ip] = Digest::MD5.hexdigest(db_entry[:ip]) # anonnymize IP

  DB[:hits].insert(db_entry)
  csv_count += 1
end

File.open(BACKUP_LOG_FILE_PATH, 'a') { |f| f.write(logs) }
File.write(MAIN_LOG_FILE_PATH, '')

write_to_output("Wrote #{csv_count} rows to DB.")
