#!obfuscate noRuleFilling noNameObfuscation
#!mainFile "main.opy"

# troon
rule "":
	for i_init in range(10):
		createBeam(getAllPlayers(), Beam.GOOD, vect(41.72, 41 - i_init*0.22, -26.06), vect(41.68, 41 - i_init*0.22, -28.89),
			Color.SKY_BLUE if abs(4.5-i_init) >= 3.5 else (
				Color.ROSE if abs(4.5-i_init) >= 1.5 else Color.WHITE
			), EffectReeval.VISIBILITY)