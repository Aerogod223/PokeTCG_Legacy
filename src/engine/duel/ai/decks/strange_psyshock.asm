AIActionTable_StrangePsyshock:
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
	db KANGASKHAN
	db MR_MIME
	db MEWTWO_ALT_LV60
	db TAUROS
	db CHANSEY
	db ABRA
	db $00

.list_bench
	db ABRA
	db CHANSEY
	db MEWTWO_ALT_LV60
	db MR_MIME
	db TAUROS
	db KANGASKHAN
	db $00

.list_retreat
	ai_retreat ABRA,       +3
	ai_retreat KANGASKHAN, -1
	ai_retreat TAUROS,     -1
	db $00

.list_energy
	ai_energy ABRA,       1, +0
	ai_energy KADABRA,    3, +0
	ai_energy ALAKAZAM,   2, +1
	ai_energy MR_MIME,    2, +2
	ai_energy TAUROS,     3, +2
	ai_energy CHANSEY,    2, -2
	ai_energy KANGASKHAN, 3, +1
	ai_energy MEWTWO_ALT_LV60,    3, +3
	db $00

.list_prize
	db SCOOP_UP
	db MR_MIME
	db ALAKAZAM
	db SWITCH
	db $00

.store_list_pointers
	store_list_pointer wAICardListAvoidPrize, .list_prize
	store_list_pointer wAICardListArenaPriority, .list_arena
	store_list_pointer wAICardListBenchPriority, .list_bench
	store_list_pointer wAICardListPlayFromHandPriority, .list_bench
	store_list_pointer wAICardListRetreatBonus, .list_retreat
	store_list_pointer wAICardListEnergyBonus, .list_energy
	ret

AIActionTable_RematchStrangePsyshock:
	dw AIMainTurnLogic
	dw AIMainTurnLogic
	dw RematchStrangePsyshock_StartDuel
	dw AIDecideBenchPokemonToSwitchTo
	dw AIDecideBenchPokemonToSwitchTo
	dw AIPickPrizeCards

RematchStrangePsyshock_StartDuel:
	call InitAIDuelVars
	store_list_pointer wAICardListAvoidPrize, RematchStrangePsyshock_PrizeList
	store_list_pointer wAICardListArenaPriority, RematchStrangePsyshock_ArenaList
	store_list_pointer wAICardListBenchPriority, RematchStrangePsyshock_BenchList
	store_list_pointer wAICardListPlayFromHandPriority, RematchStrangePsyshock_BenchList
	store_list_pointer wAICardListRetreatBonus, RematchStrangePsyshock_RetreatList
	store_list_pointer wAICardListEnergyBonus, RematchStrangePsyshock_EnergyList
	call SetUpBossStartingHandAndDeck
	call TrySetUpBossStartingPlayArea
	ret nc
	jp AIPlayInitialBasicCards

RematchStrangePsyshock_ArenaList:
	db KOFFING
	db MR_MIME
	db MEWTWO_LV53
	db MEW_LV8
	db CHANSEY
	db LICKITUNG
	db $00

RematchStrangePsyshock_BenchList:
	db KOFFING
	db MR_MIME
	db MEWTWO_LV53
	db MEW_LV8
	db CHANSEY
	db LICKITUNG
	db $00

RematchStrangePsyshock_RetreatList:
	ai_retreat MURRAY_WEEZING, -3
	ai_retreat LICKITUNG, -2
	db $00

RematchStrangePsyshock_EnergyList:
	ai_energy KOFFING, 2, +0
	ai_energy MURRAY_WEEZING, 3, +2
	ai_energy LICKITUNG, 1, +3
	ai_energy MR_MIME, 2, +2
	ai_energy MEWTWO_LV53, 2, +0
	ai_energy CHANSEY, 2, -2
	ai_energy MEW_LV8, 1, +2
	db $00
	
RematchStrangePsyshock_PrizeList:
	db MURRAY_WEEZING, ENERGY_REMOVAL, KOFFING, SWITCH, $00
