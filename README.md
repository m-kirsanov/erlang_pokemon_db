# Erlang Pokemon DB

Pokemon database written fully in Erlang.

WEBHOOK for PokemonGoMap:
-wh http://pokelocation.ru/webhookgate

Please add webhooks to your pokemon maps, i need to test how all works. After testing i will publish requests to DB API.

# Structure
# Main server
1. Returns node url for given coordinate.
2. Receives pokemon data from [PokemonGo-Map](https://github.com/AHAAAAAAA/PokemonGo-Map) using webhooks. Later i create separate service for this.

# Nodes
1. Request processing. Connection using websockets, requests/responses - protocol buffers.




