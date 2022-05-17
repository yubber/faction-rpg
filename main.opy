settings {
    "main": {
        "description": "join a faction & get unique powers to complete its supernatural goals. features catchup mechanics, diverse ways to make money & a clean interface.\n\nyubz made it",
        "modeName": "rpg with factions"
    },
    "lobby": {
        "allowPlayersInQueue": true,
        "enableMatchVoiceChat": true,
        "spectatorSlots": 12
    },
    "gamemodes": {
        "ffa": {
            "enabledMaps": [
                "dorado"
            ]
        },
        "general": {
            "spawnHealthPacks": "enabled",
            "gamemodeStartTrigger": "immediately",
            "heroLimit": "off",
            "respawnTime%": 25,
            "healthPackRespawnTime%": 350
        }
    }
}

#!define ShopCamPos vect(67.5, 8.5, -27.3)
#!define ShopLookPos vect(69.5, 8.5, -28.5)
#!define BloodRadius 4.8
#!define QuestPos vect(165.7, 12, 36.2)
#!define BaseFactionMembers 4

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
    OBJECTIVE

enum QUEST_TYPE:
    HITMAN,
    VISIT,
    BLOOD,
    DAMAGE

globalvar factNames = ["the children of gaia", "the cult of the blood god", "the bourgeoisie", "anonymous"]
globalvar factSpawns = [vect(98.38, 14, 14.15), vect(74.68, 14, 21), vect(144.65, 11, -8.53), vect(184.13, 19, 73.26)]
globalvar factGoalStrings = [
    "heal other players or kill wanted players.",
    "make offerings to the blood god or draw blood from others.",
    "hoard money in the bank.",
    "follow orders from sombra."
]
globalvar factDescs = [ # default initial stat overrides also affect refunding. change the rule.
    "heal others by 60 HP/s by crouching near them.\nyou regen 15 HP/s,\nand start with 25% less damage taken & dealt.\nyou deal 50% more damage to players who kill people in your faction.",
    "heal for 10% of your dealt damage.\nfeeding the blood god increases lifesteal to 40%, gives you 50% more money and 50% faster ult gain.\n40% of damage dealt contributes to your faction goal.",
    "increase your held money by 10% when getting eliminations\nand double money earned from kills,\nbut enemies steal 50% more money from killing you if you have more money than them.",
    "double your earnings from quests.\ngain 5% of your max health as temporary armor upon completing them."
]
globalvar shopIcons = [
    abilityIconString(Hero.GENJI, Button.ULTIMATE),
    abilityIconString(Hero.ROADHOG, Button.ABILITY_2),
    abilityIconString(Hero.BAPTISTE, Button.ABILITY_1),
    abilityIconString(Hero.SOLDIER, Button.ABILITY_1),
    abilityIconString(Hero.HANZO, Button.ABILITY_2),
    abilityIconString(Hero.TRACER, Button.ABILITY_2),
    abilityIconString(Hero.BRIGITTE, Button.SECONDARY_FIRE),
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
    50  # faction
]
globalvar statCaps = [
    99999,
    10000,
    99999,
    500,
    500,
    40,
    -40,
    50000
]
globalvar factMembers = [0, 0, 0, 0]
globalvar factPoints = [0, 0, 0, 0]
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
    100 #objective
]
globalvar stealPortion

playervar level = 0
playervar money
playervar faction = -1
playervar enemies = []
playervar option = 0
playervar stats = baseStats
playervar questData = []
playervar buyqty
playervar bloodDoT
playervar bloodFx

### inits ###
def shut():
    eventPlayer.cancelPrimaryAction()
    eventPlayer.disallowButton(Button.INTERACT)
    eventPlayer.disallowButton(Button.PRIMARY_FIRE)
    eventPlayer.disallowButton(Button.SECONDARY_FIRE)
    eventPlayer.disallowButton(Button.MELEE)
    eventPlayer.disallowButton(Button.JUMP)
    eventPlayer.disallowButton(Button.RELOAD)
    wait()
    eventPlayer.teleport(vect(6, 18.45, -59.8))
    eventPlayer.setMoveSpeed(0.01)
    eventPlayer.setGravity(0)
    eventPlayer.setStatusEffect(null, Status.PHASED_OUT, 9999)
    eventPlayer.setStatusEffect(null, Status.HACKED, 9999)
    eventPlayer.startScalingSize(0.001, false)

