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
            "respawnTime%": 50,
            "healthPackRespawnTime%": 450
        }
    },
    "heroes": {
        "allTeams": {
            "dva": {
                "spawnWithoutMech": true
            }
        }
    }
}

#!include "vars.opy"
#!include "balance.opy"

# update crypto text too bc it uses localplayer
#!define MoneyMult (factLevels[eventPlayer.faction] * 0.1 + 1)
#!define FactPointsMult (eventPlayer.stats[STATS.OBJECTIVE]/100)
#!define NumQuests [QUEST_TYPE.BLOOD, QUEST_TYPE.DAMAGE, QUEST_TYPE.CRYPTO]

### inits ###
def questComplete():
    stopChasingVariable(eventPlayer.questProgress)
	if eventPlayer.faction == FACTIONS.SOMBRUH:
		smallMessage(eventPlayer, "{} good. the plan is going well.".format(heroIcon(Hero.SOMBRA)))
		eventPlayer.setUltCharge(eventPlayer.getUltCharge() + 40)
        factPoints[eventPlayer.faction] += max(1700, eventPlayer.level/2)
	else:
		smallMessage(eventPlayer, "{} well done.".format(heroIcon(Hero.SOMBRA)))

    eventPlayer.money += (2000 + 2 * eventPlayer.level) * (2 if eventPlayer.faction == FACTIONS.SOMBRUH else 1) * MoneyMult

	eventPlayer.questType = -1
	eventPlayer.questProgress = -1
    eventPlayer.questGoal = 2
def shut():
    eventPlayer.cancelPrimaryAction()
    eventPlayer.disallowButton(Button.INTERACT)
    eventPlayer.disallowButton(Button.PRIMARY_FIRE)
    eventPlayer.disallowButton(Button.SECONDARY_FIRE)
    eventPlayer.disallowButton(Button.MELEE)
    eventPlayer.disallowButton(Button.JUMP)
    eventPlayer.disallowButton(Button.RELOAD)
    wait()
    if eventPlayer.getCurrentHero() == Hero.DVA and not eventPlayer.isInAlternateForm():
        eventPlayer.clearStatusEffect(Status.PHASED_OUT)
        damage(eventPlayer, null, eventPlayer.getMaxHealth() * 420)
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
    wait(0.3)
    eventPlayer.startScalingSize(1 - eventPlayer.stats[STATS.SHRINK]/100, false)
    if eventPlayer.getCurrentHero() == Hero.DVA and eventPlayer.isInAlternateForm():
        eventPlayer.setUltCharge(100)

