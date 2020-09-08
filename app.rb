require 'sinatra'

get '/' do
  "happy birthday yefim 🥳 You're at #{request.url}"
end
