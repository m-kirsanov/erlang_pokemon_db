-file("src/pokemap_request_pb.erl", 1).

-module(pokemap_request_pb).

-export([encode_owngetpokemonsresponse/1,
	 decode_owngetpokemonsresponse/1,
	 delimited_decode_owngetpokemonsresponse/1,
	 encode_ownresponse/1, decode_ownresponse/1,
	 delimited_decode_ownresponse/1, encode_ownpokemon/1,
	 decode_ownpokemon/1, delimited_decode_ownpokemon/1,
	 encode_ownsendpokemonsrequest/1,
	 decode_ownsendpokemonsrequest/1,
	 delimited_decode_ownsendpokemonsrequest/1,
	 encode_owngetpokemonsrequest/1,
	 decode_owngetpokemonsrequest/1,
	 delimited_decode_owngetpokemonsrequest/1,
	 encode_ownrequest/1, decode_ownrequest/1,
	 delimited_decode_ownrequest/1]).

-export([has_extension/2, extension_size/1,
	 get_extension/2, set_extension/3]).

-export([decode_extensions/1]).

-export([encode/1, decode/2, delimited_decode/2]).

-export([int_to_enum/2, enum_to_int/2]).

-record(owngetpokemonsresponse, {pokemon}).

-record(ownresponse,
	{response_id, sequence_id, response_message}).

-record(ownpokemon,
	{id, expiretimestampms, lat, lon, spawnpointid}).

-record(ownsendpokemonsrequest,
	{pokemon, latitude, longitude}).

-record(owngetpokemonsrequest,
	{latitude, longitude, radius}).

-record(ownrequest,
	{request_id, sequence_id, request_message}).

encode([]) -> [];
encode(Records) when is_list(Records) ->
    delimited_encode(Records);
encode(Record) -> encode(element(1, Record), Record).

encode_owngetpokemonsresponse(Records)
    when is_list(Records) ->
    delimited_encode(Records);
encode_owngetpokemonsresponse(Record)
    when is_record(Record, owngetpokemonsresponse) ->
    encode(owngetpokemonsresponse, Record).

encode_ownresponse(Records) when is_list(Records) ->
    delimited_encode(Records);
encode_ownresponse(Record)
    when is_record(Record, ownresponse) ->
    encode(ownresponse, Record).

encode_ownpokemon(Records) when is_list(Records) ->
    delimited_encode(Records);
encode_ownpokemon(Record)
    when is_record(Record, ownpokemon) ->
    encode(ownpokemon, Record).

encode_ownsendpokemonsrequest(Records)
    when is_list(Records) ->
    delimited_encode(Records);
encode_ownsendpokemonsrequest(Record)
    when is_record(Record, ownsendpokemonsrequest) ->
    encode(ownsendpokemonsrequest, Record).

encode_owngetpokemonsrequest(Records)
    when is_list(Records) ->
    delimited_encode(Records);
encode_owngetpokemonsrequest(Record)
    when is_record(Record, owngetpokemonsrequest) ->
    encode(owngetpokemonsrequest, Record).

encode_ownrequest(Records) when is_list(Records) ->
    delimited_encode(Records);
encode_ownrequest(Record)
    when is_record(Record, ownrequest) ->
    encode(ownrequest, Record).

encode(ownrequest, Records) when is_list(Records) ->
    delimited_encode(Records);
encode(ownrequest, Record) ->
    [iolist(ownrequest, Record)
     | encode_extensions(Record)];
encode(owngetpokemonsrequest, Records)
    when is_list(Records) ->
    delimited_encode(Records);
encode(owngetpokemonsrequest, Record) ->
    [iolist(owngetpokemonsrequest, Record)
     | encode_extensions(Record)];
encode(ownsendpokemonsrequest, Records)
    when is_list(Records) ->
    delimited_encode(Records);
encode(ownsendpokemonsrequest, Record) ->
    [iolist(ownsendpokemonsrequest, Record)
     | encode_extensions(Record)];
encode(ownpokemon, Records) when is_list(Records) ->
    delimited_encode(Records);
encode(ownpokemon, Record) ->
    [iolist(ownpokemon, Record)
     | encode_extensions(Record)];
encode(ownresponse, Records) when is_list(Records) ->
    delimited_encode(Records);
encode(ownresponse, Record) ->
    [iolist(ownresponse, Record)
     | encode_extensions(Record)];
encode(owngetpokemonsresponse, Records)
    when is_list(Records) ->
    delimited_encode(Records);
encode(owngetpokemonsresponse, Record) ->
    [iolist(owngetpokemonsresponse, Record)
     | encode_extensions(Record)].

encode_extensions(_) -> [].

delimited_encode(Records) ->
    lists:map(fun (Record) ->
		      IoRec = encode(Record),
		      Size = iolist_size(IoRec),
		      [protobuffs:encode_varint(Size), IoRec]
	      end,
	      Records).

