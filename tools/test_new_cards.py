import os
import re
import struct
import sys
from pathlib import Path

sys.path.insert(0, str(Path(os.environ.get("TEMP", "/tmp")) / "poketcg-pyboy"))
from pyboy import PyBoy


ROOT = Path(__file__).resolve().parents[1]
ROM = ROOT / "poketcg_v2.gbc"
SYMBOLS = {}
for entry in ROM.with_suffix(".sym").read_text().splitlines():
    match = re.fullmatch(r"([0-9a-fA-F]+):([0-9a-fA-F]+) (\S+)", entry)
    if match is None:
        continue
    bank, offset, name = match.groups()
    SYMBOLS[name] = (int(bank, 16), int(offset, 16))
ROM_DATA = ROM.read_bytes()


def address(name):
    return SYMBOLS[name][1]


def rom_offset(name):
    bank, offset = SYMBOLS[name]
    return bank * 0x4000 + (offset & 0x3FFF)


def card_id(name):
    table = rom_offset("CardPointers")
    pointer = address(name)
    for index in range(1, 248):
        if struct.unpack_from("<H", ROM_DATA, table + index * 2)[0] == pointer:
            return index
    raise AssertionError(f"Card is not registered: {name}")


def card(name):
    offset = rom_offset(name)
    return ROM_DATA[offset:offset + 65]


class RoutineRunner:
    def __init__(self):
        self.emulator = PyBoy(str(ROM), window="null", sound_emulated=False)
        self.emulator.set_emulation_speed(0)
        self.emulator.memory[0xFF50] = 1
        self.emulator.memory[0xFF40] = 0x91
        self.result = None
        self.emulator.memory[0, 0x100:0x107] = [0xCD, 0, 0, 0, 0xC3, 0x04, 0x01]
        self.emulator.hook_register(0, 0x103, self.on_return, None)
        self.player = address("wPlayerDuelVariables")
        self.opponent = address("wOpponentDuelVariables")
        self.reset()

    def on_return(self, context):
        if self.result is None:
            registers = self.emulator.register_file
            self.result = {name: getattr(registers, name) for name in
                           ("A", "B", "C", "D", "E", "F", "HL", "SP")}

    def reset(self):
        memory = self.emulator.memory
        for side in (self.player, self.opponent):
            memory[side:side + 256] = [0] * 256
            memory[side + 0xBB:side + 0xC2] = [255] * 7
        memory[address("wPlayerDeck"):address("wPlayerDeck") + 60] = [1] * 60
        memory[address("wOpponentDeck"):address("wOpponentDeck") + 60] = [1] * 60
        memory[address("hWhoseTurn")] = self.player >> 8

    def place(self, name, index=0, slot=0, opponent=False):
        memory = self.emulator.memory
        side = self.opponent if opponent else self.player
        deck = address("wOpponentDeck" if opponent else "wPlayerDeck")
        memory[deck + index] = card_id(name)
        memory[side + index] = 0x10 + slot
        memory[side + 0xBB + slot] = index
        memory[side + 0xC8 + slot] = card(name)[8]
        memory[side + 0xEF] += 1

    def call(self, name, **inputs):
        emulator = self.emulator
        bank, target = SYMBOLS[name]
        emulator.memory[0, 0x101:0x103] = [target & 255, target >> 8]
        emulator.memory[0x2000] = bank or 1
        emulator.memory[address("hBankROM")] = bank or 1
        emulator.memory[0xFFFF] = 0
        emulator.memory[0xFF0F] = 0
        registers = emulator.register_file
        registers.SP = 0xDFF0
        for register in ("A", "B", "C", "D", "E", "F", "HL"):
            setattr(registers, register, 0)
        for register, value in inputs.items():
            setattr(registers, register, value)
        registers.PC = 0x100
        self.result = None
        for frame in range(8):
            emulator.tick(1, render=False, sound=False)
            if self.result is not None:
                break
        assert self.result is not None, f"{name} did not return"
        assert self.result["SP"] == 0xDFF0, f"{name} unbalanced stack: {self.result}"
        return self.result

    def loaded(self):
        base = address("wLoadedCard1")
        return bytes(self.emulator.memory[base:base + 65])

    def close(self):
        self.emulator.stop(save=False)