rule "global init":
    stealPortion = createWorkshopSetting(float[0.05:0.5], "gameplay", "portion of money stolen on killing blows", 0.15)

    ### blood god ###
    createEffect(getAllPlayers(), Effect.ORB, Color.RED,
        vect(131.1, 14.5, 26.1) + vect(0, 0.5*sin(2*getTotalTimeElapsed() % 6.283), 0), 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getAllPlayers(), Effect.RING, Color.RED, vect(131.1, 11, 26.1), BloodRadius, EffectReeval.VISIBILITY)
    createInWorldText(getAllPlayers(), "blood god - sacrifice 10% max hp /s\nfor money (1 hp : $1)", vect(131.1, 15.3, 26.1), 1.5, Clip.SURFACES, WorldTextReeval.VISIBILITY, Color.WHITE, SpecVisibility.DEFAULT)
    createEffect(getAllPlayers(), Effect.ENERGY_SOUND ,Color.WHITE, vect(131.1, 12, 26.1), 25, EffectReeval.VISIBILITY)

    wait()
    ### sombra quest ###
    createEffect(getAllPlayers(), Effect.PICKUP_SOUND, Color.PURPLE, vect(165.7, 12, 36.2), 35, EffectReeval.VISIBILITY)
    createEffect(getAllPlayers(), Effect.GOOD_AURA, Color.PURPLE, vect(165.7, 12, 36.2),
        1.5 + 0.3*sin(3*getTotalTimeElapsed() % 6.283), EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createInWorldText(getAllPlayers(), "{} get quest ({})\ncooldown: 3s".format(heroIcon(Hero.SOMBRA), buttonString(Button.INTERACT)), vect(165.7, 12, 36.2), 1.5, Clip.SURFACES, WorldTextReeval.VISIBILITY_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)

    wait()
    ### gold mine ###
    createEffect(getAllPlayers(), Effect.RING, Color.YELLOW, GoldPos + Vector.UP, GoldRadius, EffectReeval.VISIBILITY)
    createEffect(getAllPlayers(), Effect.SPARKLES, Color.YELLOW, GoldPos, GoldRadius, EffectReeval.VISIBILITY)
    createEffect(getAllPlayers(), Effect.SPARKLES_SOUND, Color.YELLOW, GoldPos, 5*GoldRadius, EffectReeval.VISIBILITY)
    createInWorldText(getAllPlayers(), "beg from lumérico president (${}/s split among beggars)".format(BegMoney), GoldPos + 6*Vector.UP, 1.5, Clip.SURFACES, WorldTextReeval.VISIBILITY, Color.WHITE, SpecVisibility.DEFAULT)

    wait()
    ### crypto ###
    createEffect(getAllPlayers(), Effect.LIGHT_SHAFT, Color.VIOLET, CryptoPos + 12*Vector.DOWN, CryptoRadius, EffectReeval.VISIBILITY)
    createInWorldText(getAllPlayers(), "mine blizzcoin and ruin the environment for profit!\n${}/s + ${}/s per additional miner (join now for ${}/s)".format(CryptoBaseMoney, CryptoAddMoney, (CryptoBaseMoney + (minerCount + 0.5 if localPlayer.faction == FACTIONS.SOMBRUH else minerCount)*CryptoAddMoney) * (factLevels[localPlayer.faction] * 0.1 + 1)), CryptoPos + 7*Vector.UP, 1.5, Clip.SURFACES, WorldTextReeval.VISIBILITY_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)

    ### bank ###
    createEffect(getAllPlayers(), Effect.RING, Color.ORANGE, BankPos, 5.5, EffectReeval.VISIBILITY)
    createInWorldText(getAllPlayers(), "bank | ${} / {}\n{}".format(factPoints[FACTIONS.RICH], factLvUp[FACTIONS.RICH],
        "stand here to steal (15% / 5s)" if localPlayer.faction != FACTIONS.RICH else "buy {} {} to add money\nkeep other factions away".format(shopIcons[STATS.OBJECTIVE], shopItems[STATS.OBJECTIVE])), BankPos + 3*Vector.UP, 1.5, Clip.SURFACES, WorldTextReeval.VISIBILITY_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)

    wait()
    ### time HUD + shop prompt ###
    hudSubtext(getAllPlayers(), "{}:{}:{}{} (game ends at 4:30:00)".format(floor(getTotalTimeElapsed()/3600) if getTotalTimeElapsed() > 3600 else "00", floor(getTotalTimeElapsed() / 60 % 60), 0 if getTotalTimeElapsed() % 60 < 10 else l"", floor(getTotalTimeElapsed() % 60)), HudPosition.LEFT, -1, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubheader(getAllPlayers(), "stand still while holding [{}] and [{}] to enter the shop\n".format(buttonString(Button.CROUCH), buttonString(Button.INTERACT)), HudPosition.LEFT, -0.9, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)

    wait()
    ### player money/faction/level/quest HUD ###
    hudText(localPlayer, heroIcon(localPlayer.getCurrentHero()), "level {}".format(localPlayer.level), b"${} ".format(localPlayer.money), HudPosition.LEFT, 0, Color.BLUE, Color.BLUE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudText(localPlayer, abilityIconString(Hero.BRIGITTE, Button.ULTIMATE), "{} | {}% income bonus".format(factNames[localPlayer.faction], factLevels[localPlayer.faction]*10),
        "faction goal reached! return to your faction's base to level it up." if factPoints[localPlayer.faction] >= factLvUp[localPlayer.faction] else "faction points: {} / {}".format(factPoints[localPlayer.faction], factLvUp[localPlayer.faction]), HudPosition.LEFT, 0, Color.TURQUOISE, Color.TURQUOISE, Color.WHITE if factPoints[localPlayer.faction] < factLvUp[localPlayer.faction] else Color.ROSE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)

    wait()
    progressBarHud(localPlayer, 100 * localPlayer.questProgress / localPlayer.questGoal,
        "find sombra in lumérico for a quest" if localPlayer.questType == -1
        else " {}{}".format(questText[localPlayer.questType], b"{} / {} ".format(localPlayer.questProgress, localPlayer.questGoal) if localPlayer.questType in NumQuests else b"{} ".format(localPlayer.questGoal)), HudPosition.TOP, 1, Color.GRAY if localPlayer.questType == -1 else Color.YELLOW, Color.GRAY if localPlayer.questType == -1 else Color.ORANGE, ProgressHudReeval.VISIBILITY_VALUES_AND_COLOR, SpecVisibility.DEFAULT)
    # hudSubtext(localPlayer if localPlayer.questType != -1 else [], b"{} / {}".format(localPlayer.questProgress, localPlayer.questGoal) if localPlayer.questType in NumQuests else b" {} ".format(localPlayer.questGoal), HudPosition.TOP, 1.1, Color.GRAY if localPlayer.questType == -1 else Color.YELLOW, HudReeval.VISIBILITY_STRING_AND_COLOR)

    # event
    hudHeader(localPlayer if localPlayer.faction >= 0 else [], "{} ({}s)".format(eventText, round(eventTime)), HudPosition.TOP, 0, Color.LIME_GREEN if eventType != -1 else Color.GRAY, HudReeval.VISIBILITY_STRING_AND_COLOR, SpecVisibility.ALWAYS)

    ### factions ###
    for i_init in range(len(factSpawns)):
        # faction spawns
        createEffect(localPlayer, Effect.SPHERE,
            Color.BLUE if localPlayer.faction == evalOnce(i_init) else Color.TEAM_2,
            evalOnce(factSpawns[i_init]), 3, EffectReeval.VISIBILITY_AND_COLOR)
        createInWorldText(localPlayer if localPlayer.faction != -1 else [],
            "your faction's base\nhold crouch to swap heroes".format(buttonString(Button.INTERACT))
				if localPlayer.faction == evalOnce(i_init) else evalOnce("base of {}".format(evalOnce(factNames[i_init]))),
            evalOnce(factSpawns[i_init]), 1.5, Clip.SURFACES, WorldTextReeval.VISIBILITY_STRING_AND_COLOR, Color.WHITE, SpecVisibility.DEFAULT)

        wait()
    # faction intros
    createInWorldText(localPlayer if localPlayer.faction == -1 else [], "◀ {} ▶".format(factNames[localPlayer.option]), factCams[localPlayer.option] + 100 * (
        (1.3 - 0.200) * angleToDirection(horizontalAngleOfDirection(directionTowards(factCams[localPlayer.option], factSpawns[localPlayer.option])), verticalAngleOfDirection(directionTowards(factCams[localPlayer.option], factSpawns[localPlayer.option])) - 90) +
        3 * directionTowards(factCams[localPlayer.option], factSpawns[localPlayer.option])), 5, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.AQUA, SpecVisibility.DEFAULT)
    createInWorldText(localPlayer if localPlayer.faction == -1 else [], b"faction goal: {}".format(factGoalStrings[localPlayer.option]), factCams[localPlayer.option] + 100 * (
        (0.9 - 0.200) * angleToDirection(horizontalAngleOfDirection(directionTowards(factCams[localPlayer.option], factSpawns[localPlayer.option])), verticalAngleOfDirection(directionTowards(factCams[localPlayer.option], factSpawns[localPlayer.option])) - 90) +
        3 * directionTowards(factCams[localPlayer.option], factSpawns[localPlayer.option])), 3, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.SKY_BLUE, SpecVisibility.DEFAULT)
    createInWorldText(localPlayer if localPlayer.faction == -1 else [], factDescs[localPlayer.option], factCams[localPlayer.option] + 100 * (
        (-1.2 - 0.200) * angleToDirection(horizontalAngleOfDirection(directionTowards(factCams[localPlayer.option], factSpawns[localPlayer.option])), verticalAngleOfDirection(directionTowards(factCams[localPlayer.option], factSpawns[localPlayer.option])) - 90) +
        3 * directionTowards(factCams[localPlayer.option], factSpawns[localPlayer.option])), 2, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)
    # controls
    createInWorldText(localPlayer if localPlayer.faction == -1 else [], b"horizontal movement [a/d] to scroll | [{}] to select".format(buttonString(Button.JUMP)), factCams[localPlayer.option] + 100 * (
        (1.15 - 0.200) * angleToDirection(horizontalAngleOfDirection(directionTowards(factCams[localPlayer.option], factSpawns[localPlayer.option])), verticalAngleOfDirection(directionTowards(factCams[localPlayer.option], factSpawns[localPlayer.option])) - 90) +
        3 * directionTowards(factCams[localPlayer.option], factSpawns[localPlayer.option])), 2, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.BLUE, SpecVisibility.DEFAULT)

    ### shop IWT ###
    # pos,scale,Clip,reeval,color,specvis
    createInWorldText(shoppers, "\&diamond_in_diamond;  shop  \&diamond_in_diamond;", ShopCamPos + 100 * (
        (1.55 - 0.200) * angleToDirection(horizontalAngleOfDirection(directionTowards(ShopCamPos, ShopLookPos)), verticalAngleOfDirection(directionTowards(ShopCamPos, ShopLookPos)) - 90) +
        3 * directionTowards(ShopCamPos, ShopLookPos)), 4, Clip.NONE, WorldTextReeval.VISIBILITY_AND_COLOR,
		rgb(
            128 + 127 * cosDeg(getTotalTimeElapsed() * 100),
            128 + 127 * cosDeg((getTotalTimeElapsed() * 100) + 120),
            128 + 127 * cosDeg((getTotalTimeElapsed() * 100) + 240)
        ), SpecVisibility.DEFAULT)
    createInWorldText(shoppers, "buy some magic fish! (by making a purchase you agree to not hold us liable for any injury or damage caused by use of our products.)\n ", ShopCamPos + 100 * (
        (1.3 - 0.200) * angleToDirection(horizontalAngleOfDirection(directionTowards(ShopCamPos, ShopLookPos)), verticalAngleOfDirection(directionTowards(ShopCamPos, ShopLookPos)) - 90) +
        3 * directionTowards(ShopCamPos, ShopLookPos)), 1.5, Clip.NONE, WorldTextReeval.VISIBILITY_AND_STRING, Color.GRAY, SpecVisibility.DEFAULT)
    # createInWorldText(shoppers, "\n".format(buttonString(Button.JUMP), buttonString(Button.PRIMARY_FIRE), buttonString(Button.SECONDARY_FIRE)), ShopCamPos + 100 * (
    #     (0.95 - 0.200) * angleToDirection(horizontalAngleOfDirection(directionTowards(ShopCamPos, ShopLookPos)), verticalAngleOfDirection(directionTowards(ShopCamPos, ShopLookPos)) - 90) +
    #     3 * directionTowards(ShopCamPos, ShopLookPos)), 2, Clip.NONE, WorldTextReeval.VISIBILITY_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)
    createInWorldText(shoppers, "horizontal movement to scroll\n[{}/{}/{}] to buy 1/20/500 times\nhold [{}] while buying to buy repeatedly".format(buttonString(Button.JUMP), buttonString(Button.PRIMARY_FIRE), buttonString(Button.SECONDARY_FIRE), buttonString(Button.CROUCH)), ShopCamPos + 100 * (
        (1 - 0.200) * angleToDirection(horizontalAngleOfDirection(directionTowards(ShopCamPos, ShopLookPos)), verticalAngleOfDirection(directionTowards(ShopCamPos, ShopLookPos)) - 90) +
        3 * directionTowards(ShopCamPos, ShopLookPos)), 2, Clip.NONE, WorldTextReeval.VISIBILITY_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)
    wait()
	# icon row
    for i_init in range(ShopLen):
        createInWorldText(shoppers, shopIcons[i_init], ShopCamPos + 100 * (
            evalOnce(i_init - floor(ShopLen/2))* 0.3 * crossProduct(directionTowards(ShopCamPos, ShopLookPos), angleToDirection(horizontalAngleOfDirection(directionTowards(ShopCamPos, ShopLookPos)), verticalAngleOfDirection(directionTowards(ShopCamPos, ShopLookPos)) - 90)) +
            (0.65 - 0.200 + 0.02*sin(2*getTotalTimeElapsed() % 6.283)) * angleToDirection(horizontalAngleOfDirection(directionTowards(ShopCamPos, ShopLookPos)), verticalAngleOfDirection(directionTowards(ShopCamPos, ShopLookPos)) - 90) +
            3 * directionTowards(ShopCamPos, ShopLookPos)), 2.55, Clip.NONE, WorldTextReeval.VISIBILITY_AND_COLOR, rgb(245,252,245), SpecVisibility.DEFAULT)
        # if localPlayer.option == evalOnce(i_init) else Color.GRAY # color change works but not on ability icons
        wait()
    # arrow
	createInWorldText(shoppers, "\&up_black_triangle;", ShopCamPos + 100 * (
        (localPlayer.option - floor(ShopLen/2))* 0.3 * crossProduct(directionTowards(ShopCamPos, ShopLookPos), angleToDirection(horizontalAngleOfDirection(directionTowards(ShopCamPos, ShopLookPos)), verticalAngleOfDirection(directionTowards(ShopCamPos, ShopLookPos)) - 90)) +
        (0.45 - 0.200 + 0.05*sin(2*getTotalTimeElapsed() % 6.283)) * angleToDirection(horizontalAngleOfDirection(directionTowards(ShopCamPos, ShopLookPos)), verticalAngleOfDirection(directionTowards(ShopCamPos, ShopLookPos)) - 90) +
        3 * directionTowards(ShopCamPos, ShopLookPos)), 2.5, Clip.NONE, WorldTextReeval.VISIBILITY_AND_POSITION, Color.BLUE, SpecVisibility.DEFAULT)
    # shop item
    createInWorldText(shoppers, "◀ {} {} ({}%) - ${} ▶".format(shopIcons[localPlayer.option],
        shopItems[localPlayer.option],
        abs(localPlayer.stats[localPlayer.option]),
        shopPrices[localPlayer.option]), ShopCamPos + 100 * (
        (-0.1 - 0.200 + 0.02*sin(getTotalTimeElapsed() % 6.283)) * angleToDirection(horizontalAngleOfDirection(directionTowards(ShopCamPos, ShopLookPos)), verticalAngleOfDirection(directionTowards(ShopCamPos, ShopLookPos)) - 90) +
        3 * directionTowards(ShopCamPos, ShopLookPos)), 5, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)
    # createInWorldText(shoppers, "({} / {})".format(
    #     localPlayer.option + 1, ShopLen), ShopCamPos + 100 * (
    #     (-0.65 - 0.200) * angleToDirection(horizontalAngleOfDirection(directionTowards(ShopCamPos, ShopLookPos)), verticalAngleOfDirection(directionTowards(ShopCamPos, ShopLookPos)) - 90) +
    #     3 * directionTowards(ShopCamPos, ShopLookPos)), 2, Clip.NONE, WorldTextReeval.VISIBILITY_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)
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

    wait()
    ### server load ###
    hudText(getAllPlayers(), null,  "peak: {} | average: {}".format(getPeakServerLoad(), getAverageServerLoad()), "server load: {}".format(getServerLoad()), HudPosition.RIGHT, -1, Color.ORANGE, Color.GRAY, Color.GRAY, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)

    ### barrier text ###
    createInWorldText(getAllPlayers(), "you can pass through here", vect(138.9, 14, 28.2), 1.5, Clip.SURFACES,
        WorldTextReeval.VISIBILITY_AND_COLOR, rgba(255, 255, 255, (25-distance(localPlayer, vect(138.9, 14, 28.2))) * 12), SpecVisibility.DEFAULT)
    createInWorldText(getAllPlayers(), "you can pass\nthrough here", vect(140.58, 16.2, 47.33), 1.5, Clip.SURFACES,
        WorldTextReeval.VISIBILITY_AND_COLOR, rgba(255, 255, 255, (25-distance(localPlayer, vect(140.9, 15.5, 47.5))) * 12), SpecVisibility.DEFAULT)
    createInWorldText(getAllPlayers(), "you can pass\nthrough here", vect(158.85, 13, 5.75), 1.5, Clip.SURFACES,
        WorldTextReeval.VISIBILITY_AND_COLOR, rgba(255, 255, 255, (25-distance(localPlayer, vect(158.85, 13, 5.75))) * 12), SpecVisibility.DEFAULT)

    # tutorial?
    createInWorldText(getAllPlayers(), "view tutorial?\n[{}] - yes    [{}] - skip".format(buttonString(Button.PRIMARY_FIRE), buttonString(Button.SECONDARY_FIRE)), vect(-25.7, -0.3, 21.46), 2.3, Clip.SURFACES, WorldTextReeval.VISIBILITY_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)

    # troon
    for i_init in range(10):
        createBeam(getAllPlayers(), Beam.GOOD, vect(41.72, 41 - i_init*0.22, -26.06), vect(41.68, 41 - i_init*0.22, -28.89),
            Color.SKY_BLUE if abs(4.5-i_init) >= 3.5 else (
                Color.ROSE if abs(4.5-i_init) >= 1.5 else Color.WHITE
            ), EffectReeval.VISIBILITY)
        # createBeam(getAllPlayers(), Beam.GOOD, vect(41.72, 40.5, -26.06), vect(41.68, 40.5, -28.89), Color.ROSE, EffectReeval.VISIBILITY)
        # createBeam(getAllPlayers(), Beam.GOOD, vect(41.72, 40, -26.06), vect(41.68, 40, -28.89), Color.WHITE, EffectReeval.VISIBILITY)
        # createBeam(getAllPlayers(), Beam.GOOD, vect(41.72, 39.5, -26.06), vect(41.68, 39.5, -28.89), Color.ROSE, EffectReeval.VISIBILITY)
        # createBeam(getAllPlayers(), Beam.GOOD, vect(41.72, 39, -26.06), vect(41.68, 39, -28.89), Color.SKY_BLUE, EffectReeval.VISIBILITY)

rule "player init":
    @Event eachPlayer
    @Condition eventPlayer.hasSpawned()
    @Condition eventPlayer.faction == -1
    wait()
    if eventPlayer == hostPlayer and "{}".format(eventPlayer) == "OMGIDIED":
        hudSubheader(eventPlayer, eventPlayer.getPosition(), HudPosition.RIGHT, 0, Color.GREEN, HudReeval.STRING)
        hudSubheader(eventPlayer, eventPlayer.getFacingDirection(), HudPosition.RIGHT, 0, Color.GREEN, HudReeval.STRING)
    eventPlayer.disableGamemodeHud() # gamemode hud used for events
    eventPlayer.disableHeroHUD()
    createInWorldText([] if eventPlayer.getCurrentHero() == Hero.SOMBRA and eventPlayer.isUsingAbility1() else getAllPlayers().exclude(eventPlayer),
        "lv {} | ${}\n{}{}".format(eventPlayer.level, eventPlayer.money, factNames[eventPlayer.faction],
        "\n{} faction enemy".format(iconString(Icon.SKULL)) if localPlayer.faction in eventPlayer.enemies else ""),
        eventPlayer.getEyePosition() + 0.6*Vector.UP,
        1.2, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, rgba(240,240,240,150), SpecVisibility.ALWAYS)
    eventPlayer.hudId = getLastCreatedEntity()
    wait()
    if not eventPlayer.isDummy():
        shut()
        # tutorial
        eventPlayer.faction = -2
        eventPlayer.startCamera(vect(-24.8, -0.1, 20.2), vect(-634.6, -41.2, 811.7), 15)
        wait(0.080)
        waitUntil(eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) or eventPlayer.isHoldingButton(Button.SECONDARY_FIRE), 9999)
        if eventPlayer.isHoldingButton(Button.PRIMARY_FIRE):
            # show tuto
            for eventPlayer.option in range(len(tutoStrings)):
                eventPlayer.startCamera(tutoCams[eventPlayer.option], tutoLooks[eventPlayer.option], 15)
                wait(0.32)
                smallMessage(eventPlayer, tutoStrings[eventPlayer.option])
                wait(4)
            eventPlayer.startCamera(moonPos + Vector.UP * 6, moonPos, 15)
            wait(0.32)
            smallMessage(eventPlayer, "you can also battle for possession of the {} moon spirit.".format(iconString(Icon.MOON)))
            wait(2)
            smallMessage(eventPlayer, "it blesses you with money, ult charge and healing. money given is not increased by faction bonus, but scales with time.")
            wait(4.5)
            smallMessage(eventPlayer, "the spirit also moves occasionally, which removes your ownership.")
            wait(3)
            smallMessage(eventPlayer, "now it's time to pick a faction.")
            wait(2)
        # pick faction
        wait()
        eventPlayer.option = 0
        eventPlayer.faction = -1
        eventPlayer.startCamera(factCams[eventPlayer.option], factSpawns[eventPlayer.option], 20)
        waitUntil(eventPlayer.isHoldingButton(Button.JUMP), 9999)
        eventPlayer.faction = eventPlayer.option
        wait()
        eventPlayer.stopCamera()
        resume()

    if eventPlayer.faction == FACTIONS.GAIA:
        eventPlayer.stats[STATS.DAMAGE] = 75
        eventPlayer.stats[STATS.DEFENSE] = -75
        eventPlayer.setDamageDealt(75)
        eventPlayer.setDamageReceived(75)
    smallMessage(eventPlayer, "you joined {}.".format(factNames[eventPlayer.faction]))

    # eventPlayer.enableGamemodeHud()
    eventPlayer.enableHeroHud()
    # catchup
    eventPlayer.money = max(500, (getTotalTimeElapsed()-360) * 90)
    # event update
    switch eventType:
        case EVENTS.GRAVITY:
            eventPlayer.setGravity(eventDetail)
            break
        case EVENTS.HERO:
            eventPlayer.startForcingHero(eventDetail)
            break

### shop ###
rule "shop enter":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.INTERACT)
    @Condition eventPlayer.isHoldingButton(Button.CROUCH)
    @Condition eventPlayer.isAlive()
    @Condition eventPlayer.isStanding()
    @Condition eventPlayer.faction != -1
    wait(0.5)
    smallMessage(eventPlayer, b"going to shop. 3...")
    wait(1, Wait.ABORT_WHEN_FALSE)
    smallMessage(eventPlayer, b"2... ")
    wait(1, Wait.ABORT_WHEN_FALSE)
    smallMessage(eventPlayer, b"1... ")
    wait(1, Wait.ABORT_WHEN_FALSE)
    eventPlayer.disableGamemodeHud()
	playEffect(getAllPlayers(), DynamicEffect.GOOD_EXPLOSION, Color.PURPLE, eventPlayer, 1.5)
    eventPlayer.startCamera(ShopCamPos, ShopLookPos, 20)
    shut()
    wait() # reset ammo
    eventPlayer.setMaxAmmo(0, eventPlayer.getMaxAmmo(0)*100/eventPlayer.stats[STATS.AMMO])
    eventPlayer.setMaxAmmo(1, eventPlayer.getMaxAmmo(1)*100/eventPlayer.stats[STATS.AMMO])
    playEffect(eventPlayer, DynamicEffect.GOOD_PICKUP_EFFECT, Color.WHITE, eventPlayer, 50)
    shoppers.append(eventPlayer)

rule "shop/faction preview/tutorial scroll":
    @Event eachPlayer
    @Condition eventPlayer in shoppers or eventPlayer.faction == -1
    @Condition eventPlayer.getThrottle().x != 0
    do:
        # smallMessage(eventPlayer, eventPlayer.option)
        if eventPlayer.getThrottle().x > 0:
            if eventPlayer.option == 0:
                if eventPlayer.faction == -1:
                    eventPlayer.option = len(factNames) - 1
                else:
                    eventPlayer.option = ShopLen - 1
            else:
                eventPlayer.option--
        else:
            eventPlayer.option++
            if eventPlayer.faction == -1:
                eventPlayer.option %= len(factNames)
            else:
                eventPlayer.option %= ShopLen
        wait(0.2, Wait.ABORT_WHEN_FALSE)
    while RULE_CONDITION

rule "shop buy":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.JUMP) or eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) or eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)
    @Condition eventPlayer in shoppers
    do:
		# message if can't buy 1
        if eventPlayer.money < shopPrices[eventPlayer.option]:
            playEffect(eventPlayer, DynamicEffect.DEBUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 50)
            smallMessage(eventPlayer, "you don't have enough money.")
            return

        if eventPlayer.stats[eventPlayer.option] >= statCaps[eventPlayer.option]:
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
        eventPlayer.level += eventPlayer.buyqty
        playEffect(eventPlayer, DynamicEffect.BUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 70)
        playEffect(eventPlayer, DynamicEffect.GOOD_PICKUP_EFFECT, Color.ROSE, ShopLookPos, 5)

        wait(0.064)
        if not eventPlayer.isHoldingButton(Button.CROUCH):
            return
    while eventPlayer in shoppers and eventPlayer.isHoldingButton(Button.JUMP) or eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) or eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)