iolist(ownrequest, Record) ->
    [pack(1, required,
	  with_default(Record#ownrequest.request_id, none),
	  ownrequestid, []),
     pack(2, required,
	  with_default(Record#ownrequest.sequence_id, none),
	  string, []),
     pack(3, required,
	  with_default(Record#ownrequest.request_message, none),
	  bytes, [])];
iolist(owngetpokemonsrequest, Record) ->
    [pack(1, required,
	  with_default(Record#owngetpokemonsrequest.latitude,
		       none),
	  double, []),
     pack(2, required,
	  with_default(Record#owngetpokemonsrequest.longitude,
		       none),
	  double, []),
     pack(3, required,
	  with_default(Record#owngetpokemonsrequest.radius, none),
	  int32, [])];
iolist(ownsendpokemonsrequest, Record) ->
    [pack(1, repeated,
	  with_default(Record#ownsendpokemonsrequest.pokemon,
		       none),
	  ownpokemon, []),
     pack(2, required,
	  with_default(Record#ownsendpokemonsrequest.latitude,
		       none),
	  double, []),
     pack(3, required,
	  with_default(Record#ownsendpokemonsrequest.longitude,
		       none),
	  double, [])];
iolist(ownpokemon, Record) ->
    [pack(1, optional,
	  with_default(Record#ownpokemon.id, none), ownpokemonid,
	  []),
     pack(2, optional,
	  with_default(Record#ownpokemon.expiretimestampms, none),
	  int64, []),
     pack(3, optional,
	  with_default(Record#ownpokemon.lat, none), double, []),
     pack(4, optional,
	  with_default(Record#ownpokemon.lon, none), double, []),
     pack(5, optional,
	  with_default(Record#ownpokemon.spawnpointid, none),
	  string, [])];
iolist(ownresponse, Record) ->
    [pack(1, required,
	  with_default(Record#ownresponse.response_id, none),
	  ownrequestid, []),
     pack(2, required,
	  with_default(Record#ownresponse.sequence_id, none),
	  string, []),
     pack(3, optional,
	  with_default(Record#ownresponse.response_message, none),
	  bytes, [])];
iolist(owngetpokemonsresponse, Record) ->
    [pack(1, repeated,
	  with_default(Record#owngetpokemonsresponse.pokemon,
		       none),
	  ownpokemon, [])].

with_default(Default, Default) -> undefined;
with_default(Val, _) -> Val.

pack(_, optional, undefined, _, _) -> [];
pack(_, repeated, undefined, _, _) -> [];
pack(_, repeated_packed, undefined, _, _) -> [];
pack(_, repeated_packed, [], _, _) -> [];
pack(FNum, required, undefined, Type, _) ->
    exit({error,
	  {required_field_is_undefined, FNum, Type}});
pack(_, repeated, [], _, Acc) -> lists:reverse(Acc);
pack(FNum, repeated, [Head | Tail], Type, Acc) ->
    pack(FNum, repeated, Tail, Type,
	 [pack(FNum, optional, Head, Type, []) | Acc]);
pack(FNum, repeated_packed, Data, Type, _) ->
    protobuffs:encode_packed(FNum, Data, Type);
pack(FNum, _, Data, _, _) when is_tuple(Data) ->
    [RecName | _] = tuple_to_list(Data),
    protobuffs:encode(FNum, encode(RecName, Data), bytes);
pack(FNum, _, Data, Type, _)
    when Type =:= bool;
	 Type =:= int32;
	 Type =:= uint32;
	 Type =:= int64;
	 Type =:= uint64;
	 Type =:= sint32;
	 Type =:= sint64;
	 Type =:= fixed32;
	 Type =:= sfixed32;
	 Type =:= fixed64;
	 Type =:= sfixed64;
	 Type =:= string;
	 Type =:= bytes;
	 Type =:= float;
	 Type =:= double ->
    protobuffs:encode(FNum, Data, Type);
pack(FNum, _, Data, Type, _) when is_atom(Data) ->
    protobuffs:encode(FNum, enum_to_int(Type, Data), enum).

enum_to_int(ownpokemonid, 'MEW') -> 151;
enum_to_int(ownpokemonid, 'MEWTWO') -> 150;
enum_to_int(ownpokemonid, 'DRAGONITE') -> 149;
enum_to_int(ownpokemonid, 'DRAGONAIR') -> 148;
enum_to_int(ownpokemonid, 'DRATINI') -> 147;
enum_to_int(ownpokemonid, 'MOLTRES') -> 146;
enum_to_int(ownpokemonid, 'ZAPDOS') -> 145;
enum_to_int(ownpokemonid, 'ARTICUNO') -> 144;
enum_to_int(ownpokemonid, 'SNORLAX') -> 143;
enum_to_int(ownpokemonid, 'AERODACTYL') -> 142;
enum_to_int(ownpokemonid, 'KABUTOPS') -> 141;
enum_to_int(ownpokemonid, 'KABUTO') -> 140;
enum_to_int(ownpokemonid, 'OMASTAR') -> 139;
enum_to_int(ownpokemonid, 'OMANYTE') -> 138;
enum_to_int(ownpokemonid, 'PORYGON') -> 137;
enum_to_int(ownpokemonid, 'FLAREON') -> 136;
enum_to_int(ownpokemonid, 'JOLTEON') -> 135;
enum_to_int(ownpokemonid, 'VAPOREON') -> 134;
enum_to_int(ownpokemonid, 'EEVEE') -> 133;
enum_to_int(ownpokemonid, 'DITTO') -> 132;
enum_to_int(ownpokemonid, 'LAPRAS') -> 131;
enum_to_int(ownpokemonid, 'GYARADOS') -> 130;
enum_to_int(ownpokemonid, 'MAGIKARP') -> 129;
enum_to_int(ownpokemonid, 'TAUROS') -> 128;
enum_to_int(ownpokemonid, 'PINSIR') -> 127;
enum_to_int(ownpokemonid, 'MAGMAR') -> 126;
enum_to_int(ownpokemonid, 'ELECTABUZZ') -> 125;
enum_to_int(ownpokemonid, 'JYNX') -> 124;
enum_to_int(ownpokemonid, 'SCYTHER') -> 123;
enum_to_int(ownpokemonid, 'MR_MIME') -> 122;
enum_to_int(ownpokemonid, 'STARMIE') -> 121;
enum_to_int(ownpokemonid, 'STARYU') -> 120;
enum_to_int(ownpokemonid, 'SEAKING') -> 119;
enum_to_int(ownpokemonid, 'GOLDEEN') -> 118;
enum_to_int(ownpokemonid, 'SEADRA') -> 117;
enum_to_int(ownpokemonid, 'HORSEA') -> 116;
enum_to_int(ownpokemonid, 'KANGASKHAN') -> 115;
enum_to_int(ownpokemonid, 'TANGELA') -> 114;
enum_to_int(ownpokemonid, 'CHANSEY') -> 113;
enum_to_int(ownpokemonid, 'RHYDON') -> 112;
enum_to_int(ownpokemonid, 'RHYHORN') -> 111;
enum_to_int(ownpokemonid, 'WEEZING') -> 110;
enum_to_int(ownpokemonid, 'KOFFING') -> 109;
enum_to_int(ownpokemonid, 'LICKITUNG') -> 108;
enum_to_int(ownpokemonid, 'HITMONCHAN') -> 107;
enum_to_int(ownpokemonid, 'HITMONLEE') -> 106;
enum_to_int(ownpokemonid, 'MAROWAK') -> 105;
enum_to_int(ownpokemonid, 'CUBONE') -> 104;
enum_to_int(ownpokemonid, 'EXEGGUTOR') -> 103;
enum_to_int(ownpokemonid, 'EXEGGCUTE') -> 102;
enum_to_int(ownpokemonid, 'ELECTRODE') -> 101;
enum_to_int(ownpokemonid, 'VOLTORB') -> 100;
enum_to_int(ownpokemonid, 'KINGLER') -> 99;
enum_to_int(ownpokemonid, 'KRABBY') -> 98;
enum_to_int(ownpokemonid, 'HYPNO') -> 97;
enum_to_int(ownpokemonid, 'DROWZEE') -> 96;
enum_to_int(ownpokemonid, 'ONIX') -> 95;
enum_to_int(ownpokemonid, 'GENGAR') -> 94;
enum_to_int(ownpokemonid, 'HAUNTER') -> 93;
enum_to_int(ownpokemonid, 'GASTLY') -> 92;
enum_to_int(ownpokemonid, 'CLOYSTER') -> 91;
enum_to_int(ownpokemonid, 'SHELLDER') -> 90;
enum_to_int(ownpokemonid, 'MUK') -> 89;
enum_to_int(ownpokemonid, 'GRIMER') -> 88;
enum_to_int(ownpokemonid, 'DEWGONG') -> 87;
enum_to_int(ownpokemonid, 'SEEL') -> 86;
enum_to_int(ownpokemonid, 'DODRIO') -> 85;
enum_to_int(ownpokemonid, 'DODUO') -> 84;
enum_to_int(ownpokemonid, 'FARFETCHD') -> 83;
enum_to_int(ownpokemonid, 'MAGNETON') -> 82;
enum_to_int(ownpokemonid, 'MAGNEMITE') -> 81;
enum_to_int(ownpokemonid, 'SLOWBRO') -> 80;
enum_to_int(ownpokemonid, 'SLOWPOKE') -> 79;
enum_to_int(ownpokemonid, 'RAPIDASH') -> 78;
enum_to_int(ownpokemonid, 'PONYTA') -> 77;
enum_to_int(ownpokemonid, 'GOLEM') -> 76;
enum_to_int(ownpokemonid, 'GRAVELER') -> 75;
enum_to_int(ownpokemonid, 'GEODUGE') -> 74;
enum_to_int(ownpokemonid, 'TENTACRUEL') -> 73;
enum_to_int(ownpokemonid, 'TENTACOOL') -> 72;
enum_to_int(ownpokemonid, 'VICTREEBELL') -> 71;
enum_to_int(ownpokemonid, 'WEEPINBELL') -> 70;
enum_to_int(ownpokemonid, 'BELLSPROUT') -> 69;
enum_to_int(ownpokemonid, 'MACHAMP') -> 68;
enum_to_int(ownpokemonid, 'MACHOKE') -> 67;
enum_to_int(ownpokemonid, 'MACHOP') -> 66;
enum_to_int(ownpokemonid, 'ALAKHAZAM') -> 65;
enum_to_int(ownpokemonid, 'KADABRA') -> 64;
enum_to_int(ownpokemonid, 'ABRA') -> 63;
enum_to_int(ownpokemonid, 'POLIWRATH') -> 62;
enum_to_int(ownpokemonid, 'POLIWHIRL') -> 61;
enum_to_int(ownpokemonid, 'POLIWAG') -> 60;
enum_to_int(ownpokemonid, 'ARCANINE') -> 59;
enum_to_int(ownpokemonid, 'GROWLITHE') -> 58;
enum_to_int(ownpokemonid, 'PRIMEAPE') -> 57;
enum_to_int(ownpokemonid, 'MANKEY') -> 56;
enum_to_int(ownpokemonid, 'GOLDUCK') -> 55;
enum_to_int(ownpokemonid, 'PSYDUCK') -> 54;
enum_to_int(ownpokemonid, 'PERSIAN') -> 53;
enum_to_int(ownpokemonid, 'MEOWTH') -> 52;
enum_to_int(ownpokemonid, 'DUGTRIO') -> 51;
enum_to_int(ownpokemonid, 'DIGLETT') -> 50;
enum_to_int(ownpokemonid, 'VENOMOTH') -> 49;
enum_to_int(ownpokemonid, 'VENONAT') -> 48;
enum_to_int(ownpokemonid, 'PARASECT') -> 47;
enum_to_int(ownpokemonid, 'PARAS') -> 46;
enum_to_int(ownpokemonid, 'VILEPLUME') -> 45;
enum_to_int(ownpokemonid, 'GLOOM') -> 44;
enum_to_int(ownpokemonid, 'ODDISH') -> 43;
enum_to_int(ownpokemonid, 'GOLBAT') -> 42;
enum_to_int(ownpokemonid, 'ZUBAT') -> 41;
enum_to_int(ownpokemonid, 'WIGGLYTUFF') -> 40;
enum_to_int(ownpokemonid, 'JIGGLYPUFF') -> 39;
enum_to_int(ownpokemonid, 'NINETALES') -> 38;
enum_to_int(ownpokemonid, 'VULPIX') -> 37;
enum_to_int(ownpokemonid, 'CLEFABLE') -> 36;
enum_to_int(ownpokemonid, 'CLEFARY') -> 35;
enum_to_int(ownpokemonid, 'NIDOKING') -> 34;
enum_to_int(ownpokemonid, 'NIDORINO') -> 33;
enum_to_int(ownpokemonid, 'NIDORAN_MALE') -> 32;
enum_to_int(ownpokemonid, 'NIDOQUEEN') -> 31;
enum_to_int(ownpokemonid, 'NIDORINA') -> 30;
enum_to_int(ownpokemonid, 'NIDORAN_FEMALE') -> 29;
enum_to_int(ownpokemonid, 'SANDLASH') -> 28;
enum_to_int(ownpokemonid, 'SANDSHREW') -> 27;
enum_to_int(ownpokemonid, 'RAICHU') -> 26;
enum_to_int(ownpokemonid, 'PIKACHU') -> 25;
enum_to_int(ownpokemonid, 'ARBOK') -> 24;
enum_to_int(ownpokemonid, 'EKANS') -> 23;
enum_to_int(ownpokemonid, 'FEAROW') -> 22;
enum_to_int(ownpokemonid, 'SPEAROW') -> 21;
enum_to_int(ownpokemonid, 'RATICATE') -> 20;
enum_to_int(ownpokemonid, 'RATTATA') -> 19;
enum_to_int(ownpokemonid, 'PIDGEOT') -> 18;
enum_to_int(ownpokemonid, 'PIDGEOTTO') -> 17;
enum_to_int(ownpokemonid, 'PIDGEY') -> 16;
enum_to_int(ownpokemonid, 'BEEDRILL') -> 15;
enum_to_int(ownpokemonid, 'KAKUNA') -> 14;
enum_to_int(ownpokemonid, 'WEEDLE') -> 13;
enum_to_int(ownpokemonid, 'BUTTERFREE') -> 12;
enum_to_int(ownpokemonid, 'METAPOD') -> 11;
enum_to_int(ownpokemonid, 'CATERPIE') -> 10;
enum_to_int(ownpokemonid, 'BLASTOISE') -> 9;
enum_to_int(ownpokemonid, 'WARTORTLE') -> 8;
enum_to_int(ownpokemonid, 'SQUIRTLE') -> 7;
enum_to_int(ownpokemonid, 'CHARIZARD') -> 6;
enum_to_int(ownpokemonid, 'CHARMELEON') -> 5;
enum_to_int(ownpokemonid, 'CHARMENDER') -> 4;
enum_to_int(ownpokemonid, 'VENUSAUR') -> 3;
enum_to_int(ownpokemonid, 'IVYSAUR') -> 2;
enum_to_int(ownpokemonid, 'BULBASAUR') -> 1;
enum_to_int(ownpokemonid, 'MISSINGNO') -> 0;
enum_to_int(ownrequestid, 'INVALID_LATLON') -> 3;
enum_to_int(ownrequestid, 'SEND_POKEMONS') -> 2;
enum_to_int(ownrequestid, 'GET_POKEMONS') -> 1;
enum_to_int(ownrequestid, 'NO_REQUEST') -> 0.

int_to_enum(ownpokemonid, 151) -> 'MEW';
int_to_enum(ownpokemonid, 150) -> 'MEWTWO';
int_to_enum(ownpokemonid, 149) -> 'DRAGONITE';
int_to_enum(ownpokemonid, 148) -> 'DRAGONAIR';
int_to_enum(ownpokemonid, 147) -> 'DRATINI';
int_to_enum(ownpokemonid, 146) -> 'MOLTRES';
int_to_enum(ownpokemonid, 145) -> 'ZAPDOS';
int_to_enum(ownpokemonid, 144) -> 'ARTICUNO';
int_to_enum(ownpokemonid, 143) -> 'SNORLAX';
int_to_enum(ownpokemonid, 142) -> 'AERODACTYL';
int_to_enum(ownpokemonid, 141) -> 'KABUTOPS';
int_to_enum(ownpokemonid, 140) -> 'KABUTO';
int_to_enum(ownpokemonid, 139) -> 'OMASTAR';
int_to_enum(ownpokemonid, 138) -> 'OMANYTE';
int_to_enum(ownpokemonid, 137) -> 'PORYGON';
int_to_enum(ownpokemonid, 136) -> 'FLAREON';
int_to_enum(ownpokemonid, 135) -> 'JOLTEON';
int_to_enum(ownpokemonid, 134) -> 'VAPOREON';
int_to_enum(ownpokemonid, 133) -> 'EEVEE';
int_to_enum(ownpokemonid, 132) -> 'DITTO';
int_to_enum(ownpokemonid, 131) -> 'LAPRAS';
int_to_enum(ownpokemonid, 130) -> 'GYARADOS';
int_to_enum(ownpokemonid, 129) -> 'MAGIKARP';
int_to_enum(ownpokemonid, 128) -> 'TAUROS';
int_to_enum(ownpokemonid, 127) -> 'PINSIR';
int_to_enum(ownpokemonid, 126) -> 'MAGMAR';
int_to_enum(ownpokemonid, 125) -> 'ELECTABUZZ';
int_to_enum(ownpokemonid, 124) -> 'JYNX';
int_to_enum(ownpokemonid, 123) -> 'SCYTHER';
int_to_enum(ownpokemonid, 122) -> 'MR_MIME';
int_to_enum(ownpokemonid, 121) -> 'STARMIE';
int_to_enum(ownpokemonid, 120) -> 'STARYU';
int_to_enum(ownpokemonid, 119) -> 'SEAKING';
int_to_enum(ownpokemonid, 118) -> 'GOLDEEN';
int_to_enum(ownpokemonid, 117) -> 'SEADRA';
int_to_enum(ownpokemonid, 116) -> 'HORSEA';
int_to_enum(ownpokemonid, 115) -> 'KANGASKHAN';
int_to_enum(ownpokemonid, 114) -> 'TANGELA';
int_to_enum(ownpokemonid, 113) -> 'CHANSEY';
int_to_enum(ownpokemonid, 112) -> 'RHYDON';
int_to_enum(ownpokemonid, 111) -> 'RHYHORN';
int_to_enum(ownpokemonid, 110) -> 'WEEZING';
int_to_enum(ownpokemonid, 109) -> 'KOFFING';
int_to_enum(ownpokemonid, 108) -> 'LICKITUNG';
int_to_enum(ownpokemonid, 107) -> 'HITMONCHAN';
int_to_enum(ownpokemonid, 106) -> 'HITMONLEE';
int_to_enum(ownpokemonid, 105) -> 'MAROWAK';
int_to_enum(ownpokemonid, 104) -> 'CUBONE';
int_to_enum(ownpokemonid, 103) -> 'EXEGGUTOR';
int_to_enum(ownpokemonid, 102) -> 'EXEGGCUTE';
int_to_enum(ownpokemonid, 101) -> 'ELECTRODE';
int_to_enum(ownpokemonid, 100) -> 'VOLTORB';
int_to_enum(ownpokemonid, 99) -> 'KINGLER';
int_to_enum(ownpokemonid, 98) -> 'KRABBY';
int_to_enum(ownpokemonid, 97) -> 'HYPNO';
int_to_enum(ownpokemonid, 96) -> 'DROWZEE';
int_to_enum(ownpokemonid, 95) -> 'ONIX';
int_to_enum(ownpokemonid, 94) -> 'GENGAR';
int_to_enum(ownpokemonid, 93) -> 'HAUNTER';
int_to_enum(ownpokemonid, 92) -> 'GASTLY';
int_to_enum(ownpokemonid, 91) -> 'CLOYSTER';
int_to_enum(ownpokemonid, 90) -> 'SHELLDER';
int_to_enum(ownpokemonid, 89) -> 'MUK';
int_to_enum(ownpokemonid, 88) -> 'GRIMER';
int_to_enum(ownpokemonid, 87) -> 'DEWGONG';
int_to_enum(ownpokemonid, 86) -> 'SEEL';
int_to_enum(ownpokemonid, 85) -> 'DODRIO';
int_to_enum(ownpokemonid, 84) -> 'DODUO';
int_to_enum(ownpokemonid, 83) -> 'FARFETCHD';
int_to_enum(ownpokemonid, 82) -> 'MAGNETON';
int_to_enum(ownpokemonid, 81) -> 'MAGNEMITE';
int_to_enum(ownpokemonid, 80) -> 'SLOWBRO';
int_to_enum(ownpokemonid, 79) -> 'SLOWPOKE';
int_to_enum(ownpokemonid, 78) -> 'RAPIDASH';
int_to_enum(ownpokemonid, 77) -> 'PONYTA';
int_to_enum(ownpokemonid, 76) -> 'GOLEM';
int_to_enum(ownpokemonid, 75) -> 'GRAVELER';
int_to_enum(ownpokemonid, 74) -> 'GEODUGE';
int_to_enum(ownpokemonid, 73) -> 'TENTACRUEL';
int_to_enum(ownpokemonid, 72) -> 'TENTACOOL';
int_to_enum(ownpokemonid, 71) -> 'VICTREEBELL';
int_to_enum(ownpokemonid, 70) -> 'WEEPINBELL';
int_to_enum(ownpokemonid, 69) -> 'BELLSPROUT';
int_to_enum(ownpokemonid, 68) -> 'MACHAMP';
int_to_enum(ownpokemonid, 67) -> 'MACHOKE';
int_to_enum(ownpokemonid, 66) -> 'MACHOP';
int_to_enum(ownpokemonid, 65) -> 'ALAKHAZAM';
int_to_enum(ownpokemonid, 64) -> 'KADABRA';
int_to_enum(ownpokemonid, 63) -> 'ABRA';
int_to_enum(ownpokemonid, 62) -> 'POLIWRATH';
int_to_enum(ownpokemonid, 61) -> 'POLIWHIRL';
int_to_enum(ownpokemonid, 60) -> 'POLIWAG';
int_to_enum(ownpokemonid, 59) -> 'ARCANINE';
int_to_enum(ownpokemonid, 58) -> 'GROWLITHE';
int_to_enum(ownpokemonid, 57) -> 'PRIMEAPE';
int_to_enum(ownpokemonid, 56) -> 'MANKEY';
int_to_enum(ownpokemonid, 55) -> 'GOLDUCK';
int_to_enum(ownpokemonid, 54) -> 'PSYDUCK';
int_to_enum(ownpokemonid, 53) -> 'PERSIAN';
int_to_enum(ownpokemonid, 52) -> 'MEOWTH';
int_to_enum(ownpokemonid, 51) -> 'DUGTRIO';
int_to_enum(ownpokemonid, 50) -> 'DIGLETT';
int_to_enum(ownpokemonid, 49) -> 'VENOMOTH';
int_to_enum(ownpokemonid, 48) -> 'VENONAT';
int_to_enum(ownpokemonid, 47) -> 'PARASECT';
int_to_enum(ownpokemonid, 46) -> 'PARAS';
int_to_enum(ownpokemonid, 45) -> 'VILEPLUME';
int_to_enum(ownpokemonid, 44) -> 'GLOOM';
int_to_enum(ownpokemonid, 43) -> 'ODDISH';
int_to_enum(ownpokemonid, 42) -> 'GOLBAT';
int_to_enum(ownpokemonid, 41) -> 'ZUBAT';
int_to_enum(ownpokemonid, 40) -> 'WIGGLYTUFF';
int_to_enum(ownpokemonid, 39) -> 'JIGGLYPUFF';
int_to_enum(ownpokemonid, 38) -> 'NINETALES';
int_to_enum(ownpokemonid, 37) -> 'VULPIX';
int_to_enum(ownpokemonid, 36) -> 'CLEFABLE';
int_to_enum(ownpokemonid, 35) -> 'CLEFARY';
int_to_enum(ownpokemonid, 34) -> 'NIDOKING';
int_to_enum(ownpokemonid, 33) -> 'NIDORINO';
int_to_enum(ownpokemonid, 32) -> 'NIDORAN_MALE';
int_to_enum(ownpokemonid, 31) -> 'NIDOQUEEN';
int_to_enum(ownpokemonid, 30) -> 'NIDORINA';
int_to_enum(ownpokemonid, 29) -> 'NIDORAN_FEMALE';
int_to_enum(ownpokemonid, 28) -> 'SANDLASH';
int_to_enum(ownpokemonid, 27) -> 'SANDSHREW';
int_to_enum(ownpokemonid, 26) -> 'RAICHU';
int_to_enum(ownpokemonid, 25) -> 'PIKACHU';
int_to_enum(ownpokemonid, 24) -> 'ARBOK';
int_to_enum(ownpokemonid, 23) -> 'EKANS';
int_to_enum(ownpokemonid, 22) -> 'FEAROW';
int_to_enum(ownpokemonid, 21) -> 'SPEAROW';
int_to_enum(ownpokemonid, 20) -> 'RATICATE';
int_to_enum(ownpokemonid, 19) -> 'RATTATA';
int_to_enum(ownpokemonid, 18) -> 'PIDGEOT';
int_to_enum(ownpokemonid, 17) -> 'PIDGEOTTO';
int_to_enum(ownpokemonid, 16) -> 'PIDGEY';
int_to_enum(ownpokemonid, 15) -> 'BEEDRILL';
int_to_enum(ownpokemonid, 14) -> 'KAKUNA';
int_to_enum(ownpokemonid, 13) -> 'WEEDLE';
int_to_enum(ownpokemonid, 12) -> 'BUTTERFREE';
int_to_enum(ownpokemonid, 11) -> 'METAPOD';
int_to_enum(ownpokemonid, 10) -> 'CATERPIE';
int_to_enum(ownpokemonid, 9) -> 'BLASTOISE';
int_to_enum(ownpokemonid, 8) -> 'WARTORTLE';
int_to_enum(ownpokemonid, 7) -> 'SQUIRTLE';
int_to_enum(ownpokemonid, 6) -> 'CHARIZARD';
int_to_enum(ownpokemonid, 5) -> 'CHARMELEON';
int_to_enum(ownpokemonid, 4) -> 'CHARMENDER';
int_to_enum(ownpokemonid, 3) -> 'VENUSAUR';
int_to_enum(ownpokemonid, 2) -> 'IVYSAUR';
int_to_enum(ownpokemonid, 1) -> 'BULBASAUR';
int_to_enum(ownpokemonid, 0) -> 'MISSINGNO';
int_to_enum(ownrequestid, 3) -> 'INVALID_LATLON';
int_to_enum(ownrequestid, 2) -> 'SEND_POKEMONS';
int_to_enum(ownrequestid, 1) -> 'GET_POKEMONS';
int_to_enum(ownrequestid, 0) -> 'NO_REQUEST';
int_to_enum(_, Val) -> Val.

decode_owngetpokemonsresponse(Bytes)
    when is_binary(Bytes) ->
    decode(owngetpokemonsresponse, Bytes).

decode_ownresponse(Bytes) when is_binary(Bytes) ->
    decode(ownresponse, Bytes).

decode_ownpokemon(Bytes) when is_binary(Bytes) ->
    decode(ownpokemon, Bytes).

decode_ownsendpokemonsrequest(Bytes)
    when is_binary(Bytes) ->
    decode(ownsendpokemonsrequest, Bytes).

decode_owngetpokemonsrequest(Bytes)
    when is_binary(Bytes) ->
    decode(owngetpokemonsrequest, Bytes).

decode_ownrequest(Bytes) when is_binary(Bytes) ->
    decode(ownrequest, Bytes).

delimited_decode_ownrequest(Bytes) ->
    delimited_decode(ownrequest, Bytes).

delimited_decode_owngetpokemonsrequest(Bytes) ->
    delimited_decode(owngetpokemonsrequest, Bytes).

delimited_decode_ownsendpokemonsrequest(Bytes) ->
    delimited_decode(ownsendpokemonsrequest, Bytes).

delimited_decode_ownpokemon(Bytes) ->
    delimited_decode(ownpokemon, Bytes).

delimited_decode_ownresponse(Bytes) ->
    delimited_decode(ownresponse, Bytes).

delimited_decode_owngetpokemonsresponse(Bytes) ->
    delimited_decode(owngetpokemonsresponse, Bytes).

delimited_decode(Type, Bytes) when is_binary(Bytes) ->
    delimited_decode(Type, Bytes, []).

delimited_decode(_Type, <<>>, Acc) ->
    {lists:reverse(Acc), <<>>};
delimited_decode(Type, Bytes, Acc) ->
    try protobuffs:decode_varint(Bytes) of
      {Size, Rest} when size(Rest) < Size ->
	  {lists:reverse(Acc), Bytes};
      {Size, Rest} ->
	  <<MessageBytes:Size/binary, Rest2/binary>> = Rest,
	  Message = decode(Type, MessageBytes),
	  delimited_decode(Type, Rest2, [Message | Acc])
    catch
      _What:_Why -> {lists:reverse(Acc), Bytes}
    end.

decode(enummsg_values, 1) -> value1;
decode(ownrequest, Bytes) when is_binary(Bytes) ->
    Types = [{3, request_message, bytes, []},
	     {2, sequence_id, string, []},
	     {1, request_id, ownrequestid, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(ownrequest, Decoded);
decode(owngetpokemonsrequest, Bytes)
    when is_binary(Bytes) ->
    Types = [{3, radius, int32, []},
	     {2, longitude, double, []}, {1, latitude, double, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(owngetpokemonsrequest, Decoded);
decode(ownsendpokemonsrequest, Bytes)
    when is_binary(Bytes) ->
    Types = [{3, longitude, double, []},
	     {2, latitude, double, []},
	     {1, pokemon, ownpokemon, [is_record, repeated]}],
    Defaults = [{1, pokemon, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(ownsendpokemonsrequest, Decoded);
decode(ownpokemon, Bytes) when is_binary(Bytes) ->
    Types = [{5, spawnpointid, string, []},
	     {4, lon, double, []}, {3, lat, double, []},
	     {2, expiretimestampms, int64, []},
	     {1, id, ownpokemonid, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(ownpokemon, Decoded);
decode(ownresponse, Bytes) when is_binary(Bytes) ->
    Types = [{3, response_message, bytes, []},
	     {2, sequence_id, string, []},
	     {1, response_id, ownrequestid, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(ownresponse, Decoded);
decode(owngetpokemonsresponse, Bytes)
    when is_binary(Bytes) ->
    Types = [{1, pokemon, ownpokemon,
	      [is_record, repeated]}],
    Defaults = [{1, pokemon, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(owngetpokemonsresponse, Decoded).

decode(<<>>, Types, Acc) ->
    reverse_repeated_fields(Acc, Types);
decode(Bytes, Types, Acc) ->
    {ok, FNum} = protobuffs:next_field_num(Bytes),
    case lists:keyfind(FNum, 1, Types) of
      {FNum, Name, Type, Opts} ->
	  {Value1, Rest1} = case lists:member(is_record, Opts) of
			      true ->
				  {{FNum, V}, R} = protobuffs:decode(Bytes,
								     bytes),
				  RecVal = decode(Type, V),
				  {RecVal, R};
			      false ->
				  case lists:member(repeated_packed, Opts) of
				    true ->
					{{FNum, V}, R} =
					    protobuffs:decode_packed(Bytes,
								     Type),
					{V, R};
				    false ->
					{{FNum, V}, R} =
					    protobuffs:decode(Bytes, Type),
					{unpack_value(V, Type), R}
				  end
			    end,
	  case lists:member(repeated, Opts) of
	    true ->
		case lists:keytake(FNum, 1, Acc) of
		  {value, {FNum, Name, List}, Acc1} ->
		      decode(Rest1, Types,
			     [{FNum, Name, [int_to_enum(Type, Value1) | List]}
			      | Acc1]);
		  false ->
		      decode(Rest1, Types,
			     [{FNum, Name, [int_to_enum(Type, Value1)]} | Acc])
		end;
	    false ->
		decode(Rest1, Types,
		       [{FNum, Name, int_to_enum(Type, Value1)} | Acc])
	  end;
      false ->
	  case lists:keyfind('$extensions', 2, Acc) of
	    {_, _, Dict} ->
		{{FNum, _V}, R} = protobuffs:decode(Bytes, bytes),
		Diff = size(Bytes) - size(R),
		<<V:Diff/binary, _/binary>> = Bytes,
		NewDict = dict:store(FNum, V, Dict),
		NewAcc = lists:keyreplace('$extensions', 2, Acc,
					  {false, '$extensions', NewDict}),
		decode(R, Types, NewAcc);
	    _ ->
		{ok, Skipped} = protobuffs:skip_next_field(Bytes),
		decode(Skipped, Types, Acc)
	  end
    end.

reverse_repeated_fields(FieldList, Types) ->
    [begin
       case lists:keyfind(FNum, 1, Types) of
	 {FNum, Name, _Type, Opts} ->
	     case lists:member(repeated, Opts) of
	       true -> {FNum, Name, lists:reverse(Value)};
	       _ -> Field
	     end;
	 _ -> Field
       end
     end
     || {FNum, Name, Value} = Field <- FieldList].

unpack_value(Binary, string) when is_binary(Binary) ->
    binary_to_list(Binary);
unpack_value(Value, _) -> Value.

to_record(ownrequest, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       ownrequest),
						   Record, Name, Val)
			  end,
			  #ownrequest{}, DecodedTuples),
    Record1;
to_record(owngetpokemonsrequest, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       owngetpokemonsrequest),
						   Record, Name, Val)
			  end,
			  #owngetpokemonsrequest{}, DecodedTuples),
    Record1;
to_record(ownsendpokemonsrequest, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       ownsendpokemonsrequest),
						   Record, Name, Val)
			  end,
			  #ownsendpokemonsrequest{}, DecodedTuples),
    Record1;
to_record(ownpokemon, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       ownpokemon),
						   Record, Name, Val)
			  end,
			  #ownpokemon{}, DecodedTuples),
    Record1;
to_record(ownresponse, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       ownresponse),
						   Record, Name, Val)
			  end,
			  #ownresponse{}, DecodedTuples),
    Record1;
to_record(owngetpokemonsresponse, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       owngetpokemonsresponse),
						   Record, Name, Val)
			  end,
			  #owngetpokemonsresponse{}, DecodedTuples),
    Record1.

decode_extensions(Record) -> Record.

decode_extensions(_Types, [], Acc) ->
    dict:from_list(Acc);
decode_extensions(Types, [{FNum, Bytes} | Tail], Acc) ->
    NewAcc = case lists:keyfind(FNum, 1, Types) of
	       {FNum, Name, Type, Opts} ->
		   {Value1, Rest1} = case lists:member(is_record, Opts) of
				       true ->
					   {{FNum, V}, R} =
					       protobuffs:decode(Bytes, bytes),
					   RecVal = decode(Type, V),
					   {RecVal, R};
				       false ->
					   case lists:member(repeated_packed,
							     Opts)
					       of
					     true ->
						 {{FNum, V}, R} =
						     protobuffs:decode_packed(Bytes,
									      Type),
						 {V, R};
					     false ->
						 {{FNum, V}, R} =
						     protobuffs:decode(Bytes,
								       Type),
						 {unpack_value(V, Type), R}
					   end
				     end,
		   case lists:member(repeated, Opts) of
		     true ->
			 case lists:keytake(FNum, 1, Acc) of
			   {value, {FNum, Name, List}, Acc1} ->
			       decode(Rest1, Types,
				      [{FNum, Name,
					lists:reverse([int_to_enum(Type, Value1)
						       | lists:reverse(List)])}
				       | Acc1]);
			   false ->
			       decode(Rest1, Types,
				      [{FNum, Name, [int_to_enum(Type, Value1)]}
				       | Acc])
			 end;
		     false ->
			 [{FNum,
			   {optional, int_to_enum(Type, Value1), Type, Opts}}
			  | Acc]
		   end;
	       false -> [{FNum, Bytes} | Acc]
	     end,
    decode_extensions(Types, Tail, NewAcc).

set_record_field(Fields, Record, '$extensions',
		 Value) ->
    Decodable = [],
    NewValue = decode_extensions(element(1, Record),
				 Decodable, dict:to_list(Value)),
    Index = list_index('$extensions', Fields),
    erlang:setelement(Index + 1, Record, NewValue);
set_record_field(Fields, Record, Field, Value) ->
    Index = list_index(Field, Fields),
    erlang:setelement(Index + 1, Record, Value).

list_index(Target, List) -> list_index(Target, List, 1).

list_index(Target, [Target | _], Index) -> Index;
list_index(Target, [_ | Tail], Index) ->
    list_index(Target, Tail, Index + 1);
list_index(_, [], _) -> -1.

extension_size(_) -> 0.

has_extension(_Record, _FieldName) -> false.

get_extension(_Record, _FieldName) -> undefined.

set_extension(Record, _, _) -> {error, Record}.

