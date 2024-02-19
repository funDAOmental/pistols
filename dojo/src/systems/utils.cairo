// use debug::PrintTrait;
use core::option::OptionTrait;
use traits::{Into, TryInto};
use starknet::{ContractAddress};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use pistols::models::models::{Duelist, Challenge, Pact, Round, Shot};
use pistols::types::challenge::{ChallengeState, ChallengeStateTrait};
use pistols::types::round::{RoundState, RoundStateTrait};
use pistols::types::blades::{Blades};
use pistols::types::constants::{constants};
use pistols::utils::math::{MathU8, MathU16};

// https://github.com/starkware-libs/cairo/blob/main/corelib/src/pedersen.cairo
extern fn pedersen(a: felt252, b: felt252) -> felt252 implicits(Pedersen) nopanic;

#[inline(always)]
fn zero_address() -> ContractAddress {
    (starknet::contract_address_const::<0x0>())
}

#[inline(always)]
fn duelist_exist(world: IWorldDispatcher, address: ContractAddress) -> bool {
    let duelist: Duelist = get!(world, address, Duelist);
    (duelist.name != 0)
}

#[inline(always)]
fn make_action_hash(salt: u64, action: u16) -> u64 {
    let hash: u256 = pedersen(salt.into(), action.into()).into() & constants::HASH_SALT_MASK;
    (hash.try_into().unwrap())
}

#[inline(always)]
fn make_round_salt(round: Round) -> u64 {
    (round.shot_a.salt ^ round.shot_b.salt)
}

fn make_pact_pair(duelist_a: ContractAddress, duelist_b: ContractAddress) -> u128 {
    let a: felt252 = duelist_a.into();
    let b: felt252 = duelist_b.into();
    let aa: u256 = a.into();
    let bb: u256 = b.into();
    (aa.low ^ bb.low)
}

fn set_challenge(world: IWorldDispatcher, challenge: Challenge) {
    set!(world, (challenge));

    let state: ChallengeState = challenge.state.try_into().unwrap();

    // Set pact between Duelists to avoid duplicated challenges
    let pair: u128 = make_pact_pair(challenge.duelist_a, challenge.duelist_b);
    let pact_duel_id: u128 = if (state.finished()) { 0 } else { challenge.duel_id };
    set!(world, Pact {
        pair,
        duel_id: pact_duel_id,
    });

    // Start Round
    if (state == ChallengeState::InProgress) {
        // Round 1 starts with full health
        let mut health_a: u8 = constants::FULL_HEALTH;
        let mut health_b: u8 = constants::FULL_HEALTH;
        // Round 2+ need to copy previous Round's healths
        if (challenge.round_number > 1) {
            let prev_round: Round = get!(world, (challenge.duel_id, challenge.round_number - 1), Round);
            health_a = prev_round.shot_a.health;
            health_b = prev_round.shot_b.health;
        }

        set!(world, (
            Round {
                duel_id: challenge.duel_id,
                round_number: challenge.round_number,
                state: RoundState::Commit.into(),
                shot_a: Shot {
                    hash: 0,
                    salt: 0,
                    action: 0,
                    dice_crit: 0,
                    dice_hit: 0,
                    damage: 0,
                    block: 0,
                    health: health_a,
                },
                shot_b: Shot {
                    hash: 0,
                    salt: 0,
                    action: 0,
                    dice_crit: 0,
                    dice_hit: 0,
                    damage: 0,
                    block: 0,
                    health: health_b,
                },
            }
        ));
    }

    // Update totals
    if (state == ChallengeState::Draw || state == ChallengeState::Resolved) {
        let mut duelist_a: Duelist = get!(world, challenge.duelist_a, Duelist);
        let mut duelist_b: Duelist = get!(world, challenge.duelist_b, Duelist);
        duelist_a.total_duels += 1;
        duelist_b.total_duels += 1;
        if (state == ChallengeState::Draw) {
            duelist_a.total_draws += 1;
            duelist_b.total_draws += 1;
        } else if (challenge.winner == 1) {
            duelist_a.total_wins += 1;
            duelist_b.total_losses += 1;
        } else if (challenge.winner == 2) {
            duelist_a.total_losses += 1;
            duelist_b.total_wins += 1;
        } else {
            // should never get here!
        }

        // compute honour from 1st round steps
        let first_round: Round = get!(world, (challenge.duel_id, 1), Round);
        duelist_a.total_honour += first_round.shot_a.action.into();
        duelist_b.total_honour += first_round.shot_b.action.into();
        // average honour has an extra decimal, eg: 100 = 10.0
        duelist_a.honour = ((duelist_a.total_honour * 10) / duelist_a.total_duels.into()).try_into().unwrap();
        duelist_b.honour = ((duelist_b.total_honour * 10) / duelist_b.total_duels.into()).try_into().unwrap();
        
        // save Duelists
        set!(world, (duelist_a, duelist_b));
    }
}


