require 'sinatra'
require 'redis'
use Rack::Logger

get '/' do
  host = request.host
  redirect_url = redis.get(host)

  redis.incr("count-#{host}")
  redis.close

  if redirect_url
    redirect redirect_url
  else
    %Q(
There is no redirect for #{host}. <a href="/edit">Would you like to create one?</a>
    )
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