def test_records():
    ditto = card("DittoLv20Card")
    electrode = card("ElectrodeLv40Card")
    assert ditto[0] == 6 and ditto[8] == 50
    assert ditto[6] >> 4 == 2, "Ditto Lv. 16 must be in the Mystery set"
    assert ditto[50:53] == bytes([1, 8, 4])
    assert ditto[57] == 16
    assert electrode[0] == 2 and electrode[8] == 80 and electrode[9] == 1
    assert electrode[6] >> 4 == 0, "Electrode Lv. 45 must be in the Colosseum set"
    assert electrode[31:35] == bytes([0, 0x30, 0, 0])
    assert electrode[41] == 50
    assert electrode[50:53] == bytes([1, 8, 0])
    assert electrode[57] == 45
    assert card("DittoCard")[7] != ditto[7]


def test_transform(runner):
    runner.reset()
    runner.place("DittoLv20Card")
    runner.place("CharizardCard", opponent=True)
    runner.call("LoadCardDataToBuffer1_FromDeckIndex", A=0)
    assert runner.loaded()[8] == card("CharizardCard")[8]
    assert runner.emulator.memory[runner.player + 0xC8] == 120
    runner.emulator.memory[runner.player + 0xC8] = 90
    runner.emulator.memory[address("wOpponentDeck")] = card_id("BlastoiseCard")
    runner.call("LoadCardDataToBuffer1_FromDeckIndex", A=0)
    assert runner.loaded()[8] == 100
    assert runner.emulator.memory[runner.player + 0xC8] == 70
    for status in (1, 2, 3):
        runner.emulator.memory[runner.player + 0xF0] = status
        runner.call("LoadCardDataToBuffer1_FromDeckIndex", A=0)
        assert runner.loaded()[7] == card_id("DittoLv20Card")
        assert runner.emulator.memory[runner.player + 0xC8] == 20
        runner.emulator.memory[runner.player + 0xF0] = 0
        runner.call("LoadCardDataToBuffer1_FromDeckIndex", A=0)
        assert runner.emulator.memory[runner.player + 0xC8] == 70
    runner.emulator.memory[runner.player + 0xF0] = 0x80
    runner.call("LoadCardDataToBuffer1_FromDeckIndex", A=0)
    assert runner.loaded()[8] == 100
    runner.place("MukCard", index=1, slot=1, opponent=True)
    runner.call("LoadCardDataToBuffer1_FromDeckIndex", A=0)
    assert runner.loaded()[7] == card_id("DittoLv20Card")
    assert runner.emulator.memory[address("wPlayerDeck")] == card_id("DittoLv20Card")


def test_transform_energy(runner):
    runner.reset()
    runner.place("DittoLv20Card")
    runner.place("ZachEeveeCard", opponent=True)
    for index in (1, 2):
        runner.emulator.memory[runner.player + index] = 0x10
    runner.call("GetPlayAreaCardAttachedEnergies", E=0)
    assert runner.emulator.memory[address("wTotalAttachedEnergies")] == 2
    result = runner.call("_CheckIfEnoughEnergiesToAttack", D=0, E=1)
    assert result["F"] & 0x10, "Two units must not pay a three-type cost"
    runner.emulator.memory[runner.player + 3] = 0x10
    result = runner.call("GetPlayAreaCardAttachedEnergies", E=0, B=37, C=42)
    assert (result["B"], result["C"]) == (37, 42)
    assert result["A"] == 3
    result = runner.call("_CheckIfEnoughEnergiesToAttack", D=0, E=1)
    assert not result["F"] & 0x10, "Three arbitrary units must pay the mixed cost"


def test_buzzap_energy(runner):
    for energy_type in range(7):
        runner.reset()
        runner.place("BulbasaurCard")
        runner.emulator.memory[address("wPlayerDeck") + 1] = 0xF8 + energy_type
        runner.emulator.memory[runner.player + 1] = 0x10
        result = runner.call("GetCardTypeFromDeckIndex_SaveDE", A=1)
        assert result["A"] == 8 + energy_type
        result = runner.call("GetPlayAreaCardAttachedEnergies", E=0)
        assert result["A"] == 2, (energy_type, result)
        assert runner.emulator.memory[address("wAttachedEnergies") + energy_type] == 2
        runner.call("LoadCardDataToBuffer1_FromDeckIndex", A=1)
        assert runner.loaded()[0] == 8 + energy_type
        runner.call("PutCardInDiscardPile", A=1)
        assert runner.emulator.memory[address("wPlayerDeck") + 1] == card_id("ElectrodeLv40Card")
        result = runner.call("GetCardTypeFromDeckIndex_SaveDE", A=1)
        assert result["A"] == 2


