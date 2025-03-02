require "kemal"
require "kemal-basic-auth"
require "http/client"
require "json"
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

# add handler
Kemal.config.add_handler(CustomAuthHandler.new("admin", "password"))

serve_static({"gzip" => false})

private def validatecreds(username, pass) # handles yapping to the FREEIPA server
  puts "#{username}"
  puts "#{pass}"

  # login_url = "https://citadel.cif.rochester.edu/ipa/session/login_password"
  login_url = "https://ipa.demo1.freeipa.org/ipa/session/login_password"
  body = {"user" => username,"password"=> pass}.to_json

  headers = HTTP::Headers{
    "Content-Type" => "application/x-www-form-urlencoded",
    "Referer"      => login_url,
    "Accept" => "response/json",
  }

  response = HTTP::Client.post(
    url: login_url,
    headers: headers,
    body:body,
  )

  puts "Status #{response.status_code}"
  puts "Response #{response.body}"
end

post "/login" do |env| # handling post for pass
  username = env.params.body["username"].as(String)
  password = env.params.body["password"].as(String)
  validatecreds(username, password)
end

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
