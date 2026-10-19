AIActionTable_LegendaryArticuno:
	dw AIDoTurn_LegendaryArticuno     ; .do_turn (unused)
	dw AIDoTurn_LegendaryArticuno     ; .do_turn
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
	db LAPRAS
	db CLEFAIRY
	db ARTICUNO_LV35
	db ARTICUNO_LV37
	db $00

.list_bench
	db ARTICUNO_LV35
	db ARTICUNO_LV37
	db CLEFAIRY
	db LICKITUNG
	db LAPRAS
	db $00

.list_retreat
	ai_retreat LICKITUNG,  -3
	ai_retreat LAPRAS, -3
	db $00

.list_energy
	ai_energy CLEFAIRY,      3, +0
	ai_energy CLEFABLE,      2, +1
	ai_energy LAPRAS,        3, +1
	ai_energy ARTICUNO_LV35, 4, +1
	ai_energy ARTICUNO_LV37, 3, +0
	ai_energy LICKITUNG,     2, +2
	db $00

.list_prize
	db GAMBLER
	db ARTICUNO_LV37
	db $00

.store_list_pointers
	store_list_pointer wAICardListAvoidPrize, .list_prize
	store_list_pointer wAICardListArenaPriority, .list_arena
	store_list_pointer wAICardListBenchPriority, .list_bench
	store_list_pointer wAICardListPlayFromHandPriority, .list_bench
	store_list_pointer wAICardListRetreatBonus, .list_retreat
	store_list_pointer wAICardListEnergyBonus, .list_energy
	ret

AIDoTurn_LegendaryArticuno:
; initialize variables
	call InitAITurnVars
	ld a, AI_TRAINER_CARD_PHASE_01
	call AIProcessHandTrainerCards
	call HandleAIAntiMewtwoDeckStrategy
	jr nc, .try_attack
; process Trainer cards
	ld a, AI_TRAINER_CARD_PHASE_02
	call AIProcessHandTrainerCards
	ld a, AI_TRAINER_CARD_PHASE_04
	call AIProcessHandTrainerCards
; play Pokemon from hand
	call AIDecidePlayPokemonCard
	ret c ; return if turn ended
	ld a, AI_TRAINER_CARD_PHASE_05
	call AIProcessHandTrainerCards
	ld a, AI_TRAINER_CARD_PHASE_07
	call AIProcessHandTrainerCards
	ld a, AI_TRAINER_CARD_PHASE_09
	call AIProcessHandTrainerCards
	call AIProcessRetreat
	ld a, AI_TRAINER_CARD_PHASE_10
	call AIProcessHandTrainerCards
	ld a, AI_TRAINER_CARD_PHASE_11
	call AIProcessHandTrainerCards
	ld a, AI_TRAINER_CARD_PHASE_12
	call AIProcessHandTrainerCards
; play Energy card if possible
	ld a, [wAlreadyPlayedEnergy]
	or a
	call z, AIProcessAndTryToPlayEnergy
; play Pokemon from hand again
	call AIDecidePlayPokemonCard
	ret c ; return if turn ended
; process Trainer cards phases 13 and 15
	ld a, AI_TRAINER_CARD_PHASE_13
	call AIProcessHandTrainerCards
	ld a, AI_TRAINER_CARD_PHASE_15
	call AIProcessHandTrainerCards
; if used Professor Oak, process new hand
	ld a, [wPreviousAIFlags]
	and AI_FLAG_USED_PROFESSOR_OAK
	jr z, .try_attack
	ld a, AI_TRAINER_CARD_PHASE_01
	call AIProcessHandTrainerCards
	ld a, AI_TRAINER_CARD_PHASE_02
	call AIProcessHandTrainerCards
	ld a, AI_TRAINER_CARD_PHASE_03
	call AIProcessHandTrainerCards
	ld a, AI_TRAINER_CARD_PHASE_04
	call AIProcessHandTrainerCards
	call AIDecidePlayPokemonCard
	ret c ; return if turn ended
	ld a, AI_TRAINER_CARD_PHASE_05
	call AIProcessHandTrainerCards
	ld a, AI_TRAINER_CARD_PHASE_07
	call AIProcessHandTrainerCards
	ld a, AI_TRAINER_CARD_PHASE_09
	call AIProcessHandTrainerCards
	call AIProcessRetreat
	ld a, AI_TRAINER_CARD_PHASE_10
	call AIProcessHandTrainerCards
	ld a, AI_TRAINER_CARD_PHASE_11
	call AIProcessHandTrainerCards
	ld a, AI_TRAINER_CARD_PHASE_12
	call AIProcessHandTrainerCards
	ld a, [wAlreadyPlayedEnergy]
	or a
	call z, AIProcessAndTryToPlayEnergy
	call AIDecidePlayPokemonCard
	ret c ; return if turn ended
	ld a, AI_TRAINER_CARD_PHASE_13
	call AIProcessHandTrainerCards
.try_attack
; attack if possible, if not,
; finish turn without attacking.
	call AIProcessAndTryToUseAttack
	ret c ; return if turn ended
	ld a, OPPACTION_FINISH_NO_ATTACK
	bank1call AIMakeDecision
	ret
