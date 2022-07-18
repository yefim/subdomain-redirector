require 'sinatra'
require 'redis'
use Rack::Logger

get '/info' do
  request.host
end

get '/dash' do
  'this is where the dashboard lives'
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
  host = request.host
  redirect_url = redis.get(host)

  erb :edit, locals: {
    redirect_url: redirect_url,
    host: host,
  }
end

post '/edit' do
  redirect_url = params['redirect_url']

  if params['password'] == ENV['EDIT_PASSWORD']
    redis.set(request.host, redirect_url)
    redirect redirect_url
  else
    "#{params['password']} is not the correct password."
  end
end

def redis
  @redis ||= Redis.new(url: ENV['REDIS_URL'])
end
