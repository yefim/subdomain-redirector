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

get '/edit' do
  %q(
    <form method="post" action="">
      <label>Redirect URL
        <input type="text" name="redirect_url">
      </label>
      <button type="submit">Submit</button>
    </form>
  )
end

post '/edit' do
  subdomain = request.host.split('.').first
  redirect_url = params['redirect_url']

  redis.set(subdomain, redirect_url)
  redirect redirect_url
end

def redis
  @redis ||= Redis.new(url: ENV["REDIS_URL"])
end
