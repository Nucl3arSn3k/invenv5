require "kemal-session"

module SessionHandlers
  class UserSession
    include JSON::Serializable
    include Kemal::Session::StorableObject
    
    property username : String
    property token : UInt64
    
    def initialize(@username : String, @token : UInt64)
    end
  end
end