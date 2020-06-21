require_relative '../app/compiler'

every 1.minutes do
  runner "Compiler.update_geo_info"
end