def test_transform_rules(runner):
    runner.reset()
    runner.place("DittoLv20Card")
    runner.place("MetapodCard", opponent=True)
    runner.emulator.memory[address("wPlayerDeck") + 1] = card_id("ButterfreeCard")
    result = runner.call("CheckIfCanEvolveInto", D=1, E=0)
    assert result["F"] & 0x10, "Transformed Ditto must not evolve"
    runner.emulator.memory[runner.player + 2] = 0x10
    runner.emulator.memory[address("wPlayerDeck") + 2] = card_id("FireEnergyCard")
    result = runner.call("CreateListOfFireEnergyAttachedToActive")
    assert result["A"] == 1
    assert runner.emulator.memory[address("wDuelTempList")] == 2
    runner.emulator.memory[runner.player + 0xF0] = 2
    result = runner.call("CreateListOfFireEnergyAttachedToActive")
    assert result["A"] == 1
    runner.emulator.memory[runner.player + 0xF0] = 0
    runner.emulator.memory[address("wPlayerDeck") + 2] = card_id("WaterEnergyCard")
    result = runner.call("CreateListOfFireEnergyAttachedToActive")
    assert result["A"] == 1, "Transform must allow off-type Energy discard"
    runner.emulator.memory[runner.player + 0xF0] = 3
    result = runner.call("CreateListOfFireEnergyAttachedToActive")
    assert result["A"] == 0, "Disabled Transform must not allow off-type discard"
    runner.reset()
    runner.place("DittoLv20Card")
    runner.place("DittoLv20Card", opponent=True)
    runner.call("LoadCardDataToBuffer1_FromDeckIndex", A=0)
    assert runner.loaded()[8] == 50
    assert runner.loaded()[7] == card_id("DittoLv20Card")
    runner.reset()
    runner.place("BulbasaurCard")
    runner.place("DittoLv20Card", index=1, slot=1)
    runner.place("CharizardCard", opponent=True)
    runner.call("LoadCardDataToBuffer1_FromDeckIndex", A=1)
    assert runner.loaded()[8] == 50, "Bench Ditto must not Transform"


