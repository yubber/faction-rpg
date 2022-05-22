#!mainFile "main.opy"

enum FACTIONS:
    GAIA,
    BLOOD,
    RICH,
    SOMBRUH

enum STATS:
    DAMAGE,
    AMMO,
    HEALTH,
    HEALING,
    MOVESPEED,
    PROJECTILE,
    KNOCK,
    ULT,
    DEFENSE,
    SHRINK,
    OBJECTIVE

enum QUEST_TYPE:
    HITMAN,
    VISIT,
    BLOOD,
    DAMAGE

# globalvar shopCamPosArr = [vect(67.5, 8.5, -27.3)]
globalvar factNames = ["the children of gaia", "the cult of the blood god", "the bourgeoisie", "the crypto bros"]
globalvar factCams = [vect(106.2, 17, 4.7), vect(89.6, 13.7, 32.8), vect(140.7, 12.5, 6.8), vect(200.7, 18.9, 70.4)]
globalvar factSpawns = [vect(98.38, 14, 14.15), vect(66, 15.4, 14.5), vect(144.65, 11, -8.53), vect(184.13, 19, 73.26)]
globalvar factGoalStrings = [
    "heal other players or kill wanted players.",
    "make offerings to the blood god or draw blood from others.",
    "hoard money in the bank and defend it from robbers.",
    "simp for sombra and do her bidding."
]
globalvar factDescs = [ # default initial stat overrides also affect refunding. change the rule.
    "heal others by 60 HP/s by crouching near them.\neach player healed gives you $100/s. faction earnings bonus is doubled for this amount.\nyou regen 15 HP/s and start with 25% less damage taken & dealt.\nyou deal 75% more damage to faction enemies and blizzcoin miners.",
    "heal for 10% of your dealt damage.\nfeeding the blood god increases lifesteal to 40% and gives 50% more money.\n40% of damage dealt contributes to your faction goal.",
    "increase your held money by 10% when getting eliminations and double money earned from kills,\nbut enemies steal 50% more money from killing you if you have more money than them.",
    "gain double the earnings from quests and 40% ult charge upon completing them.\nwhen mining blizzcoin you count as 1.5 players.\nyour melee hacks enemies briefly."
]
globalvar shopIcons = [
    abilityIconString(Hero.GENJI, Button.ULTIMATE),
    abilityIconString(Hero.DVA, Button.ABILITY_2),
    iconString(Icon.HEART),
    abilityIconString(Hero.BAPTISTE, Button.ABILITY_1),
    abilityIconString(Hero.SOLDIER, Button.ABILITY_1),
    abilityIconString(Hero.HANZO, Button.ABILITY_2),
    abilityIconString(Hero.PHARAH, Button.ABILITY_2),
    abilityIconString(Hero.ANA, Button.ULTIMATE),
    abilityIconString(Hero.BRIGITTE, Button.SECONDARY_FIRE),
    abilityIconString(Hero.ORISA, Button.SECONDARY_FIRE),
    abilityIconString(Hero.BRIGITTE, Button.ULTIMATE)
]
globalvar shopItems = [
    "damage dealt",
    "ammo capacity",
    "max health",
    "healing received",
    "movement speed",
    "projectile speed & lightness",
    "knockback dealt"
    "minimum ult charge",
    "damage received",
    "player shrinking",
    "faction goal progress",
]
globalvar shopPrices = [
    60, # dmg
    40, # ammo
    55, # hp
    45, # heal
    35, # move
    15, # projectile
    80, # min ult
    35, # kb dealt
    100, # dmg received
    200, # shrink
    50,  # faction
]
globalvar statCaps = [
    99999, # dmg
    1000, # ammo
    10000, # hp
    99999, # heal
    500, # move
    500, # projectile
    99, # min ult
    500, # kb
    -40, # dmg received
    60, # shrink
    50000 # faction bonus
]
globalvar factMembers = [0, 0, 0, 0]
globalvar factLevels = [0, 0, 0, 0] # 1 = +10% income
globalvar factPoints = [0, 0, 0, 0] # basically xp. fixed scaling according to levels.
globalvar factLvUp = [5000, 5000, 5000, 5000]
globalvar i_init
globalvar shoppers = []
globalvar baseStats = [
    100, # dmg
    100, # ammo
    100, # hp
    100, # heal
    100, #movespeed
    100, #projectile
    0, # min ult
    100, # kb
    -100, #dr
    0, #shrink
    100 #objective
]
globalvar stealPortion
globalvar questText = [
    "get a killing blow on:",
    "enter this faction's base:",
    "stay in the blood god",
    "damage other players"
]
globalvar antiCrashActivated
globalvar minerCount
globalvar sombraQuips = [
    [ # kill
        "i want that bitch dead. go.",
        "go fuck that guy's mom",
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
        "i've seen the blood god's browser history. i wish i didn't."
    ],
    [ # damage
        "i'm bored, go shoot some people so i can watch the catfight.",
        "you better not ask to farm damage like a coward",
        "i love me some violence.",
        "peace is overrated. those gaia hippies don't know what they're talking about."
    ]
]

playervar level = 1
playervar money
playervar faction = -1
playervar enemies = []
playervar option = 0
playervar stats = baseStats
playervar questType = -1
playervar questProgress
playervar questGoal
playervar buyqty # also used for blood time. sorry
playervar bloodDoT
playervar bloodFx
playervar mineFx
playervar hudId