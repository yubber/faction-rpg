#!mainFile "main.opy"

globalvar shopPrices = [
    60, # dmg
    40, # ammo
    55, # hp
    45, # heal
    50, # move
    15, # projectile
    # 45, # kb dealt
    80, # min ult
    100, # dmg received
    # 105000, # shrink
    55,  # faction
    1069420, # flight
    850420, # rapid
]
globalvar statCaps = [
    99999, # dmg
    1000, # ammo
    10000, # hp
    50000, # heal
    500, # move
    500, # projectile
    # 500, # kb
    85, # min ult
    -40, # dmg received
    # 40, # shrink
    50000, # faction bonus
    1, # flight
    6 # rapid
]
#!define BaseFactionMembers 4
#!define CryptoBaseMoney 35
#!define CryptoAddMoney 45
#!define BegMoney 80
# bloodformula does not sync with text on blood god or cult faction intro
#!define BloodFormula (eventPlayer.getMaxHealth() * (0.15 if eventPlayer.faction == FACTIONS.BLOOD else 0.1) * (eventDetail if eventType == EVENTS.BLOOD else 1) * MoneyMult)
