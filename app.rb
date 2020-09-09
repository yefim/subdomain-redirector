require 'sinatra'
require 'redis'

get '/' do
  subdomain = request.host.split('.').first
  redirect_url = redis.get(subdomain)

  if redirect_url
    redirect redirect_url
  else
    "happy birthday yefim 🥳 You're at #{request.host}"
  end
end

get '/haha' do
  subdomain = request.host.split('.').first
  redirect_url = redis.get(subdomain)

  %Q(
    <form method='post' action=''>
      <label>Redirect URL
        <input type='text' name='redirect_url' value="#{redirect_url}">
      </label>
      <button type='submit'>Submit</button>
    </form>
  )
end

post '/haha' do
  subdomain = request.host.split('.').first
  redirect_url = params['redirect_url']

  redis.set(subdomain, redirect_url)
  redirect redirect_url
end

def redis
  @redis ||= Redis.new(url: ENV["REDIS_URL"])
end
