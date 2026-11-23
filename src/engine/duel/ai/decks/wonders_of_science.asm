AIActionTable_WondersOfScience:
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
	db MEWTWO_LV53
	db MEWTWO_ALT_LV60
	db MEWTWO_LV60
	db SCYTHER
	db PINSIR
	db MR_MIME
	db GRIMER
	db PORYGON
	db $00

.list_bench
	db GRIMER
	db PORYGON
	db SCYTHER
	db PINSIR
	db MEWTWO_ALT_LV60
	db MEWTWO_LV60
	db MEWTWO_LV53
	db MR_MIME
	db $00

.list_retreat
	db $00

.list_energy
	ai_energy GRIMER,          2, -1
	ai_energy MUK,             2, -1
	ai_energy SCYTHER,         3, +0
	ai_energy PINSIR,          4, +0
	ai_energy MR_MIME,         2, +1
	ai_energy MEWTWO_LV53,     2, +2
	ai_energy MEWTWO_ALT_LV60, 3, +1
	ai_energy MEWTWO_LV60,     3, +1
	ai_energy PORYGON,         3, +0
	db $00

.list_prize
	db MUK
	db $00

.store_list_pointers
	store_list_pointer wAICardListAvoidPrize, .list_prize
	store_list_pointer wAICardListArenaPriority, .list_arena
	store_list_pointer wAICardListBenchPriority, .list_bench
	store_list_pointer wAICardListPlayFromHandPriority, .list_bench
	store_list_pointer wAICardListRetreatBonus, .list_retreat
	store_list_pointer wAICardListEnergyBonus, .list_energy
	ret

AIActionTable_RematchWondersOfScience:
	dw AIMainTurnLogic
	dw AIMainTurnLogic
	dw RematchWondersOfScience_StartDuel
	dw AIDecideBenchPokemonToSwitchTo
	dw AIDecideBenchPokemonToSwitchTo
	dw AIPickPrizeCards

RematchWondersOfScience_StartDuel:
	call InitAIDuelVars
	store_list_pointer wAICardListAvoidPrize, RematchWondersOfScience_PrizeList
	store_list_pointer wAICardListArenaPriority, RematchWondersOfScience_ArenaList
	store_list_pointer wAICardListBenchPriority, RematchWondersOfScience_BenchList
	store_list_pointer wAICardListPlayFromHandPriority, RematchWondersOfScience_BenchList
	store_list_pointer wAICardListRetreatBonus, RematchWondersOfScience_RetreatList
	store_list_pointer wAICardListEnergyBonus, RematchWondersOfScience_EnergyList
	call SetUpBossStartingHandAndDeck
	call TrySetUpBossStartingPlayArea
	ret nc
	jp AIPlayInitialBasicCards

RematchWondersOfScience_ArenaList:
	db GASTLY_LV8
	db CHANSEY
	db LICKITUNG
	db PORYGON
	db $00

RematchWondersOfScience_BenchList:
	db GASTLY_LV8
	db CHANSEY
	db LICKITUNG
	db PORYGON
	db $00

RematchWondersOfScience_RetreatList:
.list_retreat
	ai_retreat LICKITUNG,   -2
	db $00

RematchWondersOfScience_EnergyList:
	ai_energy GASTLY_LV8, 2, -1
	ai_energy HAUNTER_LV17, 2, +0
	ai_energy RICK_GENGAR, 2, +1
	ai_energy GENGAR, 2, -2
	ai_energy CHANSEY, 2, -1
	ai_energy PORYGON, 3, +2
	ai_energy LICKITUNG, 1, +3
	db $00

RematchWondersOfScience_PrizeList:
	db DEVOLUTION_SPRAY, RICK_GENGAR, PROFESSOR_OAK, $00
