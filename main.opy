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
#!define ImportCode "pending"

### inits ###
def bossEventCleanup():
    # reverts boss effects. uses eventDetail as boss, not eventPlayer. does not reassign boss.
    removeHealthPool(eventDetail.eventVar)
    eventDetail.stopForcingOutlineFor(getAllPlayers())
    eventDetail.eventVar = null

def bossEventSetup():
    # sets up health pools for the player & updates hud. does not clean old boss' health pool or award money.
    eventDetail.addHealthPool(Health.ARMOR, eventDetail.getMaxHealth() * 0.5, true, false)
    eventDetail.eventVar = getLastCreatedHealthPool()
    heal(eventDetail, null, 250)
    eventDetail.startForcingOutlineFor(getAllPlayers(), true, Color.ROSE, OutlineVisibility.OCCLUDED)
    bigMessage(getAllPlayers(), "event: {}{} is now the boss!".format(heroIcon(eventDetail.getCurrentHero()), eventDetail))
    eventText = "event: boss ({}{}) - kill them to get money & become the next boss!".format(heroIcon(eventDetail.getCurrentHero()), eventDetail)

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

def resume():
    eventPlayer.setMoveSpeed(eventPlayer.stats[STATS.MOVESPEED] + eventPlayer.marketStats[MARKET.MOVESPEED])
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
    eventPlayer.respawn()
    wait(0.3)
    if eventPlayer.getCurrentHero() == Hero.DVA and eventPlayer.isInAlternateForm():
        eventPlayer.setUltCharge(100)