rule "shop refund":
    @Event eachPlayer
    @Condition eventPlayer in shoppers
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE)
    wait(1.2, Wait.ABORT_WHEN_FALSE)

    if eventPlayer.faction == FACTIONS.GAIA and eventPlayer.option in [STATS.DEFENSE, STATS.DAMAGE]:
        eventPlayer.money += shopPrices[eventPlayer.option] * eventPlayer.stats[eventPlayer.option] - 75
        eventPlayer.level -= eventPlayer.stats[eventPlayer.option] - 75
        eventPlayer.stats[eventPlayer.option] = 75
    else:
        eventPlayer.money += shopPrices[eventPlayer.option] * abs(eventPlayer.stats[eventPlayer.option] - baseStats[eventPlayer.option])
        eventPlayer.stats[eventPlayer.option] = baseStats[eventPlayer.option]
        eventPlayer.level -= abs(eventPlayer.stats[eventPlayer.option] - baseStats[eventPlayer.option])
    smallMessage(eventPlayer, "upgrade refunded.")

rule "shop leave":
    @Event eachPlayer
    @Condition eventPlayer in shoppers
    @Condition eventPlayer.isHoldingButton(Button.INTERACT)
    wait(1, Wait.ABORT_WHEN_FALSE)
    eventPlayer.stopScalingSize()
    eventPlayer.clearStatusEffect(Status.PHASED_OUT)
    wait(0.032) # update stats
    # eventPlayer.setMoveSpeed(eventPlayer.stats[STATS.MOVESPEED])
    eventPlayer.setMaxHealth(eventPlayer.stats[STATS.HEALTH])
    eventPlayer.setDamageDealt(eventPlayer.stats[STATS.DAMAGE])
    eventPlayer.setDamageReceived(-eventPlayer.stats[STATS.DEFENSE])
    eventPlayer.setHealingReceived(eventPlayer.stats[STATS.HEALING])
    eventPlayer.setProjectileGravity(-0.25 * eventPlayer.stats[STATS.PROJECTILE] + 125)
    eventPlayer.setProjectileSpeed(eventPlayer.stats[STATS.PROJECTILE])
    eventPlayer.setKnockbackDealt(eventPlayer.stats[STATS.KNOCK])
    wait()
    eventPlayer.startScalingSize(1 - (eventPlayer.stats[STATS.SHRINK] / 100), false)
    eventPlayer.setMaxAmmo(0, eventPlayer.getMaxAmmo(0)*eventPlayer.stats[STATS.AMMO]/100)
    eventPlayer.setMaxAmmo(1, eventPlayer.getMaxAmmo(1)*eventPlayer.stats[STATS.AMMO]/100)
    wait(0.032)
    eventPlayer.setScore(eventPlayer.level / 100)
    if eventPlayer.faction == FACTIONS.RICH: # bank
        factPoints[eventPlayer.faction] += shopPrices[STATS.OBJECTIVE] * (eventPlayer.stats[STATS.OBJECTIVE] - 100) / 4
        eventPlayer.stats[STATS.OBJECTIVE] = 0
    wait()
    shoppers.remove(eventPlayer)
    eventPlayer.stopCamera()
    # eventPlayer.enableGamemodeHud()
    resume()

