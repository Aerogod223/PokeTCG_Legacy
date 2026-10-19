AIActionTable_GoGoRainDance:
	dw AIMainTurnLogic                ; .do_turn (unused)
	dw AIMainTurnLogic                ; .do_turn
	dw .start_duel
	dw AIDecideBenchPokemonToSwitchTo ; .forced_switch
	dw AIDecideBenchPokemonToSwitchTo ; .ko_switch
	dw AIPickPrizeCards               ; .take_prize

.start_duel
	call InitAIDuelVars
	call .store_list_pointers
	call SetUpBossStartingHandAndDeck
	call TrySetUpBossStartingPlayArea
	ret nc
	jp AIPlayInitialBasicCards

.list_arena
	db LAPRAS
	db ARTICUNO_LV35
	db MAGIKARP
	db SQUIRTLE
	db $00

.list_bench
	db SQUIRTLE
	db MAGIKARP
	db ARTICUNO_LV35
	db LAPRAS
	db $00

.list_retreat
	ai_retreat SQUIRTLE,  +1
	ai_retreat MAGIKARP,  +3
	db $00

.list_energy
	ai_energy SQUIRTLE,        2, +0
	ai_energy WARTORTLE,       3, +0
	ai_energy BLASTOISE,       5, +0
	ai_energy ARTICUNO_LV35,   3, +1
	ai_energy MAGIKARP,        2, -2
	ai_energy GYARADOS,        4, +2
	ai_energy LAPRAS,          3, +1
	db $00

.list_prize
	db SUPER_POTION
	db SUPER_ENERGY_RETRIEVAL
	db SUPER_ENERGY_RETRIEVAL
	db BLASTOISE
	db $00

.store_list_pointers
	store_list_pointer wAICardListAvoidPrize, .list_prize
	store_list_pointer wAICardListArenaPriority, .list_arena
	store_list_pointer wAICardListBenchPriority, .list_bench
	store_list_pointer wAICardListPlayFromHandPriority, .list_bench
	store_list_pointer wAICardListRetreatBonus, .list_retreat
	store_list_pointer wAICardListEnergyBonus, .list_energy
	ret

AIActionTable_RematchGoGoRainDance:
	dw AIMainTurnLogic
	dw AIMainTurnLogic
	dw RematchGoGoRainDance_StartDuel
	dw AIDecideBenchPokemonToSwitchTo
	dw AIDecideBenchPokemonToSwitchTo
	dw AIPickPrizeCards

RematchGoGoRainDance_StartDuel:
	call InitAIDuelVars
	store_list_pointer wAICardListAvoidPrize, RematchGoGoRainDance_PrizeList
	store_list_pointer wAICardListArenaPriority, RematchGoGoRainDance_ArenaList
	store_list_pointer wAICardListBenchPriority, RematchGoGoRainDance_BenchList
	store_list_pointer wAICardListPlayFromHandPriority, RematchGoGoRainDance_BenchList
	store_list_pointer wAICardListRetreatBonus, RematchGoGoRainDance_RetreatList
	store_list_pointer wAICardListEnergyBonus, RematchGoGoRainDance_EnergyList
	call SetUpBossStartingHandAndDeck
	call TrySetUpBossStartingPlayArea
	ret nc
	jp AIPlayInitialBasicCards

RematchGoGoRainDance_ArenaList:
	db LAPRAS, ARTICUNO_LV35, MAGIKARP, SQUIRTLE, $00
RematchGoGoRainDance_BenchList:
	db SQUIRTLE, MAGIKARP, ARTICUNO_LV35, LAPRAS, $00
RematchGoGoRainDance_RetreatList:
	ai_retreat SQUIRTLE, +1
	ai_retreat MAGIKARP, +3
	db $00
RematchGoGoRainDance_EnergyList:
	ai_energy SQUIRTLE, 2, +0
	ai_energy WARTORTLE, 3, +0
	ai_energy BLASTOISE, 5, +0
	ai_energy ARTICUNO_LV35, 3, +1
	ai_energy MAGIKARP, 2, -2
	ai_energy GYARADOS, 4, +2
	ai_energy LAPRAS, 3, +1
	db $00
RematchGoGoRainDance_PrizeList:
	db SUPER_POTION, SUPER_ENERGY_RETRIEVAL, SUPER_ENERGY_RETRIEVAL, BLASTOISE, $00
