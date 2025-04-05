require "kemal"
require "kemal-session"
require "http/client"
require "json"
require "./userobject"

module Invenv6
  VERSION = "0.1.0"
end

# Keep this minimal - just declare the library name
@[Link("loginhandle")]
lib CLib
  fun loginhandle(str1 : LibC::Char*, str2 : LibC::Char*, url : LibC::Char*) : LibC::Long
end

# Route protection
class SessionAuthHandler
  include HTTP::Handler #can be used as middleware
  
  property only_paths : Array(String) 
  
  def initialize(@only_paths = [] of String)
  end
  
  def call(context)
    # Skip if not a protected path
    return call_next(context) unless only_match?(context)
    
    # Check for valid session
    user_session = context.session.object?("user_session").as(SessionHandlers::UserSession?)
    
    if user_session
      # Session exists, allow access
      call_next(context)
    else
      # No valid session
      context.redirect "/?error=login_required"
    end
  end
  
  private def only_match?(context)
    return false if @only_paths.empty?
    @only_paths.any? do |path|
      context.request.path.starts_with?(path)
    end
  end
end

# Configure session
Kemal::Session.config.cookie_name = "session_id"
Kemal::Session.config.secret = "some_secret"
Kemal::Session.config.gc_interval = 2.minutes

# Add the session auth handler to protect routes
Kemal.config.add_handler SessionAuthHandler.new(["/dashboard", "/homepage"])

serve_static({"gzip" => false})

private def validatecreds(username, pass, login_url) # handles yapping to the FREEIPA server
  CLib.loginhandle(username.to_unsafe, pass.to_unsafe, login_url.to_unsafe)
end

# Login route
post "/login" do |env|
  username = env.params.body["username"].as(String)
  password = env.params.body["password"].as(String)
 
  login_url = "https://ipa.demo1.freeipa.org/ipa/session/login_password" #tweak to CIF IPA server URL
  result = validatecreds(username, password, login_url)
 
  if result == 200
    # Create and store the session
    random_token = Random.new.rand(1000000000_u64..18446744073709551614_u64)
    sesh = SessionHandlers::UserSession.new(username, random_token)
    env.session.object("user_session", sesh)
   
    # Redirect to dashboard
    env.redirect "/dashboard"
  else
    # Login failed
    env.redirect "/?error=invalid_credentials"
  end
end

# Login page
get "/" do |env|
  render "src/views/login.ecr"
end

# Protected routes
get "/homepage" do |env|
  # Access the session if needed (if you're bypassing auth, you may need to handle this differently)
  username = begin
    user_session = env.session.object?("user_session").as(SessionHandlers::UserSession?)
    user_session ? user_session.username : "dev_user"
  rescue
    "dev_user"
  end
  
  # Initialize SQLite database and create table if it doesn't exist
  DB.open "sqlite3://./items.db" do |db|
    # Check if table exists
    table_exists = db.scalar("SELECT name FROM sqlite_master WHERE type='table' AND name='inventory_items'").is_a?(String)
    
    unless table_exists
      # Create the inventory_items table based on the Ecto schema
      db.exec <<-SQL
        CREATE TABLE inventory_items (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          item_name TEXT NOT NULL,
          item_desc TEXT NOT NULL,
          checked_out BOOLEAN DEFAULT FALSE,
          checked_out_by TEXT,
          check_out_time TIMESTAMP,
          return_time TIMESTAMP,
          image TEXT NOT NULL,
          content_type TEXT NOT NULL,
          inserted_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
      SQL
      
      # Insert some sample data if needed
      db.exec <<-SQL
        INSERT INTO inventory_items 
        (item_name, item_desc, image, content_type) 
        VALUES 
        ('Sample Item', 'This is a sample item for testing', '/images/sample.jpg', 'image/jpeg')
      SQL
    end
    
    # Query items for display in the table
    items = [] of NamedTuple(
      id: Int64, 
      item_name: String, 
      item_desc: String, 
      checked_out: Bool, 
      checked_out_by: String?, 
      check_out_time: Time?, 
      return_time: Time?, 
      image: String, 
      content_type: String
    )
    
    db.query "SELECT id, item_name, item_desc, checked_out, checked_out_by, check_out_time, return_time, image, content_type FROM inventory_items" do |rs|
      rs.each do
        items << {
          id: rs.read(Int64),
          item_name: rs.read(String),
          item_desc: rs.read(String),
          checked_out: rs.read(Bool),
          checked_out_by: rs.read(String?),
          check_out_time: rs.read(Time?),
          return_time: rs.read(Time?),
          image: rs.read(String),
          content_type: rs.read(String)
        }
      end
    end
    
    # Make items available to the template
    env.set "items", items
  end
  
  render "src/views/table.ecr"
end

get "/dashboard" do |env|
  # Access the session if needed
  user_session = env.session.object("user_session").as(SessionHandlers::UserSession)
  username = user_session.username
  
  "Dashboard content for #{username}"
end

Kemal.run