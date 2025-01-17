require "kemal"
module Invenv6
  VERSION = "0.1.0"

  get "/" do
    "Hello world!"
  end
end

Kemal.run