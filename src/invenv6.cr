require "kemal"
require "kemal-basic-auth"
require "http/client"
require "json"
module Invenv6
  VERSION = "0.1.0"
end
@[Link("clib")]
lib CLib
  # Define the function signature
  fun loginhandle(str1 : LibC::Char*, str2 : LibC::Char*, url : LibC::Char*) : Void
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
# login_url = "https://citadel.cif.rochester.edu/ipa/session/login_password"

private def validatecreds(username, pass) # handles yapping to the FREEIPA server
  CLib.loginhandle(username.to_unsafe,pass.to_unsafe)
end
post "/login" do |env| # handling post for pass
  username = env.params.body["username"].as(String)
  password = env.params.body["password"].as(String)
  login_url = "placeholder"
  validatecreds(username, password, login_url)
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
