AIActionTable_FirstStrike:
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
	db HITMONCHAN
	db ELECTABUZZ_LV35
	db SCYTHER
	db MACHOP
	db FARFETCHD
	db $00

.list_bench
	db MACHOP
	db ELECTABUZZ_LV35
	db HITMONCHAN
	db SCYTHER
	db FARFETCHD
	db $00

.list_retreat
	ai_retreat HITMONCHAN,  -1
	db $00

.list_energy
	ai_energy MACHOP,     1, +0
	ai_energy SCYTHER,    3, +0
	ai_energy ELECTABUZZ_LV35,    3, +2
	ai_energy HITMONCHAN, 3, +2
	ai_energy FARFETCHD,  3, +0
	db $00

.list_prize
	db ELECTABUZZ_LV35
	db HITMONCHAN
	db $00

.store_list_pointers
	store_list_pointer wAICardListAvoidPrize, .list_prize
	store_list_pointer wAICardListArenaPriority, .list_arena
	store_list_pointer wAICardListBenchPriority, .list_bench
	store_list_pointer wAICardListPlayFromHandPriority, .list_bench
	store_list_pointer wAICardListRetreatBonus, .list_retreat
	store_list_pointer wAICardListEnergyBonus, .list_energy
	ret
