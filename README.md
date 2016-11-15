# Erlang Pokemon DB

Pokemon database written fully in Erlang.

Discord link - [Discord](https://discord.gg/MSKWa)

iOS Client - [pokemap_live_ios](https://github.com/ruffnecktsk/pokemap_live_ios)

PHP example - [PokemonGO-SharedMap](https://github.com/SchwarzwaldFalke/PokemonGO-SharedMap)

WEBHOOK for PokemonGoMap:

-wh http://pokelocation.ru/webhookgate

How to use:

For webhook:

http://pokelocation.ru/webhookgate

For requests

http://pokelocation.ru/api/[lat]/[lon] - will give for you node url.

connect ws://[node url]:8080/gate

Now you can send requests. Proto file you can download from repo.

if you receive INVALID_LATLON response, you need again request node url for new coordinate and reconnect sockets.

Radius for get request is limited on server (1000 meters max).

If you want help me support servers:

Paypal - ruffnecktsk@gmail.com
