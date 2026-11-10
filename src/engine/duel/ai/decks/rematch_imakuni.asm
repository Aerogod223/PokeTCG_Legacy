AIActionTable_RematchImakuni:
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

; Mewtwo recycles Imakuni? for Powerful Confusion; Slowbro stays in support.
.list_arena
	db IMAKUNIS_MEWTWO, MEW_LV15, DITTO_LV20
	db SLOWPOKE_LV18, SLOWPOKE_LV9, PORYGON, $00
.list_bench
	db SLOWPOKE_LV9, SLOWPOKE_LV18, IMAKUNIS_MEWTWO
	db MEW_LV15, DITTO_LV20, PORYGON, $00
.list_retreat
	ai_retreat IMAKUNIS_MEWTWO, +3
	ai_retreat MEW_LV15, +2
	ai_retreat DITTO_LV20, +1
	ai_retreat SLOWBRO, -4
	ai_retreat SLOWPOKE_LV9, -2
	ai_retreat SLOWPOKE_LV18, -2
	ai_retreat PORYGON, -3
	db $00
.list_energy
	ai_energy IMAKUNIS_MEWTWO, 4, +3
	ai_energy MEW_LV15, 2, +2
	ai_energy DITTO_LV20, 4, +1
	ai_energy SLOWPOKE_LV9, 1, -2
	ai_energy SLOWPOKE_LV18, 1, -2
	ai_energy SLOWBRO, 0, -4
	ai_energy PORYGON, 1, -3
	db $00
.list_prize
	db IMAKUNIS_MEWTWO, IMAKUNI_CARD, $00
