AIActionTable_ZappingSelfdestruct:
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
	db LICKITUNG
	db ELECTABUZZ_LV35
	db VOLTORB
	db ELECTABUZZ_LV20
	db FLYING_PIKACHU
	db ZAPDOS_LV40
	db ZAPDOS_LV64
	db DITTO
	db $00

.list_bench
	db LICKITUNG
	db ELECTABUZZ_LV35
	db VOLTORB
	db ELECTABUZZ_LV20
	db FLYING_PIKACHU
	db ZAPDOS_LV40
	db ZAPDOS_LV64
	db DITTO
	db $00

.list_retreat
	ai_retreat VOLTORB, -1
	ai_retreat ELECTABUZZ_LV35, -1
	ai_retreat LICKITUNG, -1
	db $00

.list_energy
	ai_energy LICKITUNG,       2, +1
	ai_energy ELECTABUZZ_LV20, 2, +0
	ai_energy VOLTORB,         3, +1
	ai_energy ELECTRODE_LV35,  2, +1
	ai_energy ELECTABUZZ_LV35, 2, +2
	ai_energy FLYING_PIKACHU,  2, +0
	ai_energy ZAPDOS_LV40,     3, +0
	ai_energy ZAPDOS_LV64,     4, +1
	ai_energy DITTO,           3, -1
	db $00

.list_prize
	db LICKITUNG
	db $00

.store_list_pointers
	store_list_pointer wAICardListAvoidPrize, .list_prize
	store_list_pointer wAICardListArenaPriority, .list_arena
	store_list_pointer wAICardListBenchPriority, .list_bench
	store_list_pointer wAICardListPlayFromHandPriority, .list_bench
	store_list_pointer wAICardListRetreatBonus, .list_retreat
	store_list_pointer wAICardListEnergyBonus, .list_energy
	ret
