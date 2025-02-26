require "kemal-basic-auth"

class CustomAuthHandler < Kemal::BasicAuth::Handler
    only ["/dashboard","/homepage"]

    def call(context)
        # Skip authentication if the current route is not in the protected routes list
        # This allows other routes to be accessed without authentication
        return call_next(context) unless only_match?(context)
        
        # Call the parent class's authentication logic for protected routes
        # This will prompt for username/password and validate credentials
        super
      end
    end

Kemal.config.auth_handler = CustomAuthHandler