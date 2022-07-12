require 'sinatra'
require 'redis'
use Rack::Logger

get '/info' do
  request.host
end

get '/' do
  redirect_url = redis.get(request.host)

  redis.incr("count-#{request.host}")
  redis.close

  if redirect_url
    redirect redirect_url
  else
    "You're at #{request.host}"
  end
end

get '/count' do
  count = redis.get("count-#{request.host}")
  redis.close
  count
end

get '/edit' do
  redirect_url = redis.get(request.host)

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
  redirect_url = params['redirect_url']

  if params['password'] == ENV['EDIT_PASSWORD']
    redis.set(request.host, redirect_url)
    redirect redirect_url
  else
    'bad password'
  end
end

def redis
  @redis ||= Redis.new(url: ENV['REDIS_URL'])
end
