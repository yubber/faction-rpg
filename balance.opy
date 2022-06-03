#!mainFile "main.opy"

globalvar shopPrices = [
    150, # dmg
    30, # ammo
    95, # hp
    80, # armor
    75, # heal
    45, # move
    15, # projectile
    # 45, # kb dealt
    175, # min ult
    750, # dmg received
    # 105000, # shrink
    1200,  # faction
    2001000, # flight
    # 2501000, # rapid
]
globalvar statCaps = [
    25000, # dmg
    1000, # ammo
    10000, # hp
    10000, # armor
    20000, # heal
    175, # move
    500, # projectile
    # 500, # kb
    70, # min ult
    -40, # dmg received
    # 40, # shrink
    50000, # faction bonus
    1, # flight
    # 6 # rapid
]

globalvar marketPrices = [
    2500, # caut
    150000, # shrink
    65000, # hack
    20000, # ice
    2000, # barrier
    1200, # kb
    1800, # steadfast
    401000, # rapid
    95000 # move
]
globalvar marketStatCaps = [
    6, # caut
    40, # shrink
    8, # hack
    6, # freeze
    1000, # barrier
    500, # kb
    0, # steadfast
    12, # dakka
    200 # move
]

#!define FactCompensationMult max(1, 4 - factMembers[eventPlayer.faction])
#!define CryptoBaseMoney 50
#!define CryptoAddMoney 45
#!define BegMoney 100
#!define RapidCd 35
#!define QuestReward ((700 + 1.2 * eventPlayer.level) * (1.5 if eventPlayer.faction == FACTIONS.SOMBRUH else 1) * MoneyMult)
# bloodformula does not sync with text on blood god or cult faction intro
#!define BloodFormula (eventPlayer.getMaxHealth() * (0.065 if eventPlayer.faction == FACTIONS.BLOOD else 0.05) * (eventDetail if eventType == EVENTS.BLOOD else 1) * MoneyMult)
# moon formula is money/s, not per tick
#!define MoonFormula min(0.05*getTotalTimeElapsed(), 3500)
#!define RebirthLevel