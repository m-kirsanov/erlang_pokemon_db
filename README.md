# Erlang Pokemon DB

Pokemon database written fully in Erlang.

Discord link - [Discord](https://discord.gg/mQxTv)

iOS Client - [pokemap_live_ios](https://github.com/ruffnecktsk/pokemap_live_ios)

WEBHOOK for PokemonGoMap:

-wh http://pokelocation.ru/webhookgate

Please add webhooks to your PokemonGo-Map workers, this will help me with testing. I need some high-load test before releasing requests API. After testing and implementing some anti-spam features, API will be released for everyone.

# Structure
# Main server
1. Returns node url for given coordinate.
2. Receives pokemon data from [PokemonGo-Map](https://github.com/PokemonGoMap/PokemonGo-Map) using webhooks. Later i create separate service for this.

# Nodes
1. Request processing. Connection using websockets, requests/responses - protocol buffers.