### game behaviors ###
# blood god
rule "enter blood god":
    @Event eachPlayer
    @Condition eventPlayer.bloodDoT == null
    @Condition eventPlayer.hasSpawned()
    @Condition eventPlayer.isAlive()
    @Condition distance(eventPlayer.getPosition(), vect(131.1, 11, 26.1)) < BloodRadius
    eventPlayer.startDoT(null, 9999,  (eventPlayer.getMaxHealth() * 0.1) * 100 / -eventPlayer.stats[STATS.DEFENSE])
    eventPlayer.bloodDoT = getLastDoT()
    createBeam(getAllPlayers(), Beam.BAD, updateEveryTick(eventPlayer.getPosition() + eventPlayer.getEyePosition())/2,
        vect(131.1, 14.5, 26.1) + Vector.UP* 0.5*sin(2*getTotalTimeElapsed() % 6.283), Color.RED, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    eventPlayer.bloodFx = getLastCreatedEntity()

    # give money
    smallMessage(eventPlayer, b" ${}/s ".format(BloodFormula))
    chase(eventPlayer.money, 9999999999, rate=BloodFormula, ChaseReeval.DESTINATION_AND_RATE)
    if eventPlayer.questType == QUEST_TYPE.BLOOD:
        chase(eventPlayer.questProgress, 99999999999, rate=1, ChaseReeval.DESTINATION_AND_RATE)
    if eventPlayer.faction == FACTIONS.BLOOD:
        eventPlayer.buyqty = 0
        chase(eventPlayer.buyqty, 99999999999, rate=0.1*eventPlayer.getMaxHealth(), ChaseReeval.DESTINATION_AND_RATE)

rule "leave blood god":
    @Event eachPlayer
    # @Condition eventPlayer.hasSpawned()
    @Condition eventPlayer.bloodDoT != null
    @Condition (distance(eventPlayer, vect(131.1, 11, 26.1)) > BloodRadius) or (eventPlayer.isDead())
    wait()
    stopDoT(eventPlayer.bloodDoT)
    stopChasingVariable(eventPlayer.money)
    stopChasingVariable(eventPlayer.buyqty)
    destroyEffect(eventPlayer.bloodFx)

    eventPlayer.bloodDoT = null
    eventPlayer.bloodFx = null

    # buyqty is also used to track health given to blood god. sorry not sorry
    if eventPlayer.faction == FACTIONS.BLOOD:
        factPoints[eventPlayer.faction] += eventPlayer.buyqty * FactPointsMult
        eventPlayer.buyqty = 0
    if eventPlayer.questType == QUEST_TYPE.BLOOD:
        stopChasingVariable(eventPlayer.questProgress)

# crypto
rule "enter crypto mine":
    @Event eachPlayer
    @Condition eventPlayer.mineFx == null
    @Condition eventPlayer.isAlive()
    @Condition distance(eventPlayer, CryptoPos) <= CryptoRadius
    minerCount += 1.5 if eventPlayer.faction == FACTIONS.SOMBRUH else 1
    createBeam(getAllPlayers(), Beam.GOOD, updateEveryTick(eventPlayer.getPosition() + eventPlayer.getEyePosition())/2,
        vect(184.16, 27.5, 40.71), Color.BLUE, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    eventPlayer.mineFx = getLastCreatedEntity()
    chase(eventPlayer.money, 999999999, rate=MoneyMult * (CryptoBaseMoney + CryptoAddMoney * max(0, minerCount-1)), ChaseReeval.DESTINATION_AND_RATE)
    if eventPlayer.questType == QUEST_TYPE.CRYPTO:
        chase(eventPlayer.questProgress, eventPlayer.questGoal, rate=MoneyMult * (CryptoBaseMoney + CryptoAddMoney * max(0, minerCount-1)), ChaseReeval.DESTINATION_AND_RATE)

rule "leave crypto mine":
    @Event eachPlayer
    @Condition eventPlayer.mineFx != null
    @Condition eventPlayer.isDead() or distance(eventPlayer, CryptoPos) > CryptoRadius
    minerCount -= 1.5 if eventPlayer.faction == FACTIONS.SOMBRUH else 1
    destroyEffect(eventPlayer.mineFx)
    eventPlayer.mineFx = null
    stopChasingVariable(eventPlayer.money)
    if eventPlayer.questType == QUEST_TYPE.CRYPTO:
        stopChasingVariable(eventPlayer.questProgress)

# beg
rule "beg":
    @Event eachPlayer
    @Condition eventPlayer.hasSpawned()
    @Condition eventPlayer.isAlive()
    @Condition distance(GoldPos, eventPlayer.getPosition()) <= GoldRadius
    do:
        eventPlayer.money += MoneyMult * BegMoney / len(getPlayersInRadius(GoldPos, GoldRadius, Team.ALL, LosCheck.OFF))
        playEffect(eventPlayer, DynamicEffect.RING_EXPLOSION, Color.YELLOW, eventPlayer.getPosition() + Vector.UP, 2)
        playEffect(eventPlayer, DynamicEffect.BUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 10)
        wait(1)
    while RULE_CONDITION

# moon spirit
rule "moon init & repos":
    @Condition isGameInProgress()
    # init
    createEffect(getAllPlayers(), Effect.CLOUD, Color.VIOLET, moonPos, 3, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getAllPlayers(), Effect.RING, Color.ROSE, moonPos, 3, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createIcon(getAllPlayers(), moonPos + Vector.UP * (3 + 0.3*sin(getTotalTimeElapsed())),
        Icon.MOON, IconReeval.VISIBILITY_POSITION_AND_COLOR, rgb(127 + 30*sin(getTotalTimeElapsed()), 0, 255), false)
    # createInWorldText(getAllPlayers(), "")
    # loop
    while true:
        moonOwner = null
        playEffect(localPlayer, DynamicEffect.EXPLOSION_SOUND, Color.WHITE, localPlayer, 69)
        moonPos = random.choice(moonPosArr.exclude(moonPos))
        smallMessage(localPlayer if localPlayer.faction >= 0 else [], "{} the moon spirit has moved. claim it to gain its power.".format(iconString(Icon.MOON)))
        wait(random.randint(90, 210))

rule "moon claim":
    @Event eachPlayer
    @Condition eventPlayer != moonOwner
    @Condition distance(eventPlayer, moonPos) < 3
    @Condition len(getPlayersInRadius(moonPos, 3, Team.ALL, LosCheck.SURFACES)) == 1
    wait(0.32, Wait.ABORT_WHEN_FALSE)
    smallMessage(eventPlayer, "claiming moon spirit...".format(iconString(Icon.MOON)))
    wait(1.5, Wait.ABORT_WHEN_FALSE)
    playEffect(getAllPlayers(), DynamicEffect.GOOD_EXPLOSION, Color.VIOLET, moonPos + Vector.UP, 3)
    playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION_SOUND, Color.VIOLET, moonPos + Vector.UP, 40)
    smallMessage(moonOwner, "{} someone more worthy has claimed me.".format(iconString(Icon.MOON)))
    moonOwner = eventPlayer
    smallMessage(eventPlayer, "{} at your service.".format(iconString(Icon.MOON)))

rule "moon reward":
    @Condition isGameInProgress()
    @Condition moonOwner != null
    do:
        moonOwner.setUltCharge(1 + moonOwner.getUltCharge())
        heal(moonOwner, null, 5)
        moonOwner.money += min(getTotalTimeElapsed(), 6000)
        wait(0.5)
    while RULE_CONDITION

# quests
rule "get sombra quest":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.INTERACT)
    @Condition distance(eventPlayer, QuestPos) <= 2

    stopChasingVariable(eventPlayer.questProgress) # stop chasing blood crystal time (failsafe)
    # reject quest
    if eventPlayer.questType != -1:
        if eventPlayer.faction == FACTIONS.SOMBRUH:
            smallMessage(eventPlayer, "{} pathetic. fine, i'll give you something more your size.".format(heroIcon(Hero.SOMBRA)))
            damage(eventPlayer, null, 20)
        else:
            smallMessage(eventPlayer, "{} ugh, fine. how about this one, then?".format(heroIcon(Hero.SOMBRA)))
        playEffect(eventPlayer, DynamicEffect.RING_EXPLOSION, Color.WHITE, eventPlayer, 50)
        eventPlayer.questType = -1
        wait(0.2)
    else:
        smallMessage(eventPlayer, "{} {}".format(heroIcon(Hero.SOMBRA), random.choice(sombraQuips[eventPlayer.questType])))

    playEffect(eventPlayer, DynamicEffect.RING_EXPLOSION, Color.WHITE, eventPlayer, 50)
    eventPlayer.questType = random.randint(0, QUEST_TYPE.DAMAGE)
    switch eventPlayer.questType:
        case QUEST_TYPE.HITMAN:
            if getNumberOfPlayers(Team.ALL) > 1:
                eventPlayer.questGoal = random.choice([x for x in getAllPlayers() if x != eventPlayer])
            else:
                smallMessage(eventPlayer, "{} i was gonna tell you to kill someone for fun but uh... nobody else is here. shame.".format(heroIcon(Hero.SOMBRA)))
                eventPlayer.questType = -1
                return
            break
        case QUEST_TYPE.VISIT:
            eventPlayer.questProgress = random.randint(0, FACTIONS.SOMBRUH)
            eventPlayer.questGoal = factNames[eventPlayer.questProgress]
            break
        case QUEST_TYPE.BLOOD:
            eventPlayer.questGoal = random.uniform(1, 1.3) * min(eventPlayer.level/50 + 5, 15)
            eventPlayer.questProgress = 0
            break
        case QUEST_TYPE.CRYPTO:
            eventPlayer.questGoal = max(eventPlayer.level/2, 400) * random.uniform(0.8, 1.3)
            eventPlayer.questProgress = 0
            break
        case QUEST_TYPE.DAMAGE:
            eventPlayer.questGoal = random.randint(150, 270) + eventPlayer.level / 10
            eventPlayer.questProgress = 0
            break

    wait(3, Wait.IGNORE_CONDITION)

rule "numerical quest goal reached":
    @Event eachPlayer
    @Condition eventPlayer.questType in NumQuests
    @Condition eventPlayer.questProgress >= eventPlayer.questGoal
    wait(0.3, Wait.ABORT_WHEN_FALSE)
    stopChasingVariable(eventPlayer.questProgress)
    questComplete()

rule "visit quest done":
    @Event eachPlayer
    @Condition eventPlayer.questType == QUEST_TYPE.VISIT
    @Condition distance(eventPlayer, factSpawns[eventPlayer.questProgress]) <= 3
    questComplete()

rule "damage quest":
    @Event playerDealtDamage
    @Condition eventPlayer.questType == QUEST_TYPE.DAMAGE
    @Condition victim != eventPlayer
    eventPlayer.questProgress += eventDamage

# bases
rule "enter base & update faction level":
    @Event eachPlayer
    @Condition distance(eventPlayer, factSpawns[eventPlayer.faction]) <= 3
    smallMessage(eventPlayer, "entered your faction's base. you're invulnerable here but can't do damage.")
    # heal, phase, pacify
    heal(eventPlayer, null, eventPlayer.getMaxHealth())
    eventPlayer.setStatusEffect(null, Status.PHASED_OUT, 9999)
    eventPlayer.setStatusEffect(null, Status.UNKILLABLE, 9999)
    eventPlayer.setDamageDealt(0)
    # update faction level (points to next level = 50x^2 + 500x + 5000)
    while factPoints[eventPlayer.faction] > factLvUp[eventPlayer.faction]:
        playEffect(getAllPlayers(), DynamicEffect.GOOD_EXPLOSION, Color.SKY_BLUE, eventPlayer.getPosition(), 1)
        playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION_SOUND, Color.SKY_BLUE, eventPlayer.getPosition(), 90)
        factPoints[eventPlayer.faction] -= factLvUp[eventPlayer.faction]
        factLevels[eventPlayer.faction] += 1
        factLvUp[eventPlayer.faction] = 45 * factLevels[eventPlayer.faction]**2 + 650*factLevels[eventPlayer.faction] + 6000
        wait(0.08)

