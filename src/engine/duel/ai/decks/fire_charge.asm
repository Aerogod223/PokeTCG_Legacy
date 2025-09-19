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
	ai_retreat CHARMANDER,     -1
	ai_retreat VULPIX,         -1
	db $00

.list_energy
	ai_energy MAGMAR_LV31,     2, +2
	ai_energy ELECTABUZZ_LV35, 2, +2
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
