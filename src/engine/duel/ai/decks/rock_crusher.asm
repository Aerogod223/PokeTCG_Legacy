AIActionTable_RockCrusher:
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
	db ONIX
	db TAUROS
	db SNORLAX
	db RHYHORN
	db CUBONE
	db $00

.list_bench
	db RHYHORN
	db SNORLAX
	db TAUROS
	db ONIX
	db LICKITUNG
	db CUBONE
	db $00

.list_retreat
	ai_retreat CUBONE, -1
	db $00

.list_energy
	ai_energy SNORLAX,  3, +0
	ai_energy ONIX,     2, +2
	ai_energy TAUROS,   3, +0
	ai_energy AERODACTYL, 3, -1
	ai_energy LICKITUNG,    2, +1
	ai_energy RHYHORN,     2, +0
	ai_energy CUBONE,      3, -1
	db $00

.list_prize
	db ENERGY_REMOVAL
	db RHYHORN
	db $00

.store_list_pointers
	store_list_pointer wAICardListAvoidPrize, .list_prize
	store_list_pointer wAICardListArenaPriority, .list_arena
	store_list_pointer wAICardListBenchPriority, .list_bench
	store_list_pointer wAICardListPlayFromHandPriority, .list_bench
	store_list_pointer wAICardListRetreatBonus, .list_retreat
	store_list_pointer wAICardListEnergyBonus, .list_energy
	ret
