require "kemal"

module Invenv6
  VERSION = "0.1.0"
end

serve_static({"gzip" => false})

get "/" do |env|
  render "src/views/login.ecr"
end

Kemal.run