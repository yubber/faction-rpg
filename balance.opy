#!mainFile "main.opy"

globalvar shopPrices = [
    150, # dmg
    30, # ammo
    100, # hp
    80, # armor
    75, # heal
    45, # move
    15, # projectile
    # 45, # kb dealt
    175, # min ult
    750, # dmg received
    # 105000, # shrink
    1050,  # faction
    2001000, # flight
    # 2501000, # rapid
]
globalvar statCaps = [
    17500, # dmg
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
    5000, # faction bonus
    1, # flight
    # 6 # rapid
]

globalvar marketPrices = [
    2500, # caut
    80000, # shrink
    40000, # hack
    20000, # ice
    2000, # barrier
    900, # kb
    2400, # steadfast
    125000, # rapid
    65000 # move
]
globalvar marketStatCaps = [
    6, # caut
    40, # shrink
    8, # hack
    6, # freeze
    1000, # barrier
    500, # kb
    100, # steadfast
    12, # dakka
    200 # move
]

### BLOODMONEY
#!define ElimPay max(300, 0.5*victim.level) * MoneyMult
# bonuses to both steal portion & base money increase. update victim money loss if changing
#!define KillPay ((max(900, 2*victim.level)*MoneyMult + victim.money * stealPortion * (1.5 if victim.faction == FACTIONS.RICH and victim.money > eventPlayer.money else 1)) * (1.4 if eventPlayer.faction == FACTIONS.RICH else 1)) * (eventDetail if eventType == EVENTS.KILL else 1)

#!define RevengePay MoneyMult * victim.level * 1.5
#!define RevengePoints FactPointsMult * victim.level * 0.75
# idk what to call this. it's for gaia & bourgeois bonuses for bank & crypto kills
#!define NaughtyPay MoneyMult * victim.level * 1.2
#!define NaughtyPoints FactPointsMult * victim.level * 1.5

#!define BossPay 3500 * MoneyMult
#!define BossKilledPay eventDetail.level * 3 * MoneyMult
#!define BossDiePenalty eventDetail.level * 0.7

### FACTIONS
# deprecated. was used to make weaker factions progress faster.
#!define FactCompensationMult 1
# max(0.6, 1 + 0.175 * (4 - factMembers[eventPlayer.faction]))

### GENS
#!define CryptoBaseMoney 50
#!define CryptoAddMoney 45

#!define BegMoney 100

# bloodformula does not sync with text on blood god or cult faction intro
#!define BloodFormula (eventPlayer.getMaxHealth() * (1.3*0.05 if eventPlayer.faction == FACTIONS.BLOOD else 0.05) * (eventDetail if eventType == EVENTS.BLOOD else 1) * MoneyMult)

# moon formula is money/s, not per tick
#!define MoonFormula min(ceil(bestPlayer.level / 50), 800)

### UPGRADES
#!define RapidCd 35

### QUESTS
#!define QuestReward ((850 + 2 * eventPlayer.level) * ((0.5 if eventPlayer.faction == FACTIONS.SOMBRUH else 0 ) + MoneyMult))

### REBIRTH
# update rebirth text too bc it uses localplayer
#!define RebirthLevel (4000 + 25000 * eventPlayer.statLimit)
# base stat cap is defined in vars.opy
#!define RebirthBonus 0.2