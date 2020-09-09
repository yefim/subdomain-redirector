require 'sinatra'
require 'redis'

get '/' do
  if request.host.include?('dance.yef.im')
    redirect 'https://google.com'
  else
    "happy birthday yefim 🥳 You're at #{request.host}"
  end
end
