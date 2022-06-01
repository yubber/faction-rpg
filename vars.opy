#!mainFile "main.opy"

#!define ShopCamPos vect(67.5, 8.5, -27.3)
#!define ShopLookPos vect(69.5, 8.5, -28.5)
#!define BloodRadius 4.7
#!define QuestPos vect(165.7, 12, 36.2)
#!define GoldPos vect(123.2, 7, -17.2)
#!define GoldRadius 5.5
#!define CryptoPos vect(184.1, 13.8, 40.8)
#!define CryptoRadius 5.7
#!define BankPos vect(159.1, 10, -7.7)

enum FACTIONS: # -1 for none, -2 for yet to skip/finish tutorial
    GAIA,
    BLOOD,
    RICH,
    SOMBRUH # must be last

enum STATS:
    DAMAGE,
    AMMO,
    HEALTH,
    HEALING,
    MOVESPEED,
    PROJECTILE,
    # KNOCK,
    ULT,
    DEFENSE,
    # SHRINK,
    OBJECTIVE,
    FLIGHT,
    DAKKA

enum QUEST_TYPE: # -1 for no quest but it's not using this enum. welp
    HITMAN,
    VISIT,
    BLOOD,
    CRYPTO,
    DAMAGE # must be last

enum EVENTS: # -1 for no event but it's not using this enum. oops
    GRAVITY,
    KILL,
    BLOOD,
    BOSS,
    HERO # must be last

# market enum below

### tutorial ###
globalvar tutoCams = [vect(92.96, 76.23, -66.61), vect(108.8, 11.45, 1.64), vect(106.6, 16, 17.9), vect(165.2, 20.16, 35.53), vect(162.96, 15.15, 27.1), vect(140.6, 13.1, -6), vect(57.8, 9.3, -17.8), vect(127.41, 39.38, -35.03)]
globalvar tutoLooks = [vect(87.21, 20.45, 16.63), 4*Vector.UP + GoldPos, vect(131.1, 12, 26.1), vect(198.12, 15, 44.7), vect(166.4, 10.85, 39.6), vect(153.2, 10, -9.56), vect(59.73, 8, -27.1), vect(107.7, 11, 3.4)]
globalvar tutoStrings = [
    "welcome to the 131269th rpg gamemode in overwatch workshop.",
    "a good way to get money when you start is to be a sugar baby. be careful though, there'll be competition.",
    "once you level up, the blood god will be more profitable. just make sure you can pay the price...",
    "you can also accelerate global warming for a quick buck. but you'll have to learn to play nice.",
    "getting quests from sombra also gives you money. this scales with your level.",
    "increase your income by making progress for your faction.",
    "hold crouch + interact to enter the shop and upgrade your stats.",
    "there's also another secret shop you can visit for some different perks..."
]

### factions ###
globalvar factNames = ["the children of gaia", "the cult of the blood god", "the bourgeoisie", "the crypto bros"]
globalvar factCams = [vect(106.2, 17, 4.7), vect(89.6, 13.7, 32.8), vect(140.7, 12.5, 6.8), vect(200.7, 18.9, 70.4)]
globalvar factSpawns = [vect(98.38, 14, 14.15), vect(66, 15.4, 14.5), vect(144.65, 11, -8.53), vect(184.13, 19, 73.26)]
globalvar factGoalStrings = [
    "kill blizzcoin miners, avenge your faction members and heal the wounded.",
    "blood for the blood god.",
    "hoard money in the bank and defend it from robbers.",
    "advance sombra's nefarious agenda."
] # USED FOR TROON CHECK
globalvar factDescs = [ # default initial stat overrides (eg gaia) also affect refunding. change the rule.
    "heal others by 60 HP/s by crouching near them.\neach player healed gives you $100/s (faction earnings bonus is doubled for this amount).\nyou deal 75% more damage to faction enemies and blizzcoin miners. kill them to earn money and faction points.\nyou regen 20 HP/s while crouching and start with 25% less damage taken & dealt.\nhealing faction mates only grants half the money & faction points.",
    "heal for 10% of dealt damage.\nfeed the blood god to advance your faction level.\nit increases lifesteal to 40% and gives 50% more money.\nhalf of damage dealt contributes to your faction goal.",
    "when you get a killing blow your held money increases by 10% and you earn double the money,\nbut enemies steal 50% more money from killing you if you have more money than them.",
    "gain double the earnings from quests and 40% ult charge upon completing them.\nwhen mining blizzcoin you count as 1.5 players.\nyour melee hacks enemies briefly."
]
globalvar factMembers = [0, 0, 0, 0]
globalvar factLevels = [0, 0, 0, 0] # 1 = +10% income
globalvar factPoints = [0, 0, 0, 0] # basically xp. fixed scaling according to levels. USED FOR TROON CHECK
globalvar factLvUp = [5000, 5000, 5000, 5000]

