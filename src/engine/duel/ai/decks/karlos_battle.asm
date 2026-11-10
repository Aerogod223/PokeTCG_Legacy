AIActionTable_KarlosBattle:
	dw AIMainTurnLogic
	dw AIMainTurnLogic
	dw .start_duel
	dw AIDecideBenchPokemonToSwitchTo
	dw AIDecideBenchPokemonToSwitchTo
	dw AIPickPrizeCards

.start_duel
	call InitAIDuelVars
	store_list_pointer wAICardListAvoidPrize, .list_prize
	store_list_pointer wAICardListArenaPriority, .list_arena
	store_list_pointer wAICardListBenchPriority, .list_bench
	store_list_pointer wAICardListPlayFromHandPriority, .list_bench
	store_list_pointer wAICardListRetreatBonus, .list_retreat
	store_list_pointer wAICardListEnergyBonus, .list_energy
	call SetUpBossStartingHandAndDeck
	call TrySetUpBossStartingPlayArea
	ret nc
	jp AIPlayInitialBasicCards

.list_arena
	db HITMONCHAN, LAPRAS, SURFING_PIKACHU_LV13, POLIWAG, $00
.list_bench
	db POLIWAG, HITMONCHAN, LAPRAS, SURFING_PIKACHU_LV13, $00
.list_retreat
	ai_retreat KARLOS_POLIWRATH, +3
	ai_retreat HITMONCHAN, +1
	ai_retreat LAPRAS, +1
	ai_retreat POLIWAG, -2
	db $00
; Extra Energy enables Waterfall's bonuses and a spare Strange Spiral discard.
.list_energy
	ai_energy KARLOS_POLIWRATH, 4, +3
	ai_energy POLIWAG, 2, +1
	ai_energy POLIWHIRL, 3, +1
	ai_energy HITMONCHAN, 3, +2
	ai_energy LAPRAS, 3, +1
	ai_energy SURFING_PIKACHU_LV13, 2, +0
	db $00
.list_prize
	db KARLOS_POLIWRATH, POKEMON_BREEDER, $00
