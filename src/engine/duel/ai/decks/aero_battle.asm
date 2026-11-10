AIActionTable_AeroBattle:
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

; Magmar opens cheaply; Snorlax develops behind it with Buzzap support.
.list_arena
	db MAGMAR_LV31, AERO_SNORLAX, GROWLITHE, VOLTORB, $00
.list_bench
	db AERO_SNORLAX, VOLTORB, GROWLITHE, MAGMAR_LV31, $00
.list_retreat
	ai_retreat AERO_SNORLAX, +3
	ai_retreat ARCANINE_LV45, +1
	ai_retreat MAGMAR_LV31, +1
	ai_retreat VOLTORB, -3
	ai_retreat ELECTRODE_LV40, -4
	db $00
.list_energy
	ai_energy AERO_SNORLAX, 4, +3
	ai_energy MAGMAR_LV31, 2, +1
	ai_energy GROWLITHE, 2, +0
	ai_energy ARCANINE_LV45, 4, +2
	ai_energy VOLTORB, 0, -3
	ai_energy ELECTRODE_LV40, 0, -3
	db $00
.list_prize
	db AERO_SNORLAX, ELECTRODE_LV40, $00
