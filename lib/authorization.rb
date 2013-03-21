module Sinatra
  module Authorization
 
  def auth
    @auth ||= Rack::Auth::Basic::Request.new(request.env)
  end
 
  def unauthorized!(realm="Short URL Generator")
    headers 'WWW-Authenticate' => %(Basic realm="#{realm}")
    throw :halt, [ 401, 'Authorization Required' ]
  end
 
  def bad_request!
    throw :halt, [ 400, 'Bad Request' ]
  end
 
  def authorized?
    request.env['REMOTE_USER']
  end
 
  def authorize(username, password)
    if (username=='admin' && password=='admin') then
      true
    else
      false
    end
  end
 
  def require_admin
    return if authorized?
    puts "step 1 complete"
    unauthorized! unless auth.provided?
    puts "step 2 complete"
    bad_request! unless auth.basic?
    puts "step 3 complete"
    unauthorized! unless authorize(*auth.credentials)
    puts "step 4 complete"
    request.env['REMOTE_USER'] = auth.credentials[0]
  end
 
  def admin?
    authorized?
  end
 
  end
end