// bonus = (duelist.honour - 90), capped at duelis.total_duels
fn calc_hit_bonus(world: IWorldDispatcher, duelist_address: ContractAddress) -> u8 {
    let duelist: Duelist = get!(world, duelist_address, Duelist);
    let bonus: u8 = MathU8::sub(duelist.honour, 90);
    (MathU16::min(bonus.into(), duelist.total_duels).try_into().unwrap())
}
fn calc_hit_penalty(world: IWorldDispatcher, health: u8) -> u8 {
    ((constants::FULL_HEALTH - health) * constants::HIT_PENALTY_PER_DAMAGE)
}
fn apply_chance_bonus_penalty(chance: u8, bonus: u8, penalty: u8) -> u8 {
    let mut result: u8 = MathU8::sub(chance + bonus, penalty);
    (MathU8::clamp(result, chance / 2, 100))
}

//------------------------
// Pistols chances
//
fn get_pistols_hit_chance(world: IWorldDispatcher, duelist_address: ContractAddress, health: u8, steps: u16) -> u8 {
    let bonus: u8 = calc_hit_bonus(world, duelist_address);
    let penalty: u8 = calc_hit_penalty(world, health);
    let chance: u8 = MathU8::map(steps.try_into().unwrap(), 1, 10, constants::PISTOLS_HIT_CHANCE_AT_STEP_1, constants::PISTOLS_HIT_CHANCE_AT_STEP_10);
    (apply_chance_bonus_penalty(chance, bonus, penalty))
}
fn get_pistols_kill_chance(world: IWorldDispatcher, duelist_address: ContractAddress, health: u8, steps: u16) -> u8 {
    let chance: u8 = MathU8::map(steps.try_into().unwrap(), 1, 10, constants::PISTOLS_KILL_CHANCE_AT_STEP_1, constants::PISTOLS_KILL_CHANCE_AT_STEP_10);
    (chance)
}


//------------------------
// Blades chances
//
// bonus = ...
fn get_blades_hit_chance(world: IWorldDispatcher, duelist_address: ContractAddress, health: u8, blade: Blades) -> u8 {
    // let bonus: u8 = calc_hit_bonus(world, duelist_address);
    let penalty: u8 = calc_hit_penalty(world, health);
    (apply_chance_bonus_penalty(constants::BLADES_HIT_CHANCE, 0, penalty))
}
fn get_blades_kill_chance(world: IWorldDispatcher, duelist_address: ContractAddress, health: u8, blade: Blades) -> u8 {
    let bonus: u8 = calc_hit_bonus(world, duelist_address);
    (apply_chance_bonus_penalty(constants::BLADES_KILL_CHANCE, bonus, 0))
}


// throw a dice and return the resulting face
// faces: the number of faces on the dice (ex: 6, or 100%)
// returns a number between 1 and faces
fn throw_dice(seed: felt252, salt: felt252, faces: u128) -> u128 {
    let hash: felt252 = pedersen(salt, seed);
    let double: u256 = hash.into();
    ((double.low % faces) + 1)
}

// throw a dice and return a positive result
// faces: the number of faces on the dice (ex: 6, or 100%)
// limit: how many faces gives a positive result?
// edge case: limit <= 1, always negative
// edge case: limit == faces, always positive
fn check_dice(seed: felt252, salt: felt252, faces: u128, limit: u128) -> bool {
    (throw_dice(seed, salt, faces) <= limit)
}







