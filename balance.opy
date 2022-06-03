#!mainFile "main.opy"

globalvar shopPrices = [
    175, # dmg
    40, # ammo
    110, # hp
    90, # armor
    90, # heal
    75, # move
    25, # projectile
    # 45, # kb dealt
    250, # min ult
    1200, # dmg received
    # 105000, # shrink
    175,  # faction
    2001000, # flight
    # 2501000, # rapid
]
globalvar statCaps = [
    50000, # dmg
    1000, # ammo
    10000, # hp
    10000, # armor
    50000, # heal
    175, # move
    500, # projectile
    # 500, # kb
    85, # min ult
    -40, # dmg received
    # 40, # shrink
    50000, # faction bonus
    1, # flight
    # 6 # rapid
]

globalvar marketPrices = [
    5000, # caut
    205000, # shrink
    85000, # hack
    25000, # ice
    4000, # barrier
    1200, # kb
    1800, # steadfast
    901000, # rapid
    120000 # move
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

#!define BaseFactionMembers 4
#!define CryptoBaseMoney 35
#!define CryptoAddMoney 45
#!define BegMoney 80
#!define RapidCd 35
#!define QuestReward ((2000 + 2 * eventPlayer.level) * (2 if eventPlayer.faction == FACTIONS.SOMBRUH else 1) * MoneyMult)
# bloodformula does not sync with text on blood god or cult faction intro
#!define BloodFormula (eventPlayer.getMaxHealth() * (0.065 if eventPlayer.faction == FACTIONS.BLOOD else 0.05) * (eventDetail if eventType == EVENTS.BLOOD else 1) * MoneyMult)
# moon formula is money/s, not per tick
#!define MoonFormula min(0.05*getTotalTimeElapsed(), 3500)