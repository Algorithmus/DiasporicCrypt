
extends Node

# Factory for all items in the game

var items = {}
var itemclass = preload("res://scenes/items/BasicItem.gd")
var scrollclass = preload("res://scenes/items/scroll/ScrollItem.gd")

func _init():
	items["exp"] = {"type": "exp"}
	items["gold"] = {"type": "gold"}
	
	var amulet = itemclass.new()
	amulet.title = "ITEM_AMULET"
	amulet.description = "ITEM_AMULET_DESCRIPTION"
	amulet.type = "special"
	amulet.image = "res://scenes/items/special/amulet.png"
	items[amulet.title] = amulet
	
	var styxinscription = itemclass.new()
	styxinscription.title = "ITEM_STYXINSCRIPTION"
	styxinscription.description = "ITEM_STYX_DESCRIPTION"
	styxinscription.type = "special"
	styxinscription.image = "res://scenes/items/special/styxinscription.png"
	items[styxinscription.title] = styxinscription
	
	var styxchalice = itemclass.new()
	styxchalice.title = "ITEM_STYXCHALICE"
	styxchalice.description = "ITEM_STYX_DESCRIPTION"
	styxchalice.type = "special"
	styxchalice.image = "res://scenes/items/special/styxchalice.png"
	items[styxchalice.title] = styxchalice
	
	var styxcoin = itemclass.new()
	styxcoin.title = "ITEM_STYXCOIN"
	styxcoin.description = "ITEM_STYX_DESCRIPTION"
	styxcoin.type = "special"
	styxcoin.image = "res://scenes/items/special/styxcoin.png"
	items[styxcoin.title] = styxcoin
	
	var styxtome = itemclass.new()
	styxtome.title = "ITEM_STYXTOME"
	styxtome.description = "ITEM_STYX_DESCRIPTION"
	styxtome.type = "special"
	styxtome.image = "res://scenes/items/special/styxtome.png"
	items[styxtome.title] = styxtome

	var styxfigurine = itemclass.new()
	styxfigurine.title = "ITEM_STYXFIGURINE"
	styxfigurine.description = "ITEM_STYX_DESCRIPTION"
	styxfigurine.type = "special"
	styxfigurine.image = "res://scenes/items/special/styxfigurine.png"
	items[styxfigurine.title] = styxfigurine

	var styxbrooch = itemclass.new()
	styxbrooch.title = "ITEM_STYXBROOCH"
	styxbrooch.description = "ITEM_STYX_DESCRIPTION"
	styxbrooch.type = "special"
	styxbrooch.image = "res://scenes/items/special/styxbrooch.png"
	items[styxbrooch.title] = styxbrooch

	var styxcrest = itemclass.new()
	styxcrest.title = "ITEM_STYXCREST"
	styxcrest.description = "ITEM_STYX_DESCRIPTION"
	styxcrest.type = "special"
	styxcrest.image = "res://scenes/items/special/styxcrest.png"
	items[styxcrest.title] = styxcrest

	var styxmirror = itemclass.new()
	styxmirror.title = "ITEM_STYXMIRROR"
	styxmirror.description = "ITEM_STYX_DESCRIPTION"
	styxmirror.type = "special"
	styxmirror.image = "res://scenes/items/special/styxmirror.png"
	items[styxmirror.title] = styxmirror

	var rubykey = itemclass.new()
	rubykey.title = "ITEM_RUBYKEY"
	rubykey.description = "ITEM_RUBYKEY_DESCRIPTION"
	rubykey.type = "special"
	rubykey.image = "res://scenes/items/special/rubykey.png"
	items[rubykey.title] = rubykey
	
	var emeraldkey = itemclass.new()
	emeraldkey.title = "ITEM_EMERALDKEY"
	emeraldkey.description = "ITEM_EMERALDKEY_DESCRIPTION"
	emeraldkey.type = "special"
	emeraldkey.image = "res://scenes/items/special/emeraldkey.png"
	items[emeraldkey.title] = emeraldkey
	
	var sapphirekey = itemclass.new()
	sapphirekey.title = "ITEM_SAPPHIREKEY"
	sapphirekey.description = "ITEM_SAPPHIREKEY_DESCRIPTION"
	sapphirekey.type = "special"
	sapphirekey.image = "res://scenes/items/special/sapphirekey.png"
	items[sapphirekey.title] = sapphirekey
	
	var diamondkey = itemclass.new()
	diamondkey.title = "ITEM_DIAMONDKEY"
	diamondkey.description = "ITEM_DIAMONDKEY_DESCRIPTION"
	diamondkey.type = "special"
	diamondkey.image = "res://scenes/items/special/diamondkey.png"
	items[diamondkey.title] = diamondkey
	
	var topazkey = itemclass.new()
	topazkey.title = "ITEM_TOPAZKEY"
	topazkey.description = "ITEM_TOPAZKEY_DESCRIPTION"
	topazkey.type = "special"
	topazkey.image = "res://scenes/items/special/topazkey.png"
	items[topazkey.title] = topazkey
	
	var peridotkey = itemclass.new()
	peridotkey.title = "ITEM_PERIDOTKEY"
	peridotkey.description = "ITEM_PERIDOTKEY_DESCRIPTION"
	peridotkey.type = "special"
	peridotkey.image = "res://scenes/items/special/peridotkey.png"
	items[peridotkey.title] = peridotkey
	
	var amethystkey = itemclass.new()
	amethystkey.title = "ITEM_AMETHYSTKEY"
	amethystkey.description = "ITEM_AMETHYSTKEY_DESCRIPTION"
	amethystkey.type = "special"
	amethystkey.image = "res://scenes/items/special/amethystkey.png"
	items[amethystkey.title] = amethystkey
	
	var potion = itemclass.new()
	potion.title = "ITEM_POTION"
	potion.description = "ITEM_POTION_DESCRIPTION"
	potion.type = "item"
	potion.value = 100
	potion.image = "res://scenes/items/potion/potion.png"
	potion.effect = "hp"
	potion.cost = 100
	items[potion.title] = potion
	
	var potionplus = itemclass.new()
	potionplus.title = "ITEM_POTION+"
	potionplus.description = "ITEM_POTION+_DESCRIPTION"
	potionplus.type = "item"
	potionplus.value = 500
	potionplus.image = "res://scenes/items/potion/potionplus.png"
	potionplus.effect = "hp"
	potionplus.cost = 1000
	items[potionplus.title] = potionplus

	var potionplusplus = itemclass.new()
	potionplusplus.title = "ITEM_POTION++"
	potionplusplus.description = "ITEM_POTION++_DESCRIPTION"
	potionplusplus.type = "item"
	potionplusplus.value = 2000
	potionplusplus.image = "res://scenes/items/potion/potionplusplus.png"
	potionplusplus.effect = "hp"
	potionplusplus.cost = 3000
	items[potionplusplus.title] = potionplusplus

	var manapotion = itemclass.new()
	manapotion.title = "ITEM_MANAPOTION"
	manapotion.description = "ITEM_MANAPOTION_DESCRIPTION"
	manapotion.type = "item"
	manapotion.value = 20
	manapotion.image = "res://scenes/items/potion/manapotion.png"
	manapotion.effect = "mp"
	manapotion.cost = 500
	items[manapotion.title] = manapotion

	var manapotionplus = itemclass.new()
	manapotionplus.title = "ITEM_MANAPOTION+"
	manapotionplus.description = "ITEM_MANAPOTION+_DESCRIPTION"
	manapotionplus.type = "item"
	manapotionplus.value = 50
	manapotionplus.image = "res://scenes/items/potion/manapotionplus.png"
	manapotionplus.effect = "mp"
	manapotionplus.cost = 2000
	items[manapotionplus.title] = manapotionplus

	var manapotionplusplus = itemclass.new()
	manapotionplusplus.title = "ITEM_MANAPOTION++"
	manapotionplusplus.description = "ITEM_MANAPOTION++_DESCRIPTION"
	manapotionplusplus.type = "item"
	manapotionplusplus.value = 250
	manapotionplusplus.image = "res://scenes/items/potion/manapotionplusplus.png"
	manapotionplusplus.effect = "mp"
	manapotionplusplus.cost = 5000
	items[manapotionplusplus.title] = manapotionplusplus

	var strengthpotion = itemclass.new()
	strengthpotion.title = "ITEM_STRENGTHPOTION"
	strengthpotion.description = "ITEM_STRENGTHPOTION_DESCRIPTION"
	strengthpotion.type = "item"
	strengthpotion.value = 1
	strengthpotion.image = "res://scenes/items/potion/strengthpotion.png"
	strengthpotion.effect = "atk"
	strengthpotion.cost = 10000
	items[strengthpotion.title] = strengthpotion

	var shieldpotion = itemclass.new()
	shieldpotion.title = "ITEM_SHIELDPOTION"
	shieldpotion.description = "ITEM_SHIELDPOTION_DESCRIPTION"
	shieldpotion.type = "item"
	shieldpotion.value = 1
	shieldpotion.image = "res://scenes/items/potion/shieldpotion.png"
	shieldpotion.effect = "def"
	shieldpotion.cost = 10000
	items[shieldpotion.title] = shieldpotion

	var charmpotion = itemclass.new()
	charmpotion.title = "ITEM_CHARMPOTION"
	charmpotion.description = "ITEM_CHARMPOTION_DESCRIPTION"
	charmpotion.type = "item"
	charmpotion.value = 1
	charmpotion.image = "res://scenes/items/potion/charmpotion.png"
	charmpotion.effect = "luck"
	charmpotion.cost = 25000
	items[charmpotion.title] = charmpotion

	var mysticpotion = itemclass.new()
	mysticpotion.title = "ITEM_MYSTICPOTION"
	mysticpotion.description = "ITEM_MYSTICPOTION_DESCRIPTION"
	mysticpotion.type = "item"
	mysticpotion.value = 1
	mysticpotion.image = "res://scenes/items/potion/mysticpotion.png"
	mysticpotion.effect = "mag"
	mysticpotion.cost = 10000
	items[mysticpotion.title] = mysticpotion

	var scroll = scrollclass.new()
	scroll.title = "SCROLL_START"
	scroll.display = "SCROLL_START_TITLE"
	scroll.content = "SCROLL_START_DESCRIPTION"
	scroll.description = "SCROLL_START_SHORT"
	scroll.order = 0
	items[scroll.title] = scroll
	
	var scrollfight = scrollclass.new()
	scrollfight.title = "SCROLL_FIGHT"
	scrollfight.display = "SCROLL_FIGHT_TITLE"
	scrollfight.content = "SCROLL_FIGHT_DESCRIPTION"
	scrollfight.description = "SCROLL_FIGHT_SHORT"
	scrollfight.order = 1
	scrollfight.cost = 100
	items[scrollfight.title] = scrollfight
	
	var scrollmagic = scrollclass.new()
	scrollmagic.title = "SCROLL_MAGIC"
	scrollmagic.display = "SCROLL_MAGIC_TITLE"
	scrollmagic.content = "SCROLL_MAGIC_DESCRIPTION"
	scrollmagic.description = "SCROLL_MAGIC_SHORT"
	scrollmagic.order = 2
	items[scrollmagic.title] = scrollmagic
	
	var scrollwarrior = scrollclass.new()
	scrollwarrior.title = "SCROLL_WARRIOR"
	scrollwarrior.display = "SCROLL_WARRIOR_TITLE"
	scrollwarrior.content = "SCROLL_WARRIOR_DESCRIPTION"
	scrollwarrior.description = "SCROLL_WARRIOR_SHORT"
	scrollwarrior.order = 3
	items[scrollwarrior.title] = scrollwarrior
	
	var scrolladventure = scrollclass.new()
	scrolladventure.title = "SCROLL_ADVENTURE"
	scrolladventure.display = "SCROLL_ADVENTURE_TITLE"
	scrolladventure.content = "SCROLL_ADVENTURE_DESCRIPTION"
	scrolladventure.description = "SCROLL_ADVENTURE_SHORT"
	scrolladventure.order = 3
	items[scrolladventure.title] = scrolladventure
	
	var scrollmoon3 = scrollclass.new()
	scrollmoon3.title = "SCROLL_MOON3"
	scrollmoon3.display = "SCROLL_MOON3_TITLE"
	scrollmoon3.content = "SCROLL_MOON3_DESCRIPTION"
	scrollmoon3.description = "SCROLL_MOON3_SHORT"
	scrollmoon3.order = 6
	items[scrollmoon3.title] = scrollmoon3

	var thunder = itemclass.new()
	thunder.title = "MAGIC_THUNDER"
	thunder.description = "MAGIC_THUNDER_SHORT"
	thunder.type = "magic"
	thunder.image = "res://players/magic/thunder/icon.png"
	thunder.value = "thunder"
	thunder.cost = 50000
	items[thunder.title] = thunder
	
	var hex = itemclass.new()
	hex.title = "MAGIC_HEX"
	hex.description = "MAGIC_HEX_SHORT"
	hex.type = "magic"
	hex.image = "res://players/magic/hex/icon.png"
	hex.value = "hex"
	hex.cost = 50000
	items[hex.title] = hex
	
	var magicmine = itemclass.new()
	magicmine.title = "MAGIC_MAGICMINE"
	magicmine.description = "MAGIC_MAGICMINE_SHORT"
	magicmine.type = "magic"
	magicmine.image = "res://players/magic/magicmine/icon.png"
	magicmine.value = "magicmine"
	magicmine.cost = 50000
	items[magicmine.title] = magicmine

	var shield = itemclass.new()
	shield.title = "MAGIC_SHIELD"
	shield.description = "MAGIC_SHIELD_SHORT"
	shield.type = "magic"
	shield.image = "res://players/magic/shield/icon.png"
	shield.value = "shield"
	shield.cost = 50000
	items[shield.title] = shield

	var earth = itemclass.new()
	earth.title = "MAGIC_EARTH"
	earth.description = "MAGIC_EARTH_SHORT"
	earth.type = "magic"
	earth.image = "res://players/magic/earth/icon.png"
	earth.value = "earth"
	earth.cost = 0
	items[earth.title] = earth

	var wind = itemclass.new()
	wind.title = "MAGIC_WIND"
	wind.description = "MAGIC_WIND_SHORT"
	wind.type = "magic"
	wind.image = "res://players/magic/wind/icon.png"
	wind.value = "wind"
	wind.cost = 1000000
	items[wind.title] = wind

	var void = itemclass.new()
	void.title = "MAGIC_VOID"
	void.description = "MAGIC_VOID_SHORT"
	void.type = "magic"
	void.image = "res://players/magic/void/icon.png"
	void.value = "void"
	void.cost = 1000000
	items[void.title] = void

