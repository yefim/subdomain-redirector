require 'sinatra'
require 'redis'
use Rack::Logger

get '/' do
  subdomain = request.host.split('.').first
  redirect_url = redis.get(subdomain)

  redis.incr("count-#{subdomain}")
  redis.close

  if redirect_url
    redirect redirect_url
  else
    "You're at #{request.host}"
  end
end

get '/count' do
  subdomain = request.host.split('.').first
  count = redis.get("count-#{subdomain}")
  redis.close
  count
end

get '/edit' do
  subdomain = request.host.split('.').first
  redirect_url = redis.get(subdomain)

  %Q(
    <form method="post" action="" onsubmit="navigator.clipboard.writeText('https://' + window.location.host)">
      <label>Redirect URL
        <input type="text" name="redirect_url" value="#{redirect_url}">
      </label>
      <label>Password
        <input type="text" name="password">
      </label>
      <button type="submit">Submit</button>
    </form>
  )
end

post '/edit' do
  subdomain = request.host.split('.').first
  redirect_url = params['redirect_url']

  if params['password'] == ENV['EDIT_PASSWORD']
    redis.set(subdomain, redirect_url)
    redirect redirect_url
  else
    'bad password'
  end
end

def redis
  @redis ||= Redis.new(url: ENV["REDIS_URL"])
end