def test_balance_records():
    hit_points = {
        "Ekans": 50, "Arbok": 90, "Nidoqueen": 100, "Nidoking": 110,
        "Venomoth": 80, "Victreebel": 110, "ZapdosLv40": 110,
        "Poliwhirl": 70, "Tentacruel": 60, "Cloyster": 60, "Omastar": 120,
        "Dugtrio": 60, "Primeape": 70, "Machoke": 90, "Graveler": 80,
        "Golem": 120, "Cubone": 50, "MarowakLv26": 70, "Hitmonlee": 60,
        "Kabutops": 110, "Raticate": 70,
    }
    for name, value in hit_points.items():
        assert card(name + "Card")[8] == value, (name, "HP")
    for name in ("Nidoqueen", "Geodude", "Graveler", "Golem", "Rhydon"):
        assert card(name + "Card")[51] == 0x10, (name, "Water weakness")
    assert card("ButterfreeCard")[51] == 0x20
    for name in ("Diglett", "Dugtrio", "Lickitung", "Chansey", "Kangaskhan", "Tauros", "Porygon"):
        assert card(name + "Card")[52] == 0, (name, "resistance")
    for name, value in {"Tentacruel": 0, "Dugtrio": 1, "Rhydon": 4}.items():
        assert card(name + "Card")[50] == value, (name, "retreat")
    attacks = {
        "Butterfree": [(1, {1: 2, 6: 1}, 50)],
        "Golbat": [(0, {6: 2}, 20)],
        "Weezing": [(1, {1: 2}, 60)],
        "MoltresLv35": [(0, {0: 1}, 0), (1, {0: 2, 6: 2}, 100)],
        "ElectrodeLv35": [(1, {2: 2}, 10)],
        "ZapdosLv64": [(0, {2: 3}, 60)],
        "Poliwrath": [(1, {3: 1, 6: 2}, 30)],
        "Tentacruel": [(0, {3: 1}, 20), (1, {3: 1, 6: 1}, 20)],
        "Kingler": [(1, {3: 4}, 70)],
        "Seadra": [(1, {3: 2}, 20)],
        "Starmie": [(1, {3: 2}, 20)],
        "Gyarados": [(1, {3: 4}, 50)],
        "Omastar": [(1, {6: 3}, 40)],
        "Dugtrio": [(1, {4: 2, 6: 2}, 80)],
        "Machoke": [(0, {4: 2, 6: 1}, 70), (1, {4: 4}, 80)],
        "Machamp": [(1, {4: 2}, 40)],
        "Golem": [(1, {4: 2, 6: 2}, 120)],
        "MarowakLv32": [(0, {4: 1}, 20)],
        "Kabutops": [(1, {4: 2, 6: 1}, 40)],
        "Alakazam": [(1, {5: 2}, 30)],
        "PidgeotLv38": [(0, {6: 2}, 0), (1, {6: 3}, 40)],
        "PidgeotLv40": [(0, {6: 2}, 40), (1, {6: 3}, 40)],
        "Raticate": [(1, {6: 2}, 0)],
    }
    for name, entries in attacks.items():
        data = card(name + "Card")
        for attack, costs, damage in entries:
            start = 12 + attack * 19
            packed = [0] * 4
            for energy_type, amount in costs.items():
                packed[energy_type // 2] |= amount << (4 if energy_type % 2 == 0 else 0)
            assert data[start:start + 4] == bytes(packed), (name, attack, "cost")
            assert data[start + 10] == damage, (name, attack, "damage")
    pointers = {
        "Weezing": (0, "InflictPoisonEffectCommands"),
        "Persian": (1, "ReduceBy20EffectCommands"),
        "PidgeotLv38": (0, "RandomEnemy40DamageEffectCommands"),
        "Golem": (1, "Selfdestruct120And20EffectCommands"),
        "MoltresLv35": (1, "FlipFor100EffectCommands"),
    }
    for name, (attack, effect) in pointers.items():
        assert struct.unpack_from("<H", card(name + "Card"), 24 + attack * 19)[0] == address(effect)


def test_balance_effects(runner):
    emulator = runner.emulator
    memory = emulator.memory
    saved_code = []

    def override(name, machine_code):
        bank, offset = SYMBOLS[name]
        saved_code.append((bank, offset, memory[bank, offset:offset + len(machine_code)]))
        memory[bank, offset:offset + len(machine_code)] = machine_code

    def prepare_hand(size):
        runner.reset()
        memory[runner.player + 0x7E:runner.player + 0x7E + 60] = list(range(60))
        if size:
            memory[runner.player + 0x42:runner.player + 0x42 + size] = list(range(size))
            memory[runner.player:runner.player + size] = [1] * size
        memory[runner.player + 0xEE] = size
        memory[runner.player + 0xBA] = size
        memory[address("hTempCardIndex_ff9f")] = 0

    try:
        for name in (
            "DrawWideTextBox_WaitForInput", "DrawWideTextBox_PrintText",
            "WaitForWideTextBoxInput", "DisplayDrawNCardsScreen",
            "PlayDeckShuffleAnimation", "ExchangeRNG", "ShuffleDeck",
            "DisplayCardDetailScreen", "DrawDuelHUDs",
            "InitAndDrawCardListScreenLayout_WithSelectCheckMenu",
            "SetCardListInfoBoxText", "SetCardListHeaderText",
        ):
            override(name, [0xC9])
        list_address = address("wDuelTempList")
        selected_address = address("hTempCardIndex_ff98")
        override("DisplayCardList", [0xFA, list_address & 255, list_address >> 8,
                                     0xE0, selected_address & 255, 0xB7, 0xC9])
        for count in (2, 3):
            prepare_hand(5)
            result = runner.call(f"HandlePlayerSelection{count}HandCards")
            assert not result["F"] & 0x10
            choices = memory[address("hTempList"):address("hTempList") + count]
            assert len(set(choices)) == count
            assert all(index in range(1, 5) for index in choices)
            assert memory[runner.player + 0xEE] == 5
        for count in (0, 1, 2, 3, 4, 5):
            prepare_hand(count)
            result = runner.call("MaintenanceCheck")
            assert bool(result["F"] & 0x10) == (count < 4)
        prepare_hand(5)
        memory[address("hTempList"):address("hTempList") + 3] = [1, 2, 3]
        runner.call("Maintenance_ReturnToDeckAndDrawEffect")
        assert memory[runner.player + 0xEE] == 4
        assert memory[runner.player + 0xBA] == 4
        assert len(set(memory[runner.player + 0x42:runner.player + 0x46])) == 4
        for available in (1, 2, 5):
            prepare_hand(60 - available)
            runner.call("FindTwoBasicEnergy")
            choices = memory[address("hTempList"):address("hTempList") + 2]
            selected = [index for index in choices if index != 255]
            assert len(set(selected)) == min(2, available)
            assert all(index in range(60 - available, 60) for index in selected)
            runner.call("EnergySearch_AddToHandEffect")
            assert memory[runner.player + 0xEE] == 60 - available + min(2, available)
            assert memory[runner.player + 0xBA] == 60 - available + min(2, available)
        prepare_hand(1)
        memory[runner.player + 0xF1] = 0x80
        memory[address("hTemp_ffa0")] = 4
        runner.call("EnergySearch_AddToHandEffect")
        assert memory[runner.player + 0xEE] == 3
        assert memory[runner.player + 4] == 1
        hand = memory[runner.player + 0x42:runner.player + 0x45]
        assert len(set(hand)) == 3
        override("TossCoin", [0xAF, 0xC9])
        prepare_hand(4)
        runner.call("GamblerEffect")
        assert memory[runner.player + 0xEE] == 2
        assert memory[runner.player + 0xED] == 1
        override("TossCoin", [0x3E, 1, 0xC9])
        prepare_hand(4)
        runner.call("GamblerEffect")
        assert memory[runner.player + 0xEE] == 8
        for maximum in (30, 50, 90, 120):
            runner.reset()
            memory[runner.player + 0xC9] = maximum
            runner.call("Revive_SetHPAfterDamage", A=1)
            assert memory[runner.player + 0xC9] == maximum - 20
        for damage in (0, 10, 20, 40):
            runner.reset()
            runner.place("VileplumeCard")
            memory[runner.player + 0xC8] = 100 - damage
            memory[address("hPlayAreaEffectTarget")] = 0
            runner.call("Heal20DamageFromSelectedPokemon")
            assert memory[runner.player + 0xC8] == min(100, 120 - damage)
        runner.reset()
        runner.place("MachokeCard")
        memory[runner.player + 0xC8] = 60
        runner.call("CopyAttackDataAndDamage_FromDeckIndex", D=0, E=0)
        runner.call("KarateChop_DamageSubtractionEffect")
        assert memory[address("wDamage")] == 40
        runner.reset()
        runner.place("MagikarpCard")
        runner.place("MachampCard", opponent=True)
        memory[address("wTempTurnDuelistCardID")] = card_id("MagikarpCard")
        memory[address("wTempNonTurnDuelistCardID")] = card_id("MachampCard")
        memory[address("wDealtDamage")] = 10
        memory[address("wLoadedAttackCategory")] = 0
        memory[address("wDefendingWasForcedToSwitch")] = 0
        runner.call("HandleStrikesBack_AgainstNormalAttack")
        assert memory[runner.player + 0xC8] == 10
        override("ReorderCardsOnTopOfDeck.start", [0xC9])
        for requested in (5, 7):
            for available in (1, 3, 8):
                prepare_hand(60 - available)
                runner.call("ReorderCardsOnTopOfDeck", C=requested)
                count = min(requested, available)
                assert memory[address("wNumberOfCardsToOrder")] == count + 1
                assert memory[address("wDuelTempList") + count] == 255
        prepare_hand(1)
        runner.call("HandlePokedexPlayerSelection")
        assert memory[address("wNumberOfCardsToOrder")] == 8
        runner.call("HandleProphecyScreen")
        assert memory[address("wNumberOfCardsToOrder")] == 6
    finally:
        for bank, offset, original in reversed(saved_code):
            memory[bank, offset:offset + len(original)] = original


if __name__ == "__main__":
    test_records()
    test_balance_records()
    runner = RoutineRunner()
    try:
        test_transform(runner)
        test_transform_energy(runner)
        test_buzzap_energy(runner)
        test_transform_rules(runner)
        test_balance_effects(runner)
    finally:
        runner.close()
    print("PASS: card balance, Trainer effects, Transform, and Buzzap regression tests")