rule "global init":
    stealPortion = createWorkshopSetting(float[0.05:0.5], "gameplay", "portion of money stolen on killing blows", 0.15)

    ### blood god ###
    createEffect(getAllPlayers(), Effect.ORB, Color.RED,
        vect(131.1, 14.5, 26.1) + vect(0, 0.5*sin(2*getTotalTimeElapsed()), 0), 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
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
        "stand here to steal (40% / 3s, 5s before first steal)" if localPlayer.faction != FACTIONS.RICH else "buy {} {} to add money\nkeep other factions away".format(shopIcons[STATS.OBJECTIVE], shopItems[STATS.OBJECTIVE])), BankPos + 3*Vector.UP, 1.5, Clip.SURFACES, WorldTextReeval.VISIBILITY_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)

    wait()
    ### time HUD + shop prompt ###
    hudSubtext(getAllPlayers(), "{}:{}:{}{} (game ends at 4:30:00)".format(floor(getTotalTimeElapsed()/3600) if getTotalTimeElapsed() > 3600 else "00", floor(getTotalTimeElapsed() / 60 % 60), 0 if getTotalTimeElapsed() % 60 < 10 else l"", floor(getTotalTimeElapsed() % 60)), HudPosition.LEFT, -1, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubheader(getAllPlayers(), "stand still while holding [{}] and [{}] to enter the shop\nuse import code {} for the latest version".format(buttonString(Button.CROUCH), buttonString(Button.INTERACT), ImportCode), HudPosition.LEFT, -0.9, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)

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

    ### black market hud is in its init rule ###

    #### event ###
    hudText(localPlayer if localPlayer.faction >= 0 and localPlayer not in shoppers else [], "\&fullwidth_space;{} ({}s)\&fullwidth_space;".format(eventText, round(eventTime)), "", " \n ", HudPosition.TOP, 0, Color.LIME_GREEN if eventType != -1 else Color.GRAY, Color.GRAY, Color.GRAY, HudReeval.VISIBILITY_STRING_AND_COLOR, SpecVisibility.ALWAYS)
    ### dakka hud ###
    hudSubtext(getAllPlayers(), " ", HudPosition.LEFT, 1, Color.GRAY, HudReeval.VISIBILITY)
    createProgressBarInWorldText(localPlayer if localPlayer.dakkaFx != null else [],
        100 * localPlayer.dakkaTime / localPlayer.stats[STATS.DAKKA], "rapid fire ({}s left) | [{}] to cancel".format(round(localPlayer.dakkaTime), buttonString(Button.INTERACT)),
        updateEveryTick(
            localPlayer.getEyePosition() + 100 * ( # X_POS * World Vector Of(Right, Local Player, Rotation) +
            (-0.6 - 0.200) * angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90) +
            3 * localPlayer.getFacingDirection())), 1.2, Clip.NONE, Color.SKY_BLUE, Color.WHITE, ProgressWorldTextReeval.VISIBILITY_POSITION_VALUES_AND_COLOR, SpecVisibility.DEFAULT)

    hudText(localPlayer if localPlayer.stats[STATS.DAKKA] else [], abilityIconString(Hero.PHARAH, Button.ULTIMATE),
        "rapid fire (lasts {}s, cd {}s)".format(localPlayer.stats[STATS.DAKKA], RapidCd), "ready" if localPlayer.dakkaTime >= 0 else "cooldown {}s".format(round(abs(localPlayer.dakkaTime))),
        HudPosition.LEFT, 1.1, Color.AQUA, Color.AQUA, Color.TURQUOISE if localPlayer.dakkaTime >= 0 else Color.GRAY, HudReeval.VISIBILITY_STRING_AND_COLOR)

    ###

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
    wait()
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
    createInWorldText(shoppers, "horizontal movement [a/d] to scroll", ShopCamPos + 100 * (
        (1.25 - 0.200) * angleToDirection(horizontalAngleOfDirection(directionTowards(ShopCamPos, ShopLookPos)), verticalAngleOfDirection(directionTowards(ShopCamPos, ShopLookPos)) - 90) +
        3 * directionTowards(ShopCamPos, ShopLookPos)), 2, Clip.NONE, WorldTextReeval.VISIBILITY_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)
    createInWorldText(shoppers, "[{}/{}/{}] to buy 1/20/500 times".format(buttonString(Button.JUMP), buttonString(Button.PRIMARY_FIRE), buttonString(Button.SECONDARY_FIRE)), ShopCamPos + 100 * (
        (1.1 - 0.200) * angleToDirection(horizontalAngleOfDirection(directionTowards(ShopCamPos, ShopLookPos)), verticalAngleOfDirection(directionTowards(ShopCamPos, ShopLookPos)) - 90) +
        3 * directionTowards(ShopCamPos, ShopLookPos)), 2, Clip.NONE, WorldTextReeval.VISIBILITY_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)
    createInWorldText(shoppers, "hold [{}] while buying to buy repeatedly".format(buttonString(Button.CROUCH)), ShopCamPos + 100 * (
        (0.95 - 0.200) * angleToDirection(horizontalAngleOfDirection(directionTowards(ShopCamPos, ShopLookPos)), verticalAngleOfDirection(directionTowards(ShopCamPos, ShopLookPos)) - 90) +
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
    createInWorldText(shoppers, "◀ {} {} ▶".format(shopIcons[localPlayer.option],
        shopItems[localPlayer.option]), ShopCamPos + 100 * (
        (-0.1 - 0.200 + 0.02*sin(getTotalTimeElapsed() % 6.283)) * angleToDirection(horizontalAngleOfDirection(directionTowards(ShopCamPos, ShopLookPos)), verticalAngleOfDirection(directionTowards(ShopCamPos, ShopLookPos)) - 90) +
        3 * directionTowards(ShopCamPos, ShopLookPos)), 4.2, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)
    createInWorldText(shoppers, b" {} / {} {} | ${} ".format(abs(localPlayer.stats[localPlayer.option]),
        abs(statCaps[localPlayer.option]),
        shopUnits[localPlayer.option],
        shopPrices[localPlayer.option]), ShopCamPos + 100 * (
        (-0.27 - 0.200 + 0.02*sin(getTotalTimeElapsed() % 6.283)) * angleToDirection(horizontalAngleOfDirection(directionTowards(ShopCamPos, ShopLookPos)), verticalAngleOfDirection(directionTowards(ShopCamPos, ShopLookPos)) - 90) +
        3 * directionTowards(ShopCamPos, ShopLookPos)), 3, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)
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

    # coconut.jpg moment
    factPoints.append(null)
    for i_init in range(10):
        factPoints[len(factPoints) - 1]++
        createBeam(getAllPlayers(), Beam.GOOD, vect(41.72, 41 - i_init*0.22, -26.06), vect(41.68, 41 - i_init*0.22, -28.89),
            Color.SKY_BLUE if abs(4.5-i_init) >= 3.5 else (
                Color.ROSE if abs(4.5-i_init) >= 1.5 else Color.WHITE
            ), EffectReeval.VISIBILITY)
    factPoints.append(getLastCreatedEntity())
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
        eventPlayer.getEyePosition() + Vector.UP,
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
        # eventPlayer.enableGamemodeHud()
        eventPlayer.enableHeroHud()
        resume()

    if eventPlayer.faction == FACTIONS.GAIA:
        eventPlayer.stats[STATS.DAMAGE] = 75
        eventPlayer.stats[STATS.DEFENSE] = -75
        eventPlayer.setDamageDealt(75)
        eventPlayer.setDamageReceived(75)
    smallMessage(eventPlayer, "you joined {}.".format(factNames[eventPlayer.faction]))

    chase(eventPlayer.cautTime, 0, rate=1, ChaseReeval.DESTINATION_AND_RATE)
    # catchup
    eventPlayer.money = 6969696969 #max(500, (getTotalTimeElapsed()-360) * 90)
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
    # not in black market. view angle doesn't consider los or distance so don't use
    @Condition distance(eventPlayer, vect(86.56, 7, -11.5)) >= 3.3
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
        playEffect(eventPlayer, DynamicEffect.BUFF_IMPACT_SOUND, Color.WHITE, ShopCamPos, 70)
        playEffect(eventPlayer, DynamicEffect.GOOD_PICKUP_EFFECT, Color.VIOLET, ShopLookPos, 5)

        wait(0.064)
        if not eventPlayer.isHoldingButton(Button.CROUCH):
            return
    while RULE_CONDITION

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
    eventPlayer.clearStatusEffect(Status.PHASED_OUT)
    wait(0.032) # update stats
    # eventPlayer.setMoveSpeed(eventPlayer.stats[STATS.MOVESPEED])
    eventPlayer.setMaxHealth(eventPlayer.stats[STATS.HEALTH])
    eventPlayer.setDamageDealt(eventPlayer.stats[STATS.DAMAGE])
    eventPlayer.setDamageReceived(-eventPlayer.stats[STATS.DEFENSE])
    eventPlayer.setHealingReceived(eventPlayer.stats[STATS.HEALING])
    eventPlayer.setProjectileGravity(-0.25 * eventPlayer.stats[STATS.PROJECTILE] + 125)
    eventPlayer.setProjectileSpeed(eventPlayer.stats[STATS.PROJECTILE])
    wait()
    # set ammo
    eventPlayer.setMaxAmmo(0, eventPlayer.getMaxAmmo(0)*eventPlayer.stats[STATS.AMMO]/100)
    eventPlayer.setMaxAmmo(1, eventPlayer.getMaxAmmo(1)*eventPlayer.stats[STATS.AMMO]/100)
    wait(0.032)
    eventPlayer.setScore(eventPlayer.level / 100)
    if eventPlayer.faction == FACTIONS.RICH: # bank
        factPoints[eventPlayer.faction] += shopPrices[STATS.OBJECTIVE] * (eventPlayer.stats[STATS.OBJECTIVE] - 100) / 10
        eventPlayer.stats[STATS.OBJECTIVE] = 100
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
    createIcon(localPlayer if not localPlayer in shoppers else [], moonPos + Vector.UP * (3 + 0.3*sin(getTotalTimeElapsed())),
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
    @Condition eventPlayer.hasStatusEffect(Status.PHASED_OUT)
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
    # @Condition eventPlayer.hasStatusEffect(Status.PHASED_OUT)
    @Condition distance(eventPlayer, factSpawns[eventPlayer.faction]) <= 3
    if eventType == EVENTS.HERO:
        smallMessage(eventPlayer, "you can't change heroes during this event.")
        return
    # smallMessage(eventPlayer, "hold crouch to swap heroes...")
    wait(0.5, Wait.ABORT_WHEN_FALSE)
    wait()
    # reset ammo
    # eventPlayer.setMaxAmmo(0, eventPlayer.getMaxAmmo(0)*100/eventPlayer.stats[STATS.AMMO])
    # eventPlayer.setMaxAmmo(1, eventPlayer.getMaxAmmo(1)*100/eventPlayer.stats[STATS.AMMO])
    eventPlayer.setAllowedHeroes(getAllHeroes().exclude(eventPlayer.getCurrentHero()))
    wait()
    eventPlayer.resetHeroAvailability()

# bank
rule "rob bank":
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
			eventPlayer.money += 0.4 * factPoints[FACTIONS.RICH]
			factPoints[FACTIONS.RICH] *= 0.6
		playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION, Color.RED, BankPos + Vector.UP, 9)

# shop upgrades
rule "flight":
	@Event eachPlayer
	@Condition eventPlayer.stats[STATS.FLIGHT]
	@Condition eventPlayer.isHoldingButton(Button.JUMP)
	@Condition eventPlayer.isAlive()
	do:
		eventPlayer.applyImpulse(Vector.UP, 5, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
		wait(0.064)
	while RULE_CONDITION

rule "rapid fire input":
	@Event eachPlayer
	@Condition eventPlayer.isAlive()
	@Condition eventPlayer.stats[STATS.DAKKA]
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) and eventPlayer.isHoldingButton(Button.MELEE)
    if eventPlayer.dakkaTime < 0: # cooldown
        smallMessage(eventPlayer, "rapid fire not ready (wait {}s)".format(round(abs(eventPlayer.dakkaTime))))
    elif eventPlayer.dakkaTime == 0: # activate
        eventPlayer.dakkaTime = eventPlayer.stats[STATS.DAKKA]
        chase(eventPlayer.dakkaTime, 0, rate=1, ChaseReeval.DESTINATION_AND_RATE)
        playEffect(getAllPlayers(), DynamicEffect.GOOD_PICKUP_EFFECT, Color.SKY_BLUE, eventPlayer.getEyePosition(), 1.5)
        playEffect(getAllPlayers(), DynamicEffect.BUFF_EXPLOSION_SOUND, Color.WHITE, eventPlayer, 30)
        createEffect(getAllPlayers(), Effect.SPARKLES, Color.SKY_BLUE, eventPlayer, 1.5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        eventPlayer.dakkaFx = getLastCreatedEntity()
        wait(eventPlayer.dakkaTime) # can't abort or won't set cd
        eventPlayer.dakkaTime = -RapidCd

rule "dakkadakkadakka":
    @Event eachPlayer
    @Condition eventPlayer.dakkaTime > 0
    do:
        eventPlayer.setProjectileSpeed(eventPlayer.stats[STATS.PROJECTILE])
        wait(0.112)
    while RULE_CONDITION

rule "rapid fire end":
    @Event eachPlayer
    @Condition (eventPlayer.dakkaTime < 0) or (eventPlayer.isHoldingButton(Button.INTERACT) and eventPlayer.dakkaTime > 0)
    if eventPlayer.dakkaTime > 0:
        wait(0.56, Wait.ABORT_WHEN_FALSE)
        # smallMessage(eventPlayer, "[{}] hold to cancel rapid fire...".format(buttonString(Button.INTERACT)))
        wait(0.56, Wait.ABORT_WHEN_FALSE)
        eventPlayer.dakkaTime = -RapidCd
    destroyEffect(eventPlayer.dakkaFx)
    playEffect(getAllPlayers(), DynamicEffect.BAD_EXPLOSION, Color.BLUE, eventPlayer, 1.5)
    playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION_SOUND, Color.WHITE, eventPlayer, 30)
    eventPlayer.dakkaFx = 0

rule "min ult":
    @Event eachPlayer
    @Condition eventPlayer.isAlive()
    # @Condition eventPlayer.hasSpawned()
    @Condition eventPlayer.getUltCharge() < eventPlayer.stats[STATS.ULT]
    do:
        eventPlayer.setUltCharge(eventPlayer.stats[STATS.ULT])
        wait(1)
    while RULE_CONDITION

rule "apply hack & caut var":
    @Event playerDealtDamage
    @Condition eventPlayer != victim
    if ((eventPlayer.marketStats[MARKET.HACK] > 0) # hack
    and (victim.getHealth() < 0.5 * victim.getMaxHealth())
    and (eventDamage + victim.getHealth() >= 0.5 * victim.getMaxHealth())):
        victim.setStatusEffect(eventPlayer, Status.HACKED, eventPlayer.marketStats[MARKET.HACK])

    if victim.cautTime < eventPlayer.marketStats[MARKET.CAUT]:
        victim.cautTime = eventPlayer.marketStats[MARKET.CAUT]

rule "apply caut":
    @Event eachPlayer
    @Condition eventPlayer.cautTime > 0
    eventPlayer.setHealingReceived(0.5 * eventPlayer.stats[STATS.HEALING])
    waitUntil(eventPlayer.cautTime <= 0, 3.5)
    eventPlayer.setHealingReceived(eventPlayer.stats[STATS.HEALING])

# black market
rule "black market init & rotate":
    createEffect(getAllPlayers(), Effect.CLOUD, Color.BLACK, vect(82.13, 7.5, -14.82), 5 + sin(4*getTotalTimeElapsed()), EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createInWorldText(getAllPlayers(), "{} psst... wanna buy some candy?".format(heroIcon(Hero.ANA)), vect(86.56, 7, -11.5), 1.5, Clip.SURFACES, WorldTextReeval.VISIBILITY, Color.WHITE, SpecVisibility.DEFAULT)
    createInWorldText(getAllPlayers(),"current deal:", vect(81.42, 11, -15.47), 1.5, Clip.SURFACES, WorldTextReeval.VISIBILITY, Color.WHITE, SpecVisibility.ALWAYS)
    createInWorldText(getAllPlayers(), marketItems[marketNo], vect(81.42, 10.4 + 0.1*sin(getTotalTimeElapsed()), -15.47), 2.5, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR, rgb(
        128 + 127 * cosDeg(getTotalTimeElapsed() * 100),
        128 + 127 * cosDeg((getTotalTimeElapsed() * 100) + 120),
        128 + 127 * cosDeg((getTotalTimeElapsed() * 100) + 240)
    ), SpecVisibility.ALWAYS)
    createInWorldText(getAllPlayers(), marketDescs[marketNo], vect(81.42, 9.1, -15.47), 1.2, Clip.SURFACES, WorldTextReeval.VISIBILITY_AND_STRING, Color.WHITE, SpecVisibility.ALWAYS)
    createInWorldText(getAllPlayers(),"${}\nlevel {} / {}\nnext deal in {}s".format(marketPrices[marketNo], localPlayer.marketStats[marketNo], marketStatCaps[marketNo], floor(marketTime)), vect(81.42, 8.1, -15.47), 1.4, Clip.SURFACES, WorldTextReeval.VISIBILITY_AND_STRING, Color.WHITE, SpecVisibility.ALWAYS)
    createInWorldText(getAllPlayers(), "[{}] to buy\n[{}] to downgrade (no refunds)\n[{}] while buying or downgrading\nto do it quickly".format(buttonString(Button.INTERACT), buttonString(Button.MELEE), buttonString(Button.CROUCH)),
        vect(81.42, 7, -15.47), 1, Clip.SURFACES, WorldTextReeval.VISIBILITY_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)

    chase(marketTime, 0, rate=1, ChaseReeval.DESTINATION_AND_RATE)
    while true:
        marketTime = random.randint(150, 270)
        wait(marketTime)
        marketNo = (marketNo + 1) % len(marketItems)

rule "black market buy":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.INTERACT)
    @Condition distance(eventPlayer, vect(86.56, 7, -11.5)) <= 3.3
    @Condition eventPlayer.isInViewAngle(vect(81.42, 8.5, -15.47), 100)
    do:
		# message if can't buy 1
        if eventPlayer.money < marketPrices[marketNo]:
            playEffect(eventPlayer, DynamicEffect.DEBUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 50)
            smallMessage(eventPlayer, "{} sorry, but my candy is too expensive for you, traveller.".format(heroIcon(Hero.ANA)))
            return

        if eventPlayer.marketStats[marketNo] >= marketStatCaps[marketNo]:
            playEffect(eventPlayer, DynamicEffect.DEBUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 50)
            smallMessage(eventPlayer, "{} that's too much candy! i can't give you any more.".format(heroIcon(Hero.ANA)))
            return

        # buy
        eventPlayer.money -= marketPrices[marketNo]
        eventPlayer.marketStats[marketNo] ++
        eventPlayer.level += 300
        playEffect(eventPlayer, DynamicEffect.BUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 70)
        playEffect(eventPlayer, DynamicEffect.GOOD_PICKUP_EFFECT, Color.VIOLET, eventPlayer, 5)
        wait(0.096)
        if not eventPlayer.isHoldingButton(Button.CROUCH):
            wait(0.16)
    while RULE_CONDITION

rule "black market return":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.MELEE)
    @Condition distance(eventPlayer, vect(86.56, 7, -11.5)) <= 3.3
    @Condition eventPlayer.isInViewAngle(vect(81.42, 8.5, -15.47), 100)
    smallMessage(eventPlayer, "hold [{}] to return this item...".format(buttonString(Button.MELEE)))
    wait(0.8, Wait.ABORT_WHEN_FALSE)
    while eventPlayer.isHoldingButton(Button.MELEE):
        wait(0.4, Wait.ABORT_WHEN_FALSE)
        if eventPlayer.marketStats[marketNo] == baseMarketStats[marketNo]:
            playEffect(eventPlayer, DynamicEffect.DEBUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 50)
            smallMessage(eventPlayer, "{} you don't have any more candy to return.".format(heroIcon(Hero.ANA)))
            return

        eventPlayer.marketStats[marketNo]--
        eventPlayer.level -= 300
        wait(0.112)
        if not eventPlayer.isHoldingButton(Button.CROUCH):
            wait(0.16)

rule "black market leave, stat update":
    @Event eachPlayer
    @Condition distance(eventPlayer, vect(86.56, 7, -11.5)) <= 3.3
    waitUntil(distance(eventPlayer, vect(86.56, 7, -11.5)) > 3, 9999)
    smallMessage(eventPlayer, "{} {}".format(heroIcon(Hero.ANA), random.choice(marketQuips)))
    eventPlayer.startScalingSize(1 - eventPlayer.marketStats[MARKET.SHRINK]/100, false)
    eventPlayer.setMoveSpeed(eventPlayer.stats[STATS.MOVESPEED] + eventPlayer.marketStats[MARKET.MOVESPEED])
    eventPlayer.startScalingBarriers(eventPlayer.marketStats[MARKET.BARRIER]/100, factCams)
    eventPlayer.setKnockbackReceived(eventPlayer.marketStats[MARKET.KNOCK])
    eventPlayer.setKnockbackDealt(eventPlayer.marketStats[MARKET.STEADFAST])

# events
rule "gen events":
    @Condition isGameInProgress()
    # @Condition getMatchTime() < 0.2
    eventType = -1
    eventText = "next event coming soon"
    wait(1.6)
    eventTime = 120
    chase(eventTime, -5, rate=1, ChaseReeval.DESTINATION_AND_RATE)
    wait(eventTime)
    # bigMessage(getAllPlayers(), getMatchTime())
    while true:
        if eventType == -1:
            eventType = random.randint(0, EVENTS.HERO)
            switch eventType: # events with side effects are updated in player init
                case EVENTS.BLOOD:
                    eventDetail = random.randint(3, 7)
                    eventText = "{} event: blood god grants {}x money!".format(iconString(Icon.POISON), eventDetail)
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
                case EVENTS.BOSS:
                    eventDetail = sorted(getAllPlayers(), lambda x: -x.level)[0] # target
                    bossEventSetup()
                    break
                case EVENTS.HERO:
                    for eventDetail in range(getNumberOfPlayers(Team.ALL)):
                        # reset ammo
                        eventDetail.setMaxAmmo(0, eventDetail.getMaxAmmo(0)*100/eventDetail.stats[STATS.AMMO])
                        eventDetail.setMaxAmmo(1, eventDetail.getMaxAmmo(1)*100/eventDetail.stats[STATS.AMMO])
                        getAllPlayers()[eventDetail].eventVar = getAllPlayers()[eventDetail].getCurrentHero()
                        # set ammo
                        getAllPlayers()[eventDetail].setMaxAmmo(0, getAllPlayers()[eventDetail].getMaxAmmo(0)*getAllPlayers()[eventDetail].stats[STATS.AMMO]/100)
                        getAllPlayers()[eventDetail].setMaxAmmo(1, getAllPlayers()[eventDetail].getMaxAmmo(1)*getAllPlayers()[eventDetail].stats[STATS.AMMO]/100)
                        wait()
                    eventDetail = random.choice(getAllHeroes())
                    eventText = "event: {} hero swap".format(heroIcon(eventDetail))
                    getAllPlayers().startForcingHero(eventDetail)
                    break
            bigMessage(getAllPlayers(), eventText)
            eventTime = random.randint(20, 35)
            wait()
            wait(eventTime)
        else:
            switch eventType:
                case EVENTS.HERO:
                    for eventType in range(getNumberOfPlayers(Team.ALL)):
                        getAllPlayers()[eventType].startForcingHero(getAllPlayers()[eventType].eventVar)
                        if getAllPlayers()[eventType].getCurrentHero() != eventDetail:
                            getAllPlayers()[eventType].setMaxAmmo(0, getAllPlayers()[eventType].getMaxAmmo(0)*getAllPlayers()[eventType].stats[STATS.AMMO]/100)
                            getAllPlayers()[eventType].setMaxAmmo(1, getAllPlayers()[eventType].getMaxAmmo(1)*getAllPlayers()[eventType].stats[STATS.AMMO]/100)
                        wait()
                    break
                case EVENTS.BOSS:
                    bossEventCleanup()
                    break

            eventType = -1
            eventText = "next event coming soon"
            getAllPlayers().setGravity(100)
            getAllPlayers().stopForcingCurrentHero()
            bigMessage(getAllPlayers(), "event ended.")
            eventTime = random.randint(180, 270)
            # setMatchTime(30)
            wait()
            wait(eventTime)
            # bigMessage(getAllPlayers(), getMatchTime())
# misc
rule "elim handling":
    @Event playerEarnedElimination
    @Condition eventPlayer != victim
    @Condition victim.blower != eventPlayer
    wait(0.08, Wait.ABORT_WHEN_FALSE)
    smallMessage(eventPlayer, "elimination +${}".format(max(300, 0.5*victim.level) * MoneyMult))
    eventPlayer.money += max(300, 0.5*victim.level) * MoneyMult
    victim.blower = null

    # troon check
    if len(factPoints) != len(factGoalStrings) + 1:
        while true:
            getAllPlayers().startCamera(Vector.DOWN, 2*Vector.DOWN, 0)
            smallMessage(getAllPlayers(), "{} this gamemode has been tampered with. use import code {}".format(abilityIconString(Hero.SOMBRA, Button.ULTIMATE), ImportCode))
            i_init = raycast(random.choice(getAllPlayers()), random.choice(getAllPlayers()), [], [], true).getNormal()


rule "final blow handling":
    @Event playerDealtFinalBlow
    @Condition eventPlayer != victim

    victim.blower = eventPlayer

    # freeze
    getPlayersInRadius(victim, 5, Team.ALL, LosCheck.SURFACES_AND_ALL_BARRIERS).exclude(eventPlayer).setStatusEffect(eventPlayer, Status.FROZEN, eventPlayer.marketStats[MARKET.ICE])
    playEffect(victim, DynamicEffect.RING_EXPLOSION, Color.AQUA, victim, 5)

	# rich money bonus
	if eventPlayer.faction == FACTIONS.RICH:
		eventPlayer.money *= 1.1
    # money
    eventPlayer.money += ((max(900, 2*victim.level)*MoneyMult + victim.money * stealPortion * (1.5 if victim.faction == FACTIONS.RICH and victim.money > eventPlayer.money else 1))
        * (2 if eventPlayer.faction == FACTIONS.RICH else 1)) * (eventDetail if eventType == EVENTS.KILL else 1) # bonuses to both steal portion & base money increase

    victim.money *= 1 - stealPortion * (1.5 if victim.faction == FACTIONS.RICH and victim.money > eventPlayer.money else 1)

    # quest
    if eventPlayer.questGoal == victim and eventPlayer.questType == QUEST_TYPE.HITMAN:
        questComplete()

    # boss event
    if eventType == EVENTS.BOSS:
        if eventPlayer == eventDetail: # boss got kill
            smallMessage(eventPlayer, "got kill as boss. +${}".format(3500 * MoneyMult))
            eventPlayer.money += 3500 * MoneyMult
        elif victim == eventDetail: # boss killed
            bossEventCleanup()
            wait()
            eventPlayer.money += eventDetail.level * 3 * MoneyMult
            eventDetail.money -= eventDetail.level * 0.7
            smallMessage(eventDetail, "you are no longer the boss. lost ${}".format(eventDetail.level * 0.7))
            smallMessage(eventPlayer, "you are the new boss! earned ${}.".format(eventDetail.level * 4))
            wait()
            eventDetail = eventPlayer
            wait()
            bossEventSetup()

    # robber or miner
    if (victim.mineFx != null and eventPlayer.faction == FACTIONS.GAIA):
        smallMessage(eventPlayer, "killed a blizzcoin miner. +${}, {} faction points".format(MoneyMult * victim.level * 3, FactPointsMult * victim.level))
    elif (eventPlayer.faction == FACTIONS.RICH and (victim.faction != FACTIONS.RICH) and distance(victim, BankPos) < 5.5):
        smallMessage(eventPlayer, "killed a bank robber. +${}, {} faction points".format(MoneyMult * victim.level * 3, FactPointsMult * victim.level))

    if false:
        lbl_0:
        eventPlayer.money += MoneyMult * victim.level * 3
        factPoints[eventPlayer.faction] += FactPointsMult * victim.level

    ### enemy ###
    # killed enemy
    if eventPlayer.faction in victim.enemies:
        smallMessage(eventPlayer, "killed a faction enemy. +${}, {} faction points".format(MoneyMult * victim.level * 5, FactPointsMult * victim.level * 2))
        smallMessage(victim, "you are no longer wanted by {}.".format(factNames[eventPlayer.faction]))
        victim.enemies.remove(eventPlayer.faction)
        eventPlayer.money += MoneyMult * victim.level * 5
        factPoints[eventPlayer.faction] += FactPointsMult * victim.level * 2
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
    wait(0.048)
    eventPlayer.teleport(factSpawns[eventPlayer.faction])
    eventPlayer.setMaxAmmo(0, eventPlayer.getMaxAmmo(0)*eventPlayer.stats[STATS.AMMO]/100)
    eventPlayer.setMaxAmmo(1, eventPlayer.getMaxAmmo(1)*eventPlayer.stats[STATS.AMMO]/100)
    wait(0.032)

    if eventPlayer.getCurrentHero() == Hero.DVA and eventPlayer.isInAlternateForm():
        eventPlayer.setUltCharge(100)

    wait(0.32)
    eventPlayer.forceButtonPress(Button.RELOAD)

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
    wait(0.4, Wait.ABORT_WHEN_FALSE)
    # @Condition distance(eventPlayer, getClosestPlayer(eventPlayer, Team.ALL)) <= 3
    smallMessage(getPlayersInRadius(eventPlayer, 3, Team.ALL, LosCheck.SURFACES).exclude(eventPlayer), "{}{} is healing you. stay near them!".format(heroIcon(eventPlayer.getCurrentHero()), eventPlayer))
    while eventPlayer.isCrouching() and eventPlayer.isAlive():
        heal(getPlayersInRadius(eventPlayer, 3, Team.ALL, LosCheck.SURFACES).exclude(eventPlayer), eventPlayer, 12)
        heal(eventPlayer, eventPlayer, 4)
        playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION, Color.LIME_GREEN, eventPlayer.getPosition(), 4.5) # ring radius is smaller than actual
        wait(0.2)

