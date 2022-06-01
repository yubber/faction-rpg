#!mainFile "main.opy"

globalvar shopPrices = [
    100, # dmg
    45, # ammo
    65, # hp
    50, # heal
    55, # move
    20, # projectile
    # 45, # kb dealt
    150, # min ult
    1000, # dmg received
    # 105000, # shrink
    110,  # faction
    2001000, # flight
    2501000, # rapid
]
globalvar statCaps = [
    100000, # dmg
    1000, # ammo
    10000, # hp
    20000, # heal
    175, # move
    500, # projectile
    # 500, # kb
    85, # min ult
    -40, # dmg received
    # 40, # shrink
    50000, # faction bonus
    1, # flight
    6 # rapid
]

globalvar marketPrices = [
    60000, # caut
    205000, # shrink
    85000, # hack
    10000, # ice
    4000, # barrier
    1200, # kb
    1800, # steadfast
    95000 # move
]
globalvar marketStatCaps = [
    3, # caut
    40, # shrink
    4, # hack
    3, # freeze
    1000, # barrier
    500, # kb
    0, # steadfast
    200 # move
]

#!define BaseFactionMembers 4
#!define CryptoBaseMoney 35
#!define CryptoAddMoney 45
#!define BegMoney 80
#!define RapidCd 35
# bloodformula does not sync with text on blood god or cult faction intro
#!define BloodFormula (eventPlayer.getMaxHealth() * (0.15 if eventPlayer.faction == FACTIONS.BLOOD else 0.1) * (eventDetail if eventType == EVENTS.BLOOD else 1) * MoneyMult)