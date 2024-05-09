
mod constants {
    // number of rounds per duel
    const ROUND_COUNT: u8 = 3;
    
    // initial health of a player on a duel
    const FULL_HEALTH: u8 = 3;
    // damage taken
    const DOUBLE_DAMAGE: u8 = 2;
    const SINGLE_DAMAGE: u8 = 1;

    // Hit penalty per damage taken
    const HIT_PENALTY_PER_DAMAGE: u8 = 10;

    // archetype ranges (Honour)
    const ARCH_VILLAIN_START: u8 = 0;   // min honour
    const ARCH_TRICKSTER_START: u8 = 30;
    const ARCH_LORD_START: u8 = 80;
    const ARCH_HALFWAY: u8 = 50;        // half honour
    const ARCH_MAX: u8 = 100;           // max honour
    
    // Bonus values
    const BONUS_MIN: u8 = 10;
    const BONUS_MAX: u8 = 100;
    
    const HASH_SALT_MASK: u256 = 0xffffffffffffffff; // 64 bits
    // const HASH_SALT_MASK: u256 = 0x1fffffffffffff;   // 53 bits (Number.MAX_SAFE_INTEGER, 9007199254740991)
}

mod chances {
    const NEVER: u8 = 0;
    const ALWAYS: u8 = 100;
    
    // Pistols chances (percentage) at X paces
    const PISTOLS_KILL_AT_STEP_1: u8 = 5;
    const PISTOLS_KILL_AT_STEP_10: u8 = 20;
    const PISTOLS_HIT_AT_STEP_1: u8 = 100;
    const PISTOLS_HIT_AT_STEP_10: u8 = 20;
    const PISTOLS_GLANCE_AT_STEP_1: u8 = 20;
    const PISTOLS_GLANCE_AT_STEP_10: u8 = 15;

    // Blades chances (percentage)
    const BLADES_KILL: u8 = 15;
    const BLADES_HIT: u8 = 75;
    const BLADES_GLANCE: u8 = 0;
}