rule "leave base":
    @Event eachPlayer
    @Condition eventPlayer.faction != -1
    @Condition eventPlayer.hasStatusEffect(Status.PHASED_OUT)
    @Condition not eventPlayer in shoppers
    @Condition distance(eventPlayer, factSpawns[eventPlayer.faction]) >= 3
    wait(0.3, Wait.ABORT_WHEN_FALSE)
    eventPlayer.clearStatusEffect(Status.PHASED_OUT)
    eventPlayer.clearStatusEffect(Status.UNKILLABLE)
    eventPlayer.setDamageDealt(eventPlayer.stats[STATS.DAMAGE])

rule "swap heroes":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.CROUCH)
    @Condition eventPlayer.hasStatusEffect(Status.PHASED_OUT)
    @Condition distance(eventPlayer, factSpawns[eventPlayer.faction]) <= 3
    # smallMessage(eventPlayer, "hold crouch to swap heroes...")
    wait(0.5, Wait.ABORT_WHEN_FALSE)
    wait()
    eventPlayer.setAllowedHeroes(getAllHeroes().exclude(eventPlayer.getCurrentHero()))
    wait()
    eventPlayer.resetHeroAvailability()

# bank
rule "rob":
	@Event eachPlayer
	@Condition eventPlayer.faction != FACTIONS.RICH
	@Condition distance(eventPlayer, BankPos) < 5.5
	@Condition factPoints[FACTIONS.RICH] > 0
    wait(0.16, Wait.ABORT_WHEN_FALSE)
	smallMessage(eventPlayer, "robbing the bank. careful, the bourgeoisie have been alerted!")
	bigMessage([x for x in getAllPlayers() if x.faction == FACTIONS.RICH], "{} the bank is being robbed. defend it!".format(iconString(Icon.WARNING)))
	wait(2)
	while (distance(eventPlayer, BankPos) < 5.5) and (factPoints[FACTIONS.RICH] > 0):
		wait(3)
			eventPlayer.money += 0.15 * factPoints[FACTIONS.RICH]
			factPoints[FACTIONS.RICH] *= 0.85
		playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION, Color.RED, BankPos + Vector.UP, 4)

