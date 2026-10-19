AIActionTable_FlowerPower:
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
	db TANGELA_LV12
	db EXEGGCUTE
	db DODUO
	db BULBASAUR
	db $00

.list_bench
	db BULBASAUR
	db EXEGGCUTE
	db DODUO
	db TANGELA_LV12
	db $00

.list_retreat
	ai_retreat DODUO,     +2
	ai_retreat DODRIO, +1
	ai_retreat BULBASAUR, +2
	ai_retreat IVYSAUR,   +1
	ai_retreat EXEGGCUTE, +2
	db $00

.list_energy
	ai_energy BULBASAUR,      3, +0
	ai_energy IVYSAUR,        4, +1
	ai_energy VENUSAUR_LV67,  4, +2
	ai_energy DODUO,          2, -1
	ai_energy DODRIO,         3, -1
	ai_energy TANGELA_LV12,   2, +1
	ai_energy EXEGGCUTE,      3, +0
	ai_energy EXEGGUTOR,     22, +2
	db $00

.list_prize
	db VENUSAUR_LV67
	db $00

.store_list_pointers
	store_list_pointer wAICardListAvoidPrize, .list_prize
	store_list_pointer wAICardListArenaPriority, .list_arena
	store_list_pointer wAICardListBenchPriority, .list_bench
	store_list_pointer wAICardListPlayFromHandPriority, .list_bench
	store_list_pointer wAICardListRetreatBonus, .list_retreat
	store_list_pointer wAICardListEnergyBonus, .list_energy
	ret

AIActionTable_RematchFlowerPower:
	dw AIMainTurnLogic
	dw AIMainTurnLogic
	dw RematchFlowerPower_StartDuel
	dw AIDecideBenchPokemonToSwitchTo
	dw AIDecideBenchPokemonToSwitchTo
	dw AIPickPrizeCards

RematchFlowerPower_StartDuel:
	call InitAIDuelVars
	store_list_pointer wAICardListAvoidPrize, RematchFlowerPower_PrizeList
	store_list_pointer wAICardListArenaPriority, RematchFlowerPower_ArenaList
	store_list_pointer wAICardListBenchPriority, RematchFlowerPower_BenchList
	store_list_pointer wAICardListPlayFromHandPriority, RematchFlowerPower_BenchList
	store_list_pointer wAICardListRetreatBonus, RematchFlowerPower_RetreatList
	store_list_pointer wAICardListEnergyBonus, RematchFlowerPower_EnergyList
	call SetUpBossStartingHandAndDeck
	call TrySetUpBossStartingPlayArea
	ret nc
	jp AIPlayInitialBasicCards

RematchFlowerPower_ArenaList:
	db TANGELA_LV12, EXEGGCUTE, DODUO, BULBASAUR, $00
RematchFlowerPower_BenchList:
	db BULBASAUR, EXEGGCUTE, DODUO, TANGELA_LV12, $00
RematchFlowerPower_RetreatList:
	ai_retreat DODUO, +2
	ai_retreat DODRIO, +1
	ai_retreat BULBASAUR, +2
	ai_retreat IVYSAUR, +1
	ai_retreat EXEGGCUTE, +2
	db $00
RematchFlowerPower_EnergyList:
	ai_energy BULBASAUR, 3, +0
	ai_energy IVYSAUR, 4, +1
	ai_energy VENUSAUR_LV67, 4, +2
	ai_energy DODUO, 2, -1
	ai_energy DODRIO, 3, -1
	ai_energy TANGELA_LV12, 2, +1
	ai_energy EXEGGCUTE, 3, +0
	ai_energy EXEGGUTOR, 22, +2
	db $00
RematchFlowerPower_PrizeList:
	db VENUSAUR_LV67, $00