rule "gaia healing credit":
    @Event playerDealtHealing
    @Condition eventPlayer.faction == FACTIONS.GAIA
    @Condition healee != eventPlayer
    @Condition eventHealing > 0
    factPoints[eventPlayer.faction] += eventHealing * FactPointsMult * (0.5 if healee.faction == FACTIONS.GAIA else 1)
    eventPlayer.money += 20 * (1 + 0.2 * factLevels[eventPlayer.faction]) * (0.5 if healee.faction == FACTIONS.GAIA else 1)

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
rule "damage when stat > 10000":
    @Event playerDealtDamage
    @Condition eventDamage > 0
    @Condition eventPlayer.stats[STATS.DAMAGE] > 10000
    damage(victim, null, eventDamage * (eventPlayer.stats[STATS.DAMAGE] - 10000))
    # null to avoid looping
rule "heal when stat > 10000":
    @Event playerReceivedHealing
    @Condition eventHealing > 0
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
    # clean huds, fx, etc
    shoppers.remove(eventPlayer)
    factMembers[eventPlayer.faction]--

	destroyEffect(eventPlayer.bloodFx)
	stopDoT(eventPlayer.bloodDoT)
    destroyInWorldText(eventPlayer.hudId)
    if eventPlayer.mineFx != null:
        destroyEffect(eventPlayer.mineFx)
        minerCount -= 1.5 if eventPlayer.faction == FACTIONS.SOMBRUH else 1
    destroyEffect(eventPlayer.dakkaFx)
    # events
    if eventType == EVENTS.BOSS and eventPlayer == eventDetail: # if event player is the boss
        bossEventCleanup()
        wait()
        eventDetail = sorted(getAllPlayers(), lambda x: -x.level)[0]
        wait()
        bossEventSetup()
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

