# Erlang Pokemon DB

Pokemon database written fully in Erlang.

Discord link - [Discord](https://discord.gg/mQxTv)

iOS Client - [pokemap_live_ios](https://github.com/ruffnecktsk/pokemap_live_ios)

WEBHOOK for PokemonGoMap:

-wh http://pokelocation.ru/webhookgate

Please add webhooks to your PokemonGo-Map workers, this will help me with testing. I need some high-load test before releasing requests API. After testing and implementing some anti-spam features, API will be released for everyone.

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