def resume():
    eventPlayer.setMoveSpeed(eventPlayer.stats[STATS.MOVESPEED])
    eventPlayer.setGravity(100)
    eventPlayer.clearStatusEffect(Status.PHASED_OUT)
    eventPlayer.clearStatusEffect(Status.HACKED)
    eventPlayer.allowButton(Button.ABILITY_1)
    eventPlayer.allowButton(Button.ABILITY_2)
    eventPlayer.allowButton(Button.CROUCH)
    eventPlayer.allowButton(Button.INTERACT)
    eventPlayer.allowButton(Button.PRIMARY_FIRE)
    eventPlayer.allowButton(Button.SECONDARY_FIRE)
    eventPlayer.allowButton(Button.MELEE)
    eventPlayer.allowButton(Button.ULTIMATE)
    eventPlayer.allowButton(Button.JUMP)
    eventPlayer.allowButton(Button.RELOAD)
    eventPlayer.stopScalingSize()
    eventPlayer.respawn()

rule "global init":
    stealPortion = createWorkshopSetting(float[0.05:0.5], "gameplay", "portion of money stolen on killing blows", 0.15)

    ### blood god ###
    createEffect(getAllPlayers(), Effect.ORB, Color.RED,
        vect(131.1, 14.5, 26.1) + vect(0, 0.5*sin(2*getTotalTimeElapsed() % 6.283), 0), 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getAllPlayers(), Effect.RING, Color.RED, vect(131.1, 11, 26.1), BloodRadius, EffectReeval.VISIBILITY)
    createInWorldText(getAllPlayers(), "blood god - sacrifice 10% max hp /s\nfor money (1 hp : $3)", vect(131.1, 15.3, 26.1), 1.5, Clip.SURFACES, WorldTextReeval.VISIBILITY, Color.WHITE, SpecVisibility.DEFAULT)
    createEffect(getAllPlayers(), Effect.ENERGY_SOUND ,Color.WHITE, vect(131.1, 12, 26.1), 70, EffectReeval.VISIBILITY)

    ### sombra quest ###
    createEffect(getAllPlayers(), Effect.PICKUP_SOUND, Color.PURPLE, vect(165.7, 12, 36.2), 70, EffectReeval.VISIBILITY)
    createEffect(getAllPlayers(), Effect.GOOD_AURA, Color.PURPLE, vect(165.7, 12, 36.2),
        1.5 + 0.3*sin(3*getTotalTimeElapsed() % 6.283), EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createInWorldText(getAllPlayers(), "{} get quest ({})".format(heroIcon(Hero.SOMBRA), buttonString(Button.INTERACT)), vect(165.7, 12, 36.2), 3, Clip.SURFACES, WorldTextReeval.VISIBILITY_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)
    wait()

    ### time HUD + shop prompt ###
    hudSubtext(getAllPlayers(), "{}:{}:{}{} (game ends at 4:30:00)".format(floor(getTotalTimeElapsed()/3600) if getTotalTimeElapsed() > 3600 else "00", floor(getTotalTimeElapsed() / 60 % 60), 0 if getTotalTimeElapsed() % 60 < 10 else l"", floor(getTotalTimeElapsed() % 60)), HudPosition.LEFT, -1, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubheader(getAllPlayers(), "stand still while holding [{}] and [{}] to enter the shop\n".format(buttonString(Button.CROUCH), buttonString(Button.INTERACT)), HudPosition.LEFT, -0.9, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)

    ### player money/faction/level HUD ###
    hudText(localPlayer, heroIcon(localPlayer.getCurrentHero()), "level {} | faction: {}".format(localPlayer.level, factNames[localPlayer.faction]), "${}".format(localPlayer.money), HudPosition.LEFT, 0, Color.BLUE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    wait()

    ### bases ###
    for i_init in range(len(factSpawns)):
        createEffect(localPlayer, Effect.SPHERE,
            Color.BLUE if localPlayer.faction == evalOnce(i_init) else Color.TEAM_2,
            evalOnce(factSpawns[i_init]), 3, EffectReeval.VISIBILITY_AND_COLOR)
        createInWorldText(localPlayer,
            "your faction's base\nlook down & press [{}] to swap heroes".format(buttonString(Button.INTERACT)) if localPlayer.faction == evalOnce(i_init) else evalOnce("base of {}".format(factNames[i_init])),
            evalOnce(factSpawns[i_init] + Vector.UP), 2, Clip.SURFACES, WorldTextReeval.VISIBILITY_STRING_AND_COLOR, Color.WHITE, SpecVisibility.DEFAULT)
        wait()

    ### shop IWT ###
    # pos,scale,Clip,reeval,color,specvis
    createInWorldText(shoppers, "- shop -", ShopCamPos + 100 * (
        (1.7 - 0.200) * angleToDirection(horizontalAngleOfDirection(directionTowards(ShopCamPos, ShopLookPos)), verticalAngleOfDirection(directionTowards(ShopCamPos, ShopLookPos)) - 90) +
        3 * directionTowards(ShopCamPos, ShopLookPos)), 4, Clip.NONE, WorldTextReeval.VISIBILITY, Color.ROSE, SpecVisibility.DEFAULT)
    createInWorldText(shoppers, "buy some magic fish! (by making a purchase you agree to not hold us liable for any injury or damage caused by use of our products.)\n ".format(buttonString(Button.JUMP), buttonString(Button.PRIMARY_FIRE), buttonString(Button.SECONDARY_FIRE)), ShopCamPos + 100 * (
        (1.45 - 0.200) * angleToDirection(horizontalAngleOfDirection(directionTowards(ShopCamPos, ShopLookPos)), verticalAngleOfDirection(directionTowards(ShopCamPos, ShopLookPos)) - 90) +
        3 * directionTowards(ShopCamPos, ShopLookPos)), 1.5, Clip.NONE, WorldTextReeval.VISIBILITY_AND_STRING, Color.GRAY, SpecVisibility.DEFAULT)
    createInWorldText(shoppers, "horizontal movement to scroll\n ".format(buttonString(Button.JUMP), buttonString(Button.PRIMARY_FIRE), buttonString(Button.SECONDARY_FIRE)), ShopCamPos + 100 * (
        (1.25 - 0.200) * angleToDirection(horizontalAngleOfDirection(directionTowards(ShopCamPos, ShopLookPos)), verticalAngleOfDirection(directionTowards(ShopCamPos, ShopLookPos)) - 90) +
        3 * directionTowards(ShopCamPos, ShopLookPos)), 2, Clip.NONE, WorldTextReeval.VISIBILITY_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)
    createInWorldText(shoppers, "[{}/{}/{}] to buy 1/20/500 times\n ".format(buttonString(Button.JUMP), buttonString(Button.PRIMARY_FIRE), buttonString(Button.SECONDARY_FIRE)), ShopCamPos + 100 * (
        (1.1 - 0.200) * angleToDirection(horizontalAngleOfDirection(directionTowards(ShopCamPos, ShopLookPos)), verticalAngleOfDirection(directionTowards(ShopCamPos, ShopLookPos)) - 90) +
        3 * directionTowards(ShopCamPos, ShopLookPos)), 2, Clip.NONE, WorldTextReeval.VISIBILITY_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)
    wait()
    # shop item
    createInWorldText(shoppers, "◀ {} {} ({}) - ${} ▶".format(shopIcons[localPlayer.option],
        shopItems[localPlayer.option],
        abs(localPlayer.stats[localPlayer.option]),
        shopPrices[localPlayer.option]), ShopCamPos + 100 * (
        (-0.1 - 0.200) * angleToDirection(horizontalAngleOfDirection(directionTowards(ShopCamPos, ShopLookPos)), verticalAngleOfDirection(directionTowards(ShopCamPos, ShopLookPos)) - 90) +
        3 * directionTowards(ShopCamPos, ShopLookPos)), 5, Clip.NONE, WorldTextReeval.VISIBILITY_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)
    createInWorldText(shoppers, "({} / {})".format(
        localPlayer.option + 1, len(shopItems)), ShopCamPos + 100 * (
        (-0.65 - 0.200) * angleToDirection(horizontalAngleOfDirection(directionTowards(ShopCamPos, ShopLookPos)), verticalAngleOfDirection(directionTowards(ShopCamPos, ShopLookPos)) - 90) +
        3 * directionTowards(ShopCamPos, ShopLookPos)), 2, Clip.NONE, WorldTextReeval.VISIBILITY_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)
    wait()

    # more instructions
    createInWorldText(shoppers, "you have ${}".format(localPlayer.money), ShopCamPos + 100 * (
        (-0.85 - 0.200) * angleToDirection(horizontalAngleOfDirection(directionTowards(ShopCamPos, ShopLookPos)), verticalAngleOfDirection(directionTowards(ShopCamPos, ShopLookPos)) - 90) +
        3 * directionTowards(ShopCamPos, ShopLookPos)), 2, Clip.NONE, WorldTextReeval.VISIBILITY_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)
    createInWorldText(shoppers, "hold [{}] to refund this upgrade".format(buttonString(Button.ULTIMATE)), ShopCamPos + 100 * (
        (-1 - 0.200) * angleToDirection(horizontalAngleOfDirection(directionTowards(ShopCamPos, ShopLookPos)), verticalAngleOfDirection(directionTowards(ShopCamPos, ShopLookPos)) - 90) +
        3 * directionTowards(ShopCamPos, ShopLookPos)), 2, Clip.NONE, WorldTextReeval.VISIBILITY_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)
    createInWorldText(shoppers, "hold [{}] to leave shop".format(buttonString(Button.INTERACT)), ShopCamPos + 100 * (
        (-1.15 - 0.200) * angleToDirection(horizontalAngleOfDirection(directionTowards(ShopCamPos, ShopLookPos)), verticalAngleOfDirection(directionTowards(ShopCamPos, ShopLookPos)) - 90) +
        3 * directionTowards(ShopCamPos, ShopLookPos)), 2, Clip.NONE, WorldTextReeval.VISIBILITY_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)

rule "player init":
    @Event eachPlayer
    @Condition eventPlayer.hasSpawned()
    if eventPlayer == hostPlayer and "{}".format(eventPlayer) == "OMGIDIED":
        hudSubheader(eventPlayer, eventPlayer.getPosition(), HudPosition.RIGHT, 0, Color.GREEN, HudReeval.STRING)
        hudSubheader(eventPlayer, eventPlayer.getFacingDirection(), HudPosition.RIGHT, 0, Color.GREEN, HudReeval.STRING)
        eventPlayer.faction = 1
        eventPlayer.disableEnvironmentCollision(false)
    eventPlayer.disableGamemodeHud()
    shut()
    wait(3)
    resume()
    smallMessage(eventPlayer, "you joined {}.".format(factNames[eventPlayer.faction]))

### shop ###
rule "shop enter":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.INTERACT)
    @Condition eventPlayer.isHoldingButton(Button.CROUCH)
    @Condition eventPlayer.isAlive()
    @Condition eventPlayer.isStanding()
    @Condition eventPlayer.faction != -1
    wait(0.5)
    smallMessage(eventPlayer, "going to shop. 3...")
    wait(1, Wait.ABORT_WHEN_FALSE)
    smallMessage(eventPlayer, "going to shop. 2...")
    wait(1, Wait.ABORT_WHEN_FALSE)
    smallMessage(eventPlayer, "going to shop. 1...")
    wait(1, Wait.ABORT_WHEN_FALSE)
    eventPlayer.startCamera(ShopCamPos, ShopLookPos, 50)
    shut()
    playEffect(eventPlayer, DynamicEffect.GOOD_PICKUP_EFFECT, Color.WHITE, eventPlayer, 50)
    shoppers.append(eventPlayer)

rule "shop scroll":
    @Event eachPlayer
    @Condition eventPlayer in shoppers
    @Condition eventPlayer.getThrottle() != vect(0,0,0)
    do:
        # smallMessage(eventPlayer, eventPlayer.option)
        if eventPlayer.getThrottle().x > 0:
            if eventPlayer.option == 0:
                eventPlayer.option = len(shopItems) - 1
            else:
                eventPlayer.option--
        else:
            eventPlayer.option++
            eventPlayer.option %= len(shopItems)
        wait(0.3, Wait.ABORT_WHEN_FALSE)
    while RULE_CONDITION

rule "shop select":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.JUMP) or eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) or eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)
    @Condition eventPlayer in shoppers
    do:
        # message if can't buy 1
        if eventPlayer.money < shopPrices[eventPlayer.option]:
            playEffect(eventPlayer, DynamicEffect.DEBUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 50)
            smallMessage(eventPlayer, "you don't have enough money.")
            return

        if eventPlayer.stats[eventPlayer.option] > statCaps[eventPlayer.option]:
            playEffect(eventPlayer, DynamicEffect.DEBUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 50)
            smallMessage(eventPlayer, "this upgrade is maxed out.")
            return

        # cap at what players can afford & max
        eventPlayer.buyqty = min(
            min(1 if eventPlayer.isHoldingButton(Button.JUMP) else (
            20 if eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) else 500), # selected amt
            floor(eventPlayer.money / shopPrices[eventPlayer.option])), # affordable amt
            statCaps[eventPlayer.option] - eventPlayer.stats[eventPlayer.option]
        )

        # buy
        eventPlayer.money -= eventPlayer.buyqty * shopPrices[eventPlayer.option]
        eventPlayer.stats[eventPlayer.option] += eventPlayer.buyqty
        wait(0.080)

        if not eventPlayer.isHoldingButton(Button.CROUCH):
            return
        playEffect(eventPlayer, DynamicEffect.GOOD_PICKUP_EFFECT, Color.WHITE, eventPlayer, 50)
    while eventPlayer in shoppers and eventPlayer.isHoldingButton(Button.JUMP) or eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) or eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)

