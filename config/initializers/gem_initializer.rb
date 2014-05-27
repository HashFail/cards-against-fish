Linguistics.use(:en)
require 'faye'
PrivatePub.faye_app.on(:unsubscribe) do |client_id, channel|
	Game.find_by_name(channel[channel.index("games") + 6, channel.length]).remove_client(client_id)
end
