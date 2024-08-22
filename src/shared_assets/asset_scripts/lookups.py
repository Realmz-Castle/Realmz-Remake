from enum import Enum

class TargetType(Enum):
    MULTI_OPEN_SPACE = "-1"
    MULTI_TARGET = "0"
    SINGLE_TARGET = "1"
    FIXED_SIZE = "3"
    AREA_X_POWER = "4"
    SELF = "5"
    RAY = "6"
    PARTY = "7"
    SINGLE_OPEN = "8"
    ALL_FRIENDLY = "9"
    ALL_ENEMIES = "10"
    SPECIAL = "11"

sound_lookup = {
    0: 'spell launch 1.wav',
    1: 'spell launch 2.wav',
    2: 'spell launch 3.wav',
    3: 'spell launch 4.wav',
    4: 'spell launch 5.wav',
    5: 'spell launch 6.wav',
    6: 'spell launch 7.wav',
    7: 'spell launch 8.wav',
    9: 'spell launch 9.wav',
    10: 'hit effect 1.wav',
    11: 'hit effect 2.wav',
    12: 'hit effect 3.wav',
    13: 'hit effect 4.wav',
    15: 'lightning.wav',
    18: 'bubbles.wav',
    20: 'pops.wav',
    21: 'boing.wav',
    22: 'claps.wav',
    24: 'bombom.wav',
    25: 'bow.wav',
    26: 'dididup.wav',
    29: 'bloomp.wav',
    30: 'hit bumper.wav',
    31: 'resurrect death.wav',
    34: 'bite.wav',
    33: 'claw.wav',
    35: 'clash.wav',
    37: 'attack hit.wav',
    39: 'club.wav',
    40: 'slimed.wav',
    41: 'sting.wav',
    42: 'big explode.wav',
    44: 'bubble dip.wav',
    45: 'small explode.wav',
    49: 'boink.wav',
    51: 'bwee.wav',
    53: 'metal armor.wav',
    54: 'cloth armor.wav',
    58: 'prout.wav',
    59: 'teleport.wav',
    61: 'dingy ray gun.wav',
    62: 'bloop.wav',
    64: 'force field.wav',
    65: 'slurpy.wav',
    66: 'drippity beep.wav',
    67: 'underwater laser.wav',
    70: 'pinball bumper.wav',
    74: 'nuk.wav',
    75: 'energy blast.wav',
    77: 'swup.wav',
    81: 'bwabble.wav',
    83: 'identify.wav',
    84: 'big splat.wav',
    86: 'electric energize.wav',
    90: 'door slam.wav',
    91: 'spell hit object.wav',
    92: 'smack.wav',
    93: 'jump.wav',
    94: 'chaclunk.wav',
    95: 'spell effect heal.wav',
    98: 'poinkeroo.wav',
    99: 'wind.wav',
}


icon_lookup = {
    0: "",
    1: 'Arrow',
    2: 'Dart',
    3: 'Axe',
    4: 'Web',
    5: 'Target',
    6: 'Fire',
    7: 'Miasma',
    8: 'Cloud',
    9: 'Ice',
    10: 'Spark',
    11: 'Spinny',
    12: 'Slime',
    13: 'Whirl',
    14: 'Ball',
    15: 'Sphere',
    16: 'Thorns'
}

level_spellpoint_lookup = {
    "1": 1,
    "2": 3,
    "3": 6,
    "4": 10,
    "5": 15,
    "6": 21,
    "7": 28
}

TRAITS = {
    1: "t_fleeing.gd",
    2: "t_helpless.gd",
    3: "t_slow.gd",  # tangled , same as  slowi think
    4: "t_cursed.gd",
    5: "t_aura.gd",
    6: "t_dumb.gd",  # stupid , same as  dumb i think
    7: "t_slow.gd",  # slow, same as tangled  i  think
    8: "t_pro_hits.gd",
    9: "t_pro_proj.gd",
    10: "t_poison.gd",  # no duration x5
    11: "t_hp_regen.gd",  # no duration x5
    12: "t_prot_fire.gd",
    13: "t_prot_ice.gd",
    14: "t_prot_elect.gd",
    15: "t_prot_chem.gd",
    16: "t_prot_mental.gd",
    # argument for init is [duration : int, level : int] . Lv1
    17: "t_spell_lvl_prot.gd",
    18: "t_spell_lvl_prot.gd",  # Lv2
    19: "t_spell_lvl_prot.gd",  # Lv3
    20: "t_spell_lvl_prot.gd",  # Lv4
    21: "t_spell_lvl_prot.gd",  # Lv5
    22: "t_strong.gd",
    23: "t_prot_evil.gd",
    24: "t_speedy.gd",
    25: "t_invisible.gd",
    26: "t_animated.gd",
    27: "p_petrified.gd",
    28: "t_blind.gd",
    29: "t_disease.gd",
    30: "t_confused.gd",
    31: "t_reflect_spells.gd",
    32: "t_reflect_melee.gd",
    33: "t_phys_dmg_bonus.gd",
    34: "t_sp_regen.gd",
    35: "t_sp_leak.gd",
    36: "t_sp_absorb.gd",
    37: "t_hindered_atk.gd",
    38: "t_hindered_def.gd",
    39: "t_def_bonus.gd",
    40: "t_dumb.gd"  # silenced, same efefct as tangled i think
}