rule "shop refund":
    @Event eachPlayer
    @Condition eventPlayer in shoppers
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE)
    wait(0.4)
    smallMessage(eventPlayer, "hold {} to refund this upgrade...".format(buttonString(Button.ULTIMATE)))
    wait(1.6)

    if eventPlayer.faction == FACTIONS.GAIA and eventPlayer.option in [STATS.DEFENSE, STATS.DAMAGE]:
        eventPlayer.money += shopPrices[eventPlayer.option] * eventPlayer.stats[eventPlayer.option] - 75
        eventPlayer.stats[eventPlayer.option] = 75
    else:
        eventPlayer.money += shopPrices[eventPlayer.option] * abs(eventPlayer.stats[eventPlayer.option] - baseStats[eventPlayer.option])
        eventPlayer.stats[eventPlayer.option] = baseStats[eventPlayer.option]
    smallMessage(eventPlayer, "upgrade refunded.")

rule "leave shop":
    @Event eachPlayer
    @Condition eventPlayer in shoppers
    @Condition eventPlayer.isHoldingButton(Button.INTERACT)
    wait(0.75, Wait.ABORT_WHEN_FALSE)
    eventPlayer.clearStatusEffect(Status.PHASED_OUT)
    wait(0.032) # update stats
    # eventPlayer.setMoveSpeed(eventPlayer.stats[STATS.MOVESPEED])
    eventPlayer.setMaxHealth(eventPlayer.stats[STATS.HEALTH])
    eventPlayer.setDamageDealt(eventPlayer.stats[STATS.DAMAGE])
    eventPlayer.setDamageReceived(-eventPlayer.stats[STATS.DEFENSE])
    eventPlayer.setHealingReceived(eventPlayer.stats[STATS.HEALING])
    eventPlayer.setProjectileGravity(-0.25 * eventPlayer.stats[STATS.PROJECTILE] + 125)
    eventPlayer.setProjectileSpeed(eventPlayer.stats[STATS.PROJECTILE])
    wait(0.032)
    shoppers.remove(eventPlayer)
    eventPlayer.stopCamera()
    resume()

