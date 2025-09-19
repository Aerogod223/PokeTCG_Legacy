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
	ai_retreat SQUIRTLE,  -3
	ai_retreat WARTORTLE, -2
	ai_retreat MAGIKARP,  -3
	db $00

.list_energy
	ai_energy SQUIRTLE,        2, +0
	ai_energy WARTORTLE,       3, +1
	ai_energy BLASTOISE,       5, +0
	ai_energy ARTICUNO_LV35,   3, +1
	ai_energy MAGIKARP,        2, -2
	ai_energy GYARADOS,        4, +0
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