# shop upgrades
rule "flight":
	@Event eachPlayer
	@Condition eventPlayer.stats[STATS.FLIGHT]
	@Condition eventPlayer.isHoldingButton(Button.JUMP)
	@Condition eventPlayer.isAlive()
	do:
		eventPlayer.applyImpulse(Vector.UP, 2, Relativity.TO_WORLD, Impulse.INCORPORATE_CONTRARY_MOTION)
		wait(0.064)
	while RULE_CONDITION

rule "rapid fire":
	@Event eachPlayer
	@Condition eventPlayer.isAlive()
	@Condition eventPlayer.stats[STATS.DAKKA]
	do:
		eventPlayer.setProjectileSpeed(eventPlayer.stats[STATS.PROJECTILE])
		wait(0.16)
	while RULE_CONDITION

rule "min ult":
    @Event eachPlayer
    @Condition eventPlayer.isAlive()
    # @Condition eventPlayer.hasSpawned()
    @Condition eventPlayer.getUltCharge() < eventPlayer.stats[STATS.ULT]
    do:
        eventPlayer.setUltCharge(eventPlayer.stats[STATS.ULT])
        wait(1)
    while RULE_CONDITION

# events
rule "gen events":
    @Condition isGameInProgress()
    # @Condition getMatchTime() < 0.2
    eventType = -1
    eventText = "next event coming soon"
    wait(1.6)
    eventTime = 120
    wait(eventTime)
    chase(eventTime, -5, rate=1, ChaseReeval.DESTINATION_AND_RATE)
    # bigMessage(getAllPlayers(), getMatchTime())
    while true:
        if eventType == -1:
            eventType = random.randint(0, EVENTS.HERO)
            switch eventType: # events with side effects are updated in player init
                case EVENTS.BLOOD:
                    eventDetail = random.randint(3, 7)
                    eventText = "{} event: blood god grants {}x money!".format(iconString(Icon.POISON), eventDetail)
                    bigMessage(getAllPlayers(), eventText)
                    break
                case EVENTS.KILL:
                    eventDetail = random.randint(3, 5) / 2
                    eventText = "event: {} kills grant {}x money!".format(iconString(Icon.SKULL), eventDetail)
                    break
                case EVENTS.GRAVITY:
                    eventDetail = random.randint(20, 60)
                    eventText = "event: {} gravity is {}%".format(abilityIconString(Hero.ECHO, Button.JUMP), eventDetail)
                    getAllPlayers().setGravity(eventDetail) # also used in player init
                    break
                case EVENTS.HERO:
                    eventDetail = random.choice(getAllHeroes())
                    eventText = "event: {} hero swap".format(heroIcon(eventDetail))
                    getAllPlayers().startForcingHero(eventDetail)
                    break
            bigMessage(getAllPlayers(), eventText)
            eventTime = random.randint(20, 35)
            wait()
            wait(eventTime)
        else:
            eventType = -1
            eventText = "next event coming soon"
            getAllPlayers().setGravity(100)
            getAllPlayers().stopForcingCurrentHero()
            bigMessage(getAllPlayers(), "event ended.")
            eventTime = random.randint(240, 360)
            # setMatchTime(30)
            wait()
            wait(eventTime)
            # bigMessage(getAllPlayers(), getMatchTime())