### game behaviors ###
rule "enter blood god":
    @Event eachPlayer
    @Condition eventPlayer.hasSpawned()
    @Condition eventPlayer.bloodDoT == null
    @Condition eventPlayer.getPosition().y <= 19
    @Condition distance(eventPlayer.getPosition() * vect(1,0,1), vect(131.1, 0, 26.1)) < BloodRadius
    eventPlayer.startDoT(null, 9999,  eventPlayer.getMaxHealth() * 0.1)
    eventPlayer.bloodDoT = getLastDoT()
    createBeam(getAllPlayers(), Beam.BAD, vect(131.1, 14.5, 26.1) + vect(0, 0.5*sin(2*getTotalTimeElapsed() % 6.283), 0),
        (updateEveryTick(eventPlayer.getPosition()) + eventPlayer.getEyePosition())/2, Color.RED, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    eventPlayer.bloodFx = getLastCreatedEntity()

    # give money
    chase(eventPlayer.money, 9999999999, rate=eventPlayer.getMaxHealth() * (0.39 if eventPlayer.faction == FACTIONS.BLOOD else 0.3), ChaseReeval.DESTINATION_AND_RATE)

rule "leave blood god":
    @Event eachPlayer
    @Condition eventPlayer.hasSpawned()
    @Condition eventPlayer.bloodDoT != null
    @Condition eventPlayer.getPosition().y >= 20 or eventPlayer.isDead() or distance(eventPlayer.getPosition() * vect(1,0,1), vect(131.1, 0, 26.1)) > BloodRadius
    stopDoT(eventPlayer.bloodDoT)
    stopChasingVariable(eventPlayer.money)
    destroyEffect(eventPlayer.bloodFx)

    eventPlayer.bloodDoT = null
    eventPlayer.bloodFx = null

rule "get sombra quest":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.INTERACT)
    @Condition distance(eventPlayer, QuestPos) <= 2
    # reject quest
    if eventPlayer.questData != []:
        if eventPlayer.faction == FACTIONS.SOMBRUH:
            smallMessage(eventPlayer, "{} pathetic. fine, i'll give you something more your size.".format(heroIcon(Hero.SOMBRA)))
            damage(eventPlayer, null, 20)
        else:
            smallMessage(eventPlayer, "{} ugh, fine. how about this one, then?".format(heroIcon(Hero.SOMBRA)))
        playEffect(eventPlayer, DynamicEffect.RING_EXPLOSION, Color.WHITE, eventPlayer, 50)
    else:
        playEffect(eventPlayer, DynamicEffect.RING_EXPLOSION, Color.WHITE, eventPlayer, 50)



