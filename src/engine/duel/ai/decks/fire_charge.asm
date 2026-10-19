AIActionTable_FireCharge:
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
	db MAGMAR_LV31
	db ELECTABUZZ_LV35
	db TAUROS
	db VULPIX
	db FLYING_PIKACHU
	db CHARMANDER
	db $00

.list_bench
	db CHARMANDER
	db VULPIX
	db FLYING_PIKACHU
	db TAUROS
	db ELECTABUZZ_LV35
	db MAGMAR_LV31
	db $00

.list_retreat
	ai_retreat CHARMANDER,     +1
	ai_retreat VULPIX,         +1
	ai_retreat MAGMAR_LV31,    -1
	ai_retreat ELECTABUZZ_LV35,     -1
	db $00

.list_energy
	ai_energy MAGMAR_LV31,     2, +1
	ai_energy ELECTABUZZ_LV35, 2, +1
	ai_energy FLYING_PIKACHU,  3, +0
	ai_energy VULPIX,          2, +0
	ai_energy NINETALES_LV35,  2, +1
	ai_energy CHARMANDER,      2, +0
	ai_energy CHARMELEON,      3, +0
	ai_energy CHARIZARD,       4, +1
	ai_energy TAUROS,          3, +0
	db $00

.list_prize
	db ENERGY_RETRIEVAL
	db $00

.store_list_pointers
	store_list_pointer wAICardListAvoidPrize, .list_prize
	store_list_pointer wAICardListArenaPriority, .list_arena
	store_list_pointer wAICardListBenchPriority, .list_bench
	store_list_pointer wAICardListPlayFromHandPriority, .list_bench
	store_list_pointer wAICardListRetreatBonus, .list_retreat
	store_list_pointer wAICardListEnergyBonus, .list_energy
	ret

AIActionTable_RematchFireCharge:
	dw AIMainTurnLogic
	dw AIMainTurnLogic
	dw RematchFireCharge_StartDuel
	dw AIDecideBenchPokemonToSwitchTo
	dw AIDecideBenchPokemonToSwitchTo
	dw AIPickPrizeCards

RematchFireCharge_StartDuel:
	call InitAIDuelVars
	store_list_pointer wAICardListAvoidPrize, RematchFireCharge_PrizeList
	store_list_pointer wAICardListArenaPriority, RematchFireCharge_ArenaList
	store_list_pointer wAICardListBenchPriority, RematchFireCharge_BenchList
	store_list_pointer wAICardListPlayFromHandPriority, RematchFireCharge_BenchList
	store_list_pointer wAICardListRetreatBonus, RematchFireCharge_RetreatList
	store_list_pointer wAICardListEnergyBonus, RematchFireCharge_EnergyList
	call SetUpBossStartingHandAndDeck
	call TrySetUpBossStartingPlayArea
	ret nc
	jp AIPlayInitialBasicCards

RematchFireCharge_ArenaList:
	db MAGMAR_LV31, ELECTABUZZ_LV35, TAUROS, VULPIX, FLYING_PIKACHU, CHARMANDER, $00
RematchFireCharge_BenchList:
	db CHARMANDER, VULPIX, FLYING_PIKACHU, TAUROS, ELECTABUZZ_LV35, MAGMAR_LV31, $00
RematchFireCharge_RetreatList:
	ai_retreat CHARMANDER, +1
	ai_retreat VULPIX, +1
	ai_retreat MAGMAR_LV31, -1
	ai_retreat ELECTABUZZ_LV35, -1
	db $00
RematchFireCharge_EnergyList:
	ai_energy MAGMAR_LV31, 2, +1
	ai_energy ELECTABUZZ_LV35, 2, +1
	ai_energy FLYING_PIKACHU, 3, +0
	ai_energy VULPIX, 2, +0
	ai_energy NINETALES_LV35, 2, +1
	ai_energy CHARMANDER, 2, +0
	ai_energy CHARMELEON, 3, +0
	ai_energy CHARIZARD, 4, +1
	ai_energy TAUROS, 3, +0
	db $00
RematchFireCharge_PrizeList:
	db ENERGY_RETRIEVAL, $00
