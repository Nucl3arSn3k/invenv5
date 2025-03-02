require "kemal"
require "kemal-basic-auth"

module Invenv6
  VERSION = "0.1.0"
end

# Create custom handler
class CustomAuthHandler < Kemal::BasicAuth::Handler
  only ["/dashboard", "/homepage"]

  def call(context)
    return call_next(context) unless only_match?(context)
    super
  end
end

#add handler
Kemal.config.add_handler(CustomAuthHandler.new("admin", "password"))

serve_static({"gzip" => false})

get "/" do |env|
  render "src/views/login.ecr"
end

get "/homepage" do |env|
  render "src/views/table.ecr"
end

get "/dashboard" do |env|
  "Dashboard content here"
end

Kemal.run