# technical
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

rule "debug bot spawn + advance market item":
    @Condition "{}".format(hostPlayer) == "OMGIDIED"
    @Condition hostPlayer.isHoldingButton(Button.MELEE) and hostPlayer.isHoldingButton(Button.INTERACT) and hostPlayer.isInAir()
    createDummy(random.choice(getAllHeroes()), Team.ALL, -1, hostPlayer, Vector.UP)
    wait(0.080)
    getLastCreatedEntity().clearStatusEffect(Status.PHASED_OUT)
    getLastCreatedEntity().faction = random.randint(0, FACTIONS.SOMBRUH)
    getLastCreatedEntity().startForcingButton(Button.CROUCH)
    getLastCreatedEntity().startForcingButton(Button.PRIMARY_FIRE)
    getLastCreatedEntity().setMaxHealth(999999999999)
    marketNo++

rule "yeet debug bot":
    @Event playerTookDamage
    @Condition eventAbility == Button.MELEE
    @Condition attacker == hostPlayer
    destroyDummy(Team.ALL, eventPlayer.getSlot())
/*2do
- move tuto cam (market, intro)
- armor stat
- refund item that isn't in rotation
- test freeze
- more events (punching bag if slot available? faction point bonus? wallhax?)
- bank & robbing balance
- test sombra invis hud
- earning $/s hud
- balance catchup
- catchup faction points for empty factions (do on player joining faction)
- compensate for low faction membership in objectives

faction select
- children of gaia (goal: heal)
- cult of the blood god (goal: feed blood)
- the 0.1%
- the singularity

 to encourage peace*/