### shop ###
globalvar shopIcons = [
    abilityIconString(Hero.GENJI, Button.ULTIMATE),
    abilityIconString(Hero.DVA, Button.ABILITY_2),
    iconString(Icon.HEART),
    abilityIconString(Hero.BAPTISTE, Button.ABILITY_1),
    abilityIconString(Hero.SOLDIER, Button.ABILITY_1),
    abilityIconString(Hero.HANZO, Button.ABILITY_2),
    # abilityIconString(Hero.PHARAH, Button.ABILITY_2),
    abilityIconString(Hero.ANA, Button.ULTIMATE),
    abilityIconString(Hero.BRIGITTE, Button.SECONDARY_FIRE),
    # abilityIconString(Hero.ORISA, Button.SECONDARY_FIRE),
    abilityIconString(Hero.BRIGITTE, Button.ULTIMATE),
    abilityIconString(Hero.MERCY, Button.ULTIMATE),
    abilityIconString(Hero.PHARAH, Button.ULTIMATE)
]
globalvar shopItems = [
    "damage dealt",
    "ammo capacity",
    "max health",
    "healing received",
    "movement speed",
    "projectile speed & lightness",
    # "knockback dealt",
    "minimum ult charge",
    "damage received",
    # "player shrinking",
    "faction goal progress",
    "flight (hold {})".format(Button.JUMP),
    "rapid fire ({} + {})".format(Button.INTERACT, Button.MELEE)
]
globalvar shoppers = []
globalvar baseStats = [
    100, # dmg
    100, # ammo
    100, # hp
    100, # heal
    100, #movespeed
    100, #projectile
    # 100, # kb
    0, # min ult
    -100, #dr
    # 0, #shrink
    100, #objective
    false, # flight (false + 1 = 1)
    0 # rapid
]
globalvar shopUnits = [
    "%", # dmg
    "%", # ammo
    "%", # hp
    "%", # heal
    "%", #movespeed
    "%", #projectile
    # "%", # kb
    "%", # min ult
    "%", #dr
    # "%", #shrink
    "%", #objective
    "", # flight
    "sec", # rapid
]
# globalvar shopCamPosArr = [vect(67.5, 8.5, -27.3)]
#!define ShopLen len(shopItems)
# shop prices & stat caps in balance.opy

### black market ###
enum MARKET:
    CAUT,
    SHRINK,
    HACK,
    ICE,
    BARRIER,
    KNOCK,
    STEADFAST,
    MOVESPEED