# misc
rule "kill handling":
    @Event playerDealtFinalBlow
	# rich money bonus
	if eventPlayer.faction == FACTIONS.RICH:
		eventPlayer.money *= 1.1
    # money
    eventPlayer.money += (max(350, MoneyMult*2*victim.level) + victim.money * stealPortion * (2 if eventPlayer.faction == FACTIONS.RICH and victim.money > eventPlayer.money else 1)) * (eventDetail if eventType == EVENTS.KILL else 1)
    victim.money *= 1 - stealPortion * (1.5 if victim.faction == FACTIONS.RICH and victim.money > eventPlayer.money else 1)

    # quest
    if eventPlayer.questGoal == victim and eventPlayer.questType == QUEST_TYPE.HITMAN:
        questComplete()

    ### enemy ###
    # killed enemy
    if eventPlayer.faction in victim.enemies:
        smallMessage(eventPlayer, "killed a faction enemy. +${}, {} faction points".format(MoneyMult * victim.level * 3, FactPointsMult * victim.level))
        smallMessage(victim, "you are no longer wanted by {}.".format(factNames[eventPlayer.faction]))
        victim.enemies.remove(eventPlayer.faction)
        eventPlayer.money += MoneyMult * victim.level * 3
    # killed innocent
    else:
        if not victim.faction in eventPlayer.enemies:
            smallMessage(eventPlayer, "{} you are now wanted by {}.".format(iconString(Icon.SKULL), factNames[victim.faction]))
            eventPlayer.enemies.append(victim.faction)

rule "respawn":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()
    @Condition eventPlayer.hasSpawned()
    @Condition eventPlayer.isAlive()
    @Condition eventPlayer.faction != -1
    # @Condition eventPlayer.isInAlternateForm()
    # @Condition eventPlayer.isOnGround() # cheesy detect spawned vs demeched
    eventPlayer.teleport(factSpawns[eventPlayer.faction])

    if eventPlayer.getCurrentHero() == Hero.DVA and eventPlayer.isInAlternateForm():
        eventPlayer.setUltCharge(100)

### faction specific behaviors ###
rule "cult lifesteal & blood":
    @Event playerDealtDamage
    @Condition eventPlayer.faction == FACTIONS.BLOOD
    heal(eventPlayer, null, eventDamage * (0.1 if eventPlayer.bloodFx == null else 0.3))
    factPoints[FACTIONS.BLOOD] += eventDamage * 0.5 * FactPointsMult

rule "gaia healing":
    @Event eachPlayer
    @Condition eventPlayer.faction == FACTIONS.GAIA
    @Condition eventPlayer.isAlive()
    @Condition eventPlayer.isHoldingButton(Button.CROUCH)
    wait(0.5, Wait.ABORT_WHEN_FALSE)
    # @Condition distance(eventPlayer, getClosestPlayer(eventPlayer, Team.ALL)) <= 3
    smallMessage(getPlayersInRadius(eventPlayer, 3, Team.ALL, LosCheck.SURFACES).exclude(eventPlayer), "{}{} is healing you. stay near them!".format(heroIcon(eventPlayer.getCurrentHero()), eventPlayer))
    while eventPlayer.isCrouching() and eventPlayer.isAlive():
        heal(getPlayersInRadius(eventPlayer, 3, Team.ALL, LosCheck.SURFACES).exclude(eventPlayer), eventPlayer, 6)
        heal(eventPlayer, eventPlayer, 2)
        playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION, Color.LIME_GREEN, eventPlayer.getPosition(), 3)
        wait(0.1)

