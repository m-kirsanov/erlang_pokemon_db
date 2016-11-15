export RELX_REPLACE_OS_VARS=true

NODE_NAME=node-180x0x-90x0 _build/default/rel/pokemonserv/bin/pokemonserv foreground &
    sleep 1

NODE_NAME=node-180x0x0x90 _build/default/rel/pokemonserv/bin/pokemonserv foreground &
    sleep 1

NODE_NAME=node0x180x-90x0 _build/default/rel/pokemonserv/bin/pokemonserv foreground &
    sleep 1

NODE_NAME=node0x180x0x90 _build/default/rel/pokemonserv/bin/pokemonserv foreground &
    sleep 1
