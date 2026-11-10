AIActionTable_ZachBattle:
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

; Eevee can start charging for free; the Bench supplies single-type attackers.
.list_arena
	db ZACH_EEVEE, ELECTABUZZ_LV35, MAGMAR_LV31, LAPRAS
	db SURFING_PIKACHU_LV13, FLYING_PIKACHU, $00
.list_bench
	db ELECTABUZZ_LV35, MAGMAR_LV31, LAPRAS, ZACH_EEVEE
	db SURFING_PIKACHU_LV13, FLYING_PIKACHU, $00
.list_retreat
	ai_retreat ELECTABUZZ_LV35, +2
	ai_retreat MAGMAR_LV31, +2
	ai_retreat LAPRAS, +1
	ai_retreat ZACH_EEVEE, +1
	db $00
.list_energy
	ai_energy ZACH_EEVEE, 3, +3
	ai_energy ELECTABUZZ_LV35, 2, +2
	ai_energy MAGMAR_LV31, 2, +2
	ai_energy LAPRAS, 3, +1
	ai_energy SURFING_PIKACHU_LV13, 2, +0
	ai_energy FLYING_PIKACHU, 3, +0
	db $00
.list_prize
	db ZACH_EEVEE, ENERGY_SEARCH, $00

AIHandleUnstableGene:
	ld e, PLAY_AREA_ARENA
	call GetPlayAreaCardAttachedEnergies
	ld a, [wAttachedEnergies + FIRE]
	or a
	jr z, .find_missing_energy
	ld a, [wAttachedEnergies + WATER]
	or a
	jr z, .find_missing_energy
	ld a, [wAttachedEnergies + LIGHTNING]
	or a
	jr nz, .no_energy_needed
.find_missing_energy
	farcall AIFindZachEeveeEnergy
	ldh a, [hTemp_ffa0]
	cp $ff
	jr z, .no_energy_needed
	; A matching Energy is useful only if it supplies a missing attack type.
	call GetCardIDFromDeckIndex
	ld a, e
	cp FIRE_ENERGY
	jr z, .check_fire
	cp WATER_ENERGY
	jr z, .check_water
	ld a, [wAttachedEnergies + LIGHTNING]
	jr .check_missing
.check_fire
	ld a, [wAttachedEnergies + FIRE]
	jr .check_missing
.check_water
	ld a, [wAttachedEnergies + WATER]
.check_missing
	or a
	jr nz, .no_energy_needed
	ld a, $84
	ret
.no_energy_needed
	xor a
	ret