rule "gaia healing credit":
    @Event playerDealtHealing
    @Condition eventPlayer.faction == FACTIONS.GAIA
    @Condition healee != eventPlayer
    @Condition eventHealing > 0
    factPoints[eventPlayer.faction] += eventHealing * FactPointsMult * (0.5 if healee.faction == FACTIONS.GAIA else 1)
    eventPlayer.money += 10 * (1 + 0.2 * factLevels[eventPlayer.faction]) * (0.5 if healee.faction == FACTIONS.GAIA else 1)

rule "gaia revenge":
    @Event playerDealtDamage
    @Condition eventPlayer.faction == FACTIONS.GAIA
    @Condition eventAbility != null
    @Condition eventPlayer.faction in victim.enemies or victim.mineFx != null
    victim.setStatusEffect(eventPlayer, Status.BURNING, 0.25)
    damage(victim, eventPlayer, eventDamage * 0.75)

rule "crypto melee":
    @Event playerDealtDamage
    @Condition eventPlayer.faction == FACTIONS.SOMBRUH
    @Condition eventAbility == Button.MELEE
    # @Condition eventPlayer != victim
    victim.setStatusEffect(eventPlayer, Status.HACKED, 1.5)
### misc ###
rule "heal when stat > 10000":
    @Event playerReceivedHealing
    @Condition eventPlayer.stats[STATS.HEALING] > 1000
    # heal(eventPlayer, healer, eventHealing * (10000 - eventPlayer.stats[STATS.HEALING]) / eventPlayer.stats[STATS.HEALING])
    heal(eventPlayer, null, eventHealing * (eventPlayer.stats[STATS.HEALING] - 1000)/1000 )
    # null to avoid looping
rule "big door to lumerico barrier":
    @Event eachPlayer
    @Condition distance(eventPlayer.getPosition() * vect(1,0,1), vect(138.9, 0, 28.2)) <= 3.2
    @Condition eventPlayer.getPosition().y <= 15.5
    # bigMessage(eventPlayer, "debug phase")
    eventPlayer.disableEnvironmentCollision(false)
    waitUntil(distance(eventPlayer.getPosition() * vect(1,0,1), vect(138.9, 0, 28.2)) > 3.2 or eventPlayer.getPosition().y > 15.5, 9999)
    eventPlayer.enableEnvironmentCollision()

rule "small door to lumerico barrier":
    @Event eachPlayer
    @Condition distance(eventPlayer.getPosition() * vect(1,0,1), vect(140.9, 0, 47.5)) <= 1.15
    @Condition eventPlayer.getPosition().y <= 15
    eventPlayer.disableEnvironmentCollision(false)
    waitUntil(distance(eventPlayer.getPosition() * vect(1,0,1), vect(140.9, 0, 47.5)) > 1.15 or eventPlayer.getPosition().y > 15, 9999)
    eventPlayer.enableEnvironmentCollision()

rule "small door from bank barrier":
    @Event eachPlayer
    @Condition distance(eventPlayer.getPosition() * vect(1,0,1), vect(159.57, 0, 5.97)) <= 1.3
    @Condition eventPlayer.getPosition().y <= 12
    eventPlayer.disableEnvironmentCollision(false)
    waitUntil(distance(eventPlayer.getPosition() * vect(1,0,1), vect(159.57, 0, 5.97)) > 1.3 or eventPlayer.getPosition().y > 12, 9999)
    eventPlayer.enableEnvironmentCollision()

rule "player leave cleanup":
    @Event playerLeft
    shoppers.remove(eventPlayer)
	destroyEffect(eventPlayer.bloodFx)
	stopDoT(eventPlayer.bloodDoT)
    destroyInWorldText(eventPlayer.hudId)
    if eventPlayer.mineFx != null:
        destroyEffect(eventPlayer.mineFx)
        minerCount -= 1.5 if eventPlayer.faction == FACTIONS.SOMBRUH else 1
    # would add quest refresh for people with them as their mark but sounds expensive

rule "skip hero select phase, alter default gamemode conditions":
    @Event global
    @Condition not isGameInProgress()
    setMatchTime(4)
    wait(5)
    disableGamemodeCompletion()
    disableScoring()
    disableAnnouncer()

rule "no entering spawn":
    @Event eachPlayer
    @Condition eventPlayer.isInSpawnRoom()
    kill(eventPlayer, null)
    smallMessage(eventPlayer, "{} you can't enter spawn.".format(iconString(Icon.NO)))
rule "voice cracks (taken from YJ9W2 by zomg)":
    @Event eachPlayer
    while true:
        wait(random.uniform(12, 30))
        eventPlayer.startModifyingVoicelinePitch(1.3, false)
        wait(0.3)
        eventPlayer.stopModifyingVoicelinePitch()

rule "miners oopsie":
    @Condition minerCount < 0
    wait()
    playEffect([x for x in getAllPlayers() if x.mineFx != null], DynamicEffect.RING_EXPLOSION_SOUND, Color.WHITE, CryptoPos, 90)
    wait()
    minerCount = len([x for x in getPlayersInRadius(CryptoPos, CryptoRadius, Team.ALL, LosCheck.OFF) if x.mineFx != null])
    wait()
    smallMessage(getAllPlayers(), "{} crypto mine bugged out. if you're mining, reenter it to get the right amount of money.".format(iconString(Icon.WARNING)))

rule "anti crash":
    @Condition not antiCrashActivated
    @Condition getServerLoad() > 230
    wait(1, Wait.ABORT_WHEN_FALSE)
    smallMessage(getAllPlayers(), "{} Anti crash system activated".format(abilityIconString(Hero.TORBJORN, Button.ABILITY_2)))
    setSlowMotion(10)
    antiCrashActivated = true

rule "disable anti crash":
    @Condition antiCrashActivated
    @Condition getServerLoad() < 200
    setSlowMotion(100)
    antiCrashActivated = false

rule "debug bot spawn":
    @Condition "{}".format(hostPlayer) == "OMGIDIED"
    @Condition hostPlayer.isHoldingButton(Button.MELEE) and hostPlayer.isHoldingButton(Button.INTERACT)
    createDummy(random.choice(getAllHeroes()), Team.ALL, -1, hostPlayer, Vector.UP)
    wait(0.080)
    getLastCreatedEntity().clearStatusEffect(Status.PHASED_OUT)
    getLastCreatedEntity().faction = random.randint(0, FACTIONS.SOMBRUH)
    getLastCreatedEntity().startForcingButton(Button.CROUCH)
    getLastCreatedEntity().startForcingButton(Button.PRIMARY_FIRE)

/*2do
- fix tutorial cams
- balance rapid fire (change to max duration, activate on interact?)
- fix display for boolean shop items
- reverse hero swap event
- more events (punching bag if slot available? faction point bonus? wallhax? chasseur de prime?)
- bank & robbing
- test small lumerico barrier glitch
- offensive effects (hack at hp threshold, caut?)
- test phase near bank mega health pack barrier
- earning $/s hud
- balance catchup
- compensate for low faction membership in objectives

faction select
- children of gaia (goal: heal)
- cult of the blood god (goal: feed blood)
- the 0.1%
- the singularity

 to encourage peace*/