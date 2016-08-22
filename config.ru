require 'bundler/setup'
require 'sinatra/base'
require 'json'
require 'rest-client'
class ContentofMessage
	def initialize(msg)
		@msg = msg
	end
	def content()
		if(@msg == "ボルト")
		return {
			contentType:2,
			toType:1,
			originalContentUrl:"https://i.ytimg.com/vi/qS0OLh8UrZk/maxresdefault.jpg",
			previewImageUrl:"https://i.ytimg.com/vi/qS0OLh8UrZk/maxresdefault.jpg"
		}
		else
		return {
			contentType:1,
			toType:1,
			text:text()
		}
		end
	end
	def text()
		flag = @msg.match(/乱数\(([0-9]{1,10})〜([0-9]{1,10})\)/)
		if(flag != nil)
			return "#{rand(flag[1].to_i..flag[2].to_i)}"
		else
			case @msg
			when "あ"
				return @msg+"じゃないです"
			when "乱数"
				return "「乱数(範囲)」って打ってください。(ex)乱数(1〜100))"
			else
				return "あって打ってください"
			end
		end
	end
end

a = gets.chomp
b = ContentofMessage.new(a)
puts b.text()



class App < Sinatra::Base
  post '/linebot/callback' do
    params = JSON.parse(request.body.read)
    
    params['result'].each do |msg|
    process = ContentofMessage.new(msg['content']['text'])
      request_content = {
        to: [msg['content']['from']],
        toChannel: 1383378250, # Fixed  value
        eventType: "138311608800106203", # Fixed value
        content: process.content()
      }

      endpoint_uri = 'https://trialbot-api.line.me/v1/events'
      content_json = request_content.to_json

      RestClient.proxy = ENV["FIXIE_URL"]
      RestClient.post(endpoint_uri, content_json, {
        'Content-Type' => 'application/json; charset=UTF-8',
        'X-Line-ChannelID' => ENV["LINE_CHANNEL_ID"],
        'X-Line-ChannelSecret' => ENV["LINE_CHANNEL_SECRET"],
        'X-Line-Trusted-User-With-ACL' => ENV["LINE_CHANNEL_MID"],
      })
    end


    "OK"
  end
end

run App