rule "enter base":
    @Event eachPlayer
    @Condition distance(eventPlayer, factSpawns[eventPlayer.faction]) <= 3

rule "swap heroes":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.INTERACT)
    @Condition eventPlayer.getFacingDirection() == Vector.DOWN
    @Condition distance(eventPlayer, factSpawns[eventPlayer.faction]) <= 3
    wait()
    eventPlayer.setAllowedHeroes(getAllHeroes().exclude(eventPlayer.getCurrentHero()))
    wait()
    eventPlayer.resetHeroAvailability()

rule "kill handling":
    @Event playerDealtFinalBlow
    # money
    eventPlayer.money += victim.money * stealPortion * (2 if eventPlayer.faction == FACTIONS.RICH else 1)
    victim.money *= 1 - stealPortion * (1.5 if victim.faction == FACTIONS.RICH and victim.money > eventPlayer.money else 1)
    # enemy
    if not victim.faction in eventPlayer.enemies:
        eventPlayer.enemies.append(victim.faction)
### faction specific behaviors ###
rule "cult lifesteal & blood":
    @Event playerDealtDamage
    @Condition eventPlayer.faction == FACTIONS.BLOOD
    heal(eventPlayer, null, eventDamage * (0.1 if eventPlayer.bloodFx == null else 0.3))
    factPoints[FACTIONS.BLOOD] += eventDamage * 0.4

rule "gaia healing":
    @Event eachPlayer
    @Condition eventPlayer.faction == FACTIONS.GAIA
    @Condition eventPlayer.isCrouching()
    @Condition distance(eventPlayer, getClosestPlayer(eventPlayer, Team.ALL))
    smallMessage([x for x in getPlayersInRadius(eventPlayer, 3, Team.ALL, LosCheck.SURFACES) if x != eventPlayer], "{}{} is healing you. stay near them!".format(heroIcon(eventPlayer.getCurrentHero()), eventPlayer))
    while eventPlayer.isCrouching() and distance(eventPlayer, getClosestPlayer(eventPlayer, Team.ALL)):
        heal([x for x in getPlayersInRadius(eventPlayer, 3, Team.ALL, LosCheck.SURFACES) if x != eventPlayer], eventPlayer, 6)
        playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION, Color.LIME_GREEN, eventPlayer, 3)
        wait(0.1)

rule "gaia healing credit":
    @Event playerDealtHealing
    @Condition eventPlayer.faction == FACTIONS.GAIA
    @Condition healee != eventPlayer
    factPoints[FACTIONS.GAIA] += eventHealing * eventPlayer.stats[STATS.OBJECTIVE]

rule "clear enemy on death":
    @Event playerDealtDamage
    @Condition eventPlayer.faction == FACTIONS.GAIA
    @Condition eventPlayer.faction in victim.enemies
    damage(victim, eventPlayer, eventDamage * 0.5)
### misc ###
rule "player leave cleanup":
    @Event playerLeft
    shoppers.remove(eventPlayer)

rule "skip hero select phase, alter default gamemode conditions":
    @Event global
    @Condition not isGameInProgress()
    setMatchTime(4)
    wait(5)
    pauseMatchTime()
    disableGamemodeCompletion()
    disableScoring()
    disableAnnouncer()

/*2do
- icon list instead of page no in shop
- fix base names
- fix hero swap & do base healing, pacify & invuln
- random shop bg
- quests
- faction goals
- catchup'
- compensate for low faction membership in objectives
- gold mine near gaia spawn
- mine with more output/users ($ > blood only at low level) at payload end point?

faction select
- children of gaia (goal: heal)
- cult of the blood god (goal: feed blood)
- the 0.1%
- the singularity

 to encourage peace*/