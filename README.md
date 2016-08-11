# Erlang Pokemon DB

Pokemon database powered by Erlang.

# Structure
# Main server
1. Returns node url for given coordinate.
2. Receives pokemon data from [PokemonGo-Map](https://github.com/AHAAAAAAA/PokemonGo-Map) using webhooks. Later i create separate service for this.

# Nodes
1. Request processing. Connection using websockets, requests/responses - protocol buffers.




