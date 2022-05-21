#!mainFile "main.opy"

enum FACTIONS:
    GAIA,
    BLOOD,
    RICH,
    SOMBRUH

enum STATS:
    DAMAGE,
    HEALTH,
    HEALING,
    MOVESPEED,
    PROJECTILE,
    COOLDOWNS,
    DEFENSE,
    SHRINK,
    OBJECTIVE

enum QUEST_TYPE:
    HITMAN,
    VISIT,
    BLOOD,
    DAMAGE

globalvar shopCamPosArr = [vect(67.5, 8.5, -27.3)]
globalvar factNames = ["the children of gaia", "the cult of the blood god", "the bourgeoisie", "the crypto bros"]
globalvar factSpawns = [vect(98.38, 14, 14.15), vect(66, 15.4, 14.5), vect(144.65, 11, -8.53), vect(184.13, 19, 73.26)]
globalvar factGoalStrings = [
    "heal other players or kill wanted players.",
    "make offerings to the blood god or draw blood from others.",
    "hoard money in the bank.",
    "simp for sombra and mine blizzcoin."
]
globalvar factDescs = [ # default initial stat overrides also affect refunding. change the rule.
    "heal others by 60 HP/s by crouching near them.\neach player healed gives you $100/s.\nyou regen 15 HP/s and start with 25% less damage taken & dealt.\nyou deal 75% more damage to faction enemies and blizzcoin miners.",
    "heal for 10% of your dealt damage.\nfeeding the blood god increases lifesteal to 40% and gives 50% more money.\n40% of damage dealt contributes to your faction goal.",
    "increase your held money by 10% when getting eliminations\nand double money earned from kills,\nbut enemies steal 50% more money from killing you if you have more money than them.",
    "double your earnings from quests.\ngain 5% of your max health as temporary armor upon completing them.\nwhen mining blizzcoin you count as 1.5 players."
]
globalvar shopIcons = [
    abilityIconString(Hero.GENJI, Button.ULTIMATE),
    abilityIconString(Hero.ROADHOG, Button.ABILITY_2),
    abilityIconString(Hero.BAPTISTE, Button.ABILITY_1),
    abilityIconString(Hero.SOLDIER, Button.ABILITY_1),
    abilityIconString(Hero.HANZO, Button.ABILITY_2),
    abilityIconString(Hero.TRACER, Button.ABILITY_2),
    abilityIconString(Hero.BRIGITTE, Button.SECONDARY_FIRE),
    abilityIconString(Hero.ORISA, Button.SECONDARY_FIRE),
    abilityIconString(Hero.BRIGITTE, Button.ULTIMATE)
]
globalvar shopItems = [
    "damage dealt",
    "max health",
    "healing received",
    "movement speed",
    "projectile speed & lightness",
    "cooldown reduction",
    "damage received",
    "player shrinking (%)",
    "faction goal progress %",
]
globalvar shopPrices = [
    60, # dmg
    40, # hp
    35, # heal
    30, # move
    20, # projectile
    55, # cooldowns
    60, # dmg received
    50, # shrink
    35  # faction
]
globalvar statCaps = [
    99999, # dmg
    10000, # hp
    99999, # heal
    500, # move
    500, # projectile
    50, # cooldowns
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
    100, # hp
    100, # heal
    100, #movespeed
    100, #projectile
    0, #cdr
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
        "go over to that faction's base i'm sure they won't shoot you or anything.",
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