AIActionTable_DrMasonBattle:
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
	store_list_pointer wAICardListPlayFromHandPriority, .list_play_hand
	store_list_pointer wAICardListRetreatBonus, .list_retreat
	store_list_pointer wAICardListEnergyBonus, .list_energy
	call SetUpBossStartingHandAndDeck
	call TrySetUpBossStartingPlayArea
	ret nc
	jp AIPlayInitialBasicCards

; Jigglypuff buys time while the Bench develops into Wigglytuff and Pidgeot.
.list_arena
	db JIGGLYPUFF_LV14, CLEFAIRY, PIDGEY, $00
.list_bench
	db PIDGEY, JIGGLYPUFF_LV14, CLEFAIRY, $00
.list_play_hand
	db JIGGLYPUFF_LV14, PIDGEY, CLEFAIRY, $00
.list_retreat
	ai_retreat WIGGLYTUFF, +3
	ai_retreat PIDGEOT_LV40, +2
	ai_retreat CLEFABLE, +2
	ai_retreat PIDGEY, -2
	ai_retreat CLEFAIRY, -1
	db $00
.list_energy
	ai_energy JIGGLYPUFF_LV14, 2, +1
	ai_energy WIGGLYTUFF, 3, +3
	ai_energy PIDGEY, 1, -1
	ai_energy PIDGEOTTO, 2, +0
	ai_energy PIDGEOT_LV40, 3, +2
	ai_energy CLEFAIRY, 1, -1
	ai_energy CLEFABLE, 1, +2
	db $00
.list_prize
	db POKEMON_BREEDER, WIGGLYTUFF, $00

; Fill the Bench for Do the Wave instead of stopping at the usual four Pokemon.
AIEncourageMasonBench:
	ld a, [wOpponentDeckID]
	cp DR_MASON_BATTLE_DECK_ID
	ret nz
	ld a, WIGGLYTUFF
	ld b, PLAY_AREA_ARENA
	call LookForCardIDInPlayArea_Bank5
	ret nc
	ld a, 70
	jp AIEncourage