globalvar marketNo
globalvar marketItems = [
    "{} caut-ton candy".format(abilityIconString(Hero.ANA, Button.ABILITY_2)), # reduce heal by up to 50% on hit, upgrade duration to 3s
    "{} smallties".format(abilityIconString(Hero.ORISA, Button.SECONDARY_FIRE)), # shrinking up to 0.6x size
    "{} hackshey's kisses".format(abilityIconString(Hero.SOMBRA, Button.ULTIMATE)), # hack when you bring target below 50% hp
    "{} ice scream".format(abilityIconString(Hero.MEI, Button.ABILITY_1)), # freeze nearby enemies when you get killing blow
    "{} barriero rocher".format(abilityIconString(Hero.SYMMETRA, Button.ULTIMATE)), # barrier
    "{} kick kat".format(abilityIconString(Hero.DOOMFIST, Button.SECONDARY_FIRE)), # kb dealt
    "{} knockstoppers".format(abilityIconString(Hero.ORISA, Button.ABILITY_1)), # kb received
    "{} fruit rollouts".format(abilityIconString(Hero.SOLDIER, Button.ABILITY_1)) # extra speed
]
globalvar marketDescs = [
    "hitting an enemy halves their healing received.\nlevel of this item is effect duration (seconds).\neffect doesn't stack but duration refreshes.",
    "shrink yourself.\neach level reduces your size by 1%.",
    "hack enemies when you drop their health below half.\nlevel of this item is effect duration (seconds).",
    "freeze nearby enemies when you deal a killing blow.\nlevel of this item is effect duration (seconds).",
    "make your shields & walls bigger.\neach level increases size by 1%.",
    "take better control of your personal space.\neach level increases knockback dealt by 1%.",
    "become resistant to knockbacks.\neach level decreases knockback received by 1%.",
    "go even faster.\neach level adds 1% to your current movement speed."
]
globalvar baseMarketStats = [
    0, # caut
    0, # shrink
    0, # hack
    0, # freeze
    100, # barrier
    0, # kb
    0, # steadfast
    0 # move
]
globalvar marketQuips = [
    "pleasure doing business with you.",
    "remember, you are what you eat!",
    "don't worry, i won't tell your mom.",
    "please don't tell mommy i sold you these.",
    "you're supposed to eat these by the way. one of my customers ground them up and snorted them...",
    "you better not throw the wrapper on the floor.",
    "come back soon!",
    "not many people stop by nowadays. must be those darn razor blades...",
    "you should probably book a dentist appointment soon.",
    "don't eat it too quickly. why? uh... it's not because there could be razor blades or anything!"
]
globalvar marketTime

globalvar i_init
globalvar stealPortion

### quests ###
globalvar questText = [
    "get a killing blow on ",
    "enter the base of ",
    "stay in the blood god for ",
    "mine blizzcoin to get $",
    "damage other players: "
]
globalvar sombraQuips = [
    [ # kill
        "i want that bitch dead. go.",
        "go \"befriend\" that guy's mom",
        "wouldn't be an rpg gamemode without murder.",
        "i don't actually know that person, i just want to see you both struggle."
    ],
    [ # visit
        "i need you to get some intel for me.",
        "we do a little peeping",
        "go on over to that faction's base, i'm sure they won't shoot you or anything.",
        "my crush is in that faction and i need uh..."
    ],
    [ # blood
        "don't ask me what my business is with that thing.",
        "ngl the blood god is kinda thicc tho",
        "no need to be scared, it's just an eldritch god.",
        "i've seen the blood god's browser history. i wish i didn't.",
        "would you be surprised if i told you there's a ton of blood god fanfics? no? i guess i should've known."
    ],
    [ # crypto
        "those gaia nerds need to be taken down a peg. thankfully the mine is coal powered.",
        "i wanna sell my stock, go buy a bunch of blizzcoin so i make more dough.",
        "i know more people mining gives you more money, but it'll be really funny if you kill everyone who joins you.",
        "just so you know, the gpu shortage has absolutely nothing to do with me. just kidding."
    ],
    [ # damage
        "i'm bored, go shoot some people so i can watch the catfight.",
        "you better not ask to farm damage like a coward",
        "i love me some violence.",
        "peace is overrated. those gaia hippies don't know what they're talking about."
    ]
]

### crypto mine ###
globalvar minerCount

### moon ###
globalvar moonPos
globalvar moonPosArr = [vect(147.9, 14, 49.5), vect(108.5, 11, -31), vect(110, 18.1, -0.4), vect(132.2, 17.7, 11.1)]
globalvar moonOwner # briefly used for trooning

### event ###
globalvar eventType
globalvar eventDetail
globalvar eventText
globalvar eventTime

### general ###
globalvar antiCrashActivated

### personal ###
playervar level = 1
playervar money
playervar stats = baseStats # only for stuff in the normal shop
playervar marketStats = baseMarketStats
playervar option = 0 # also used for tutorial i in for loop. sorry
playervar buyqty # also used for blood time. sorry
playervar hudId
# dakka
playervar dakkaTime
playervar dakkaFx # sparkle effect
# event
playervar eventVar # use for any event
# misc
playervar blower # player who dealt final blow, used to separate final blow & elim events
playervar cautTime

### quests ###
playervar questType = -1
playervar questProgress
playervar questGoal

### mines ###
playervar bloodDoT
playervar bloodFx
playervar mineFx

### faction ###
playervar faction = -1 # -2 is spaghetti for "not done viewing tutorial" (viewing or yet to choose to skip)
playervar enemies = []