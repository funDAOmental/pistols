use starknet::ContractAddress;
use pistols::types::challenge::{ChallengeState};

//
// Players need to register as a Duelist to play
#[derive(Model, Copy, Drop, Serde)]
struct Duelist {
    #[key]
    address: ContractAddress,
    //-----------------------
    name: felt252,
    profile_pic: u8,
    total_duels: u16,
    total_wins: u16,
    total_losses: u16,
    total_draws: u16,
    total_honour: u32,  // sum of al duels Honour
    honour: u8,         // +1 decimal, eg: 100 = 10.0
    timestamp: u64,     // Unix time, 1st registered
} // f + 176 bits

//
// Challenge lifecycle
#[derive(Model, Copy, Drop, Serde)]
struct Challenge {
    #[key]
    duel_id: u128,
    //-------------------------
    duelist_a: ContractAddress, // Challenger
    duelist_b: ContractAddress, // Challenged
    message: felt252,           // message to challenged
    // progress and results
    state: u8,                  // actually a ChallengeState
    round_number: u8,           // current or final
    winner: u8,                 // 0:draw, 1:duelist_a, 2:duelist_b
    // timestamps in unix epoch
    timestamp_start: u64,       // Unix time, started
    timestamp_end: u64,         // Unix time, ended
} // f + f + f + 152 bits

//
// Current challenge between two Duelists
#[derive(Model, Copy, Drop, Serde)]
struct Pact {
    #[key]
    pair: u128,     // xor'd duelists u256(address).low
    //------------
    duel_id: u128,  // current Challenge, or 0x0
} // 128 bits

//
// The shot of each player on a Round
#[derive(Copy, Drop, Serde, Introspect)]
struct Shot {
    // player input
    hash: u64,          // hashed action (salt + action)
    salt: u64,          // the player's secret salt
    action: u16,        // the player's chosen action(s) (paces, weapon, ...)
    // shot results
    chance_crit: u8,    // computed chances (1..100) - kill / double damage
    chance_hit: u8,     // computed chances (1..100) - hit / normal damage
    dice_crit: u8,      // dice roll result (1..100) - kill / double damage
    dice_hit: u8,       // dice roll result (1..100) - hit / normal damage
    damage: u8,         // amount of health taken
    block: u8,          // amount of damage blocked
    // player state
    health: u8,         // final health
    honour: u8,         // honour granted
    // more results -- TODO: move up
    win: u8,            // wins the round
} // 208 bits

//
// Each duel round
#[derive(Model, Copy, Drop, Serde)]
struct Round {
    #[key]
    duel_id: u128,
    #[key]
    round_number: u8,
    //---------------
    state: u8,      // actually a RoundState
    shot_a: Shot,   // duelist_a shot
    shot_b: Shot,   // duelist_b shot
} // (8 + 208 + 208) = 424 bits ~ 2 felts (max 504)




//-------------------------------------
// Model initializers
//
mod init {
    use pistols::models::{models};

    fn Shot() -> models::Shot {
        (models::Shot {
            hash: 0,
            salt: 0,
            action: 0,
            chance_crit: 0,
            chance_hit: 0,
            dice_crit: 0,
            dice_hit: 0,
            damage: 0,
            block: 0,
            health: 0,
            honour: 0,
            win: 0,
        })
    }

}