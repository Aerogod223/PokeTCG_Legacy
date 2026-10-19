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
	ai_energy PORYGON,         2, -1
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
	db MEWTWO_LV53, MEWTWO_ALT_LV60, MEWTWO_LV60, SCYTHER, PINSIR, MR_MIME, GRIMER, PORYGON, $00
RematchWondersOfScience_BenchList:
	db GRIMER, PORYGON, SCYTHER, PINSIR, MEWTWO_ALT_LV60, MEWTWO_LV60, MEWTWO_LV53, MR_MIME, $00
RematchWondersOfScience_RetreatList:
	db $00
RematchWondersOfScience_EnergyList:
	ai_energy GRIMER, 2, -1
	ai_energy MUK, 2, -1
	ai_energy SCYTHER, 3, +0
	ai_energy PINSIR, 4, +0
	ai_energy MR_MIME, 2, +1
	ai_energy MEWTWO_LV53, 2, +2
	ai_energy MEWTWO_ALT_LV60, 3, +1
	ai_energy MEWTWO_LV60, 3, +1
	ai_energy PORYGON, 2, -1
	db $00
RematchWondersOfScience_PrizeList:
	db MUK, $00
