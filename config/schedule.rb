require_relative '../app/compiler'

every 5.minutes do
  runner "Compiler.update_geo_info"
end