//------------------------------------------------------
// Unit tests
//
#[cfg(test)]
mod tests {
    use core::traits::{Into, TryInto};
    use debug::PrintTrait;
    use starknet::{ContractAddress};

    use pistols::systems::{utils};
    use pistols::types::challenge::{ChallengeState, ChallengeStateTrait};
    use pistols::types::constants::{constants};
    use pistols::utils::math::{MathU8};

    #[test]
    #[available_gas(1_000_000)]
    fn test_pact_pair() {
        let a: ContractAddress = starknet::contract_address_const::<0x269c58e5fa1e7f6fe3756f1de88ecdfab7d03ba67e79ba0365b4ef1e81155be>();
        let b: ContractAddress = starknet::contract_address_const::<0xb3ff441a68610b30fd5e2abbf3a1548eb6ba6f3559f2862bf2dc757e5828ca>();
        let p_a = utils::make_pact_pair(a, b);
        let p_b = utils::make_pact_pair(b, a);
        assert(p_a == p_b, 'test_pact_pair');
    }

    #[test]
    #[available_gas(1_000_000_000)]
    fn test_check_dice_average() {
        // lower limit
        let mut counter: u8 = 0;
        let mut n: felt252 = 0;
        loop {
            if (n == 100) { break; }
            let seed: felt252 = 'seed_1' + n;
            if (utils::check_dice(seed, 'salt_1', 100, 25)) {
                counter += 1;
            }
            n += 1;
        };
        assert(counter > 10 && counter < 40, 'dices_25');
        // higher limit
        let mut counter: u8 = 0;
        let mut n: felt252 = 0;
        loop {
            if (n == 100) { break; }
            let seed: felt252 = 'seed_2' + n;
            if (utils::check_dice(seed, 'salt_2', 100, 75)) {
                counter += 1;
            }
            n += 1;
        };
        assert(counter > 60 && counter < 90, 'dices_75');
    }

    #[test]
    #[available_gas(1_000_000_000)]
    fn test_check_dice_edge() {
        let mut n: felt252 = 0;
        loop {
            if (n == 100) { break; }
            let seed: felt252 = 'seed' + n;
            let bottom: bool = utils::check_dice(seed, 'salt', 10, 0);
            assert(bottom == false, 'bottom');
            let upper: bool = utils::check_dice(seed, 'salt', 10, 10);
            assert(upper == true, 'bottom');
            n += 1;
        };
    }

    #[test]
    #[available_gas(100_000_000)]
    fn test_hit_kill_maps() {
        assert(MathU8::map(1, 1, 10, constants::PISTOLS_HIT_CHANCE_AT_STEP_1, constants::PISTOLS_HIT_CHANCE_AT_STEP_10) == constants::PISTOLS_HIT_CHANCE_AT_STEP_1, 'PISTOLS_HIT_CHANCE_AT_STEP_1');
        assert(MathU8::map(10, 1, 10, constants::PISTOLS_HIT_CHANCE_AT_STEP_1, constants::PISTOLS_HIT_CHANCE_AT_STEP_10) == constants::PISTOLS_HIT_CHANCE_AT_STEP_10, 'PISTOLS_HIT_CHANCE_AT_STEP_10');
        assert(MathU8::map(1, 1, 10, constants::PISTOLS_KILL_CHANCE_AT_STEP_1, constants::PISTOLS_KILL_CHANCE_AT_STEP_10) == constants::PISTOLS_KILL_CHANCE_AT_STEP_1, 'PISTOLS_KILL_CHANCE_AT_STEP_1');
        assert(MathU8::map(10, 1, 10, constants::PISTOLS_KILL_CHANCE_AT_STEP_1, constants::PISTOLS_KILL_CHANCE_AT_STEP_10) == constants::PISTOLS_KILL_CHANCE_AT_STEP_10, 'PISTOLS_KILL_CHANCE_AT_STEP_10');
    }
}
