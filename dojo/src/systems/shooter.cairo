
mod shooter {
    use core::option::OptionTrait;
    use core::traits::TryInto;
    use starknet::{ContractAddress, get_block_timestamp};
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

    use pistols::systems::{utils};
    use pistols::models::models::{Challenge, Round, Shot};
    use pistols::types::constants::{constants};
    use pistols::types::challenge::{ChallengeState};
    use pistols::types::round::{RoundState};
    use pistols::types::steps::{Steps};
    use pistols::types::blades::{Blades, BLADES};
    use pistols::utils::math::{MathU8};

    fn _assert_challenge(world: IWorldDispatcher, caller: ContractAddress, duel_id: u128, round_number: u8) -> (Challenge, u8) {
        let challenge: Challenge = get!(world, duel_id, Challenge);

        // Assert Duelist is in the challenge
        let duelist_number: u8 = if (challenge.duelist_a == caller) { 1 } else if (challenge.duelist_b == caller) { 2 } else { 0 };
        assert(duelist_number == 1 || duelist_number == 2, 'Not your Challenge!');

        // Correct Challenge state
        assert(challenge.state == ChallengeState::InProgress.into(), 'Challenge is not In Progress');
        assert(challenge.round_number == round_number, 'Bad Round number');
        
        (challenge, duelist_number)
    }


    //-----------------------------------
    // Commit
    //
    fn commit_action(world: IWorldDispatcher, duel_id: u128, round_number: u8, hash: felt252) {
        let caller: ContractAddress = starknet::get_caller_address();

        // Assert correct Challenge
        let (challenge, duelist_number) = _assert_challenge(world, caller, duel_id, round_number);

        // Assert correct Round
        let mut round: Round = get!(world, (duel_id, round_number), Round);
        assert(round.state == RoundState::Commit.into(), 'Round not in Commit');

        // Validate action hash

        // Store hash
        if (duelist_number == 1) {
            assert(round.shot_a.hash == 0, 'Already committed');
            round.shot_a.hash = hash;
        } else if (duelist_number == 2) {
            assert(round.shot_b.hash == 0, 'Already committed');
            round.shot_b.hash = hash;
        }

        // Finished commit
        if (round.shot_a.hash != 0 && round.shot_b.hash != 0) {
            round.state = RoundState::Reveal.into();
        }

        set!(world, (round));
    }

    //-----------------------------------
    // Reveal
    //
    fn reveal_action(world: IWorldDispatcher, duel_id: u128, round_number: u8, salt: u64, mut action: u8) {
        let caller: ContractAddress = starknet::get_caller_address();

        // Assert correct Challenge
        let (mut challenge, duelist_number) = _assert_challenge(world, caller, duel_id, round_number);

        // Assert correct Round
        let mut round: Round = get!(world, (duel_id, round_number), Round);
        assert(round.state == RoundState::Reveal.into(), 'Round not in Reveal');

        // Validate action hash
        let hash: felt252 = utils::make_action_hash(salt, action);

        // validate action
        // if invalid, set as 0 (idle, will skip round)
        action = validated_action(round_number, action);

        // Store action
        if (duelist_number == 1) {
            assert(round.shot_a.action == 0, 'Already revealed');
            assert(round.shot_a.hash == hash, 'Action does not match hash');
            round.shot_a.salt = salt;
            round.shot_a.action = action;
        } else if (duelist_number == 2) {
            assert(round.shot_b.action == 0, 'Already revealed');
            assert(round.shot_b.hash == hash, 'Action does not match hash');
            round.shot_b.salt = salt;
            round.shot_b.action = action;
        }

        // Finishes round if both actions are revealed
        if (round.shot_a.salt > 0 && round.shot_b.salt > 0) {
            process_round(world, ref challenge, ref round);
            // update Round first, Challenge may need it
            set!(world, (round));
            // update Challenge
            utils::set_challenge(world, challenge);
        } else {
            // update Round only
            set!(world, (round));
        }
    }

    // Validates a action and returns it
    // Pistols: if invalid, clamps between 1 and 10
    // Blades: if invalid, returns Blades::Idle
    fn validated_action(round_number: u8, action: u8) -> u8 {
        if (round_number == 1) {
            return MathU8::clamp(action, 1, 10); // valid or not, clamp in steps
        } else if (round_number == 2) {
            let blade: Option<Blades> = action.try_into();
            if (blade != Option::None) {
                return (action); // valid action
            }
        }
        (0) // invalid action
    }

    //---------------------------------------
    // Decide who wins a round, or go to next
    //
    fn process_round(world: IWorldDispatcher, ref challenge: Challenge, ref round: Round) {
        // get damage for each player
        if (round.round_number == 1) {
            pistols_shootout(world, challenge, ref round);
        } else {
            blades_clash(world, challenge, ref round);
        }

        // decide results
        if (round.shot_a.health == 0 && round.shot_b.health == 0) {
            // both dead!
            challenge.state = ChallengeState::Draw.into();
            challenge.timestamp_end = get_block_timestamp();
        } else if (round.shot_a.health == 0) {
            // A is dead!
            challenge.state = ChallengeState::Resolved.into();
            challenge.winner = 2;
            challenge.timestamp_end = get_block_timestamp();
        } else if (round.shot_b.health == 0) {
            // B is dead!
            challenge.state = ChallengeState::Resolved.into();
            challenge.winner = 1;
            challenge.timestamp_end = get_block_timestamp();
        } else {
            // both alive!
            if (challenge.round_number == constants::ROUND_COUNT) {
                // end in a Draw
                challenge.state = ChallengeState::Draw.into();
                challenge.timestamp_end = get_block_timestamp();
            } else {
                // next round
                challenge.round_number += 1;
            }
        }

        // Finish round
        round.state = RoundState::Finished.into();
    }

    //-----------------------------------
    // Pistols duel
    //
    fn pistols_shootout(world: IWorldDispatcher, challenge: Challenge, ref round: Round) {
        let steps_a: u8 = round.shot_a.action;
        let steps_b: u8 = round.shot_b.action;

        if (steps_a == steps_b) {
            // both shoot together
            shoot_apply_damage(world, 'shoot_a', challenge.duelist_a, round, ref round.shot_a, ref round.shot_b);
            shoot_apply_damage(world, 'shoot_b', challenge.duelist_b, round, ref round.shot_b, ref round.shot_a);
        } else if (steps_a < steps_b) {
            // A shoots first
            shoot_apply_damage(world, 'shoot_a', challenge.duelist_a, round, ref round.shot_a, ref round.shot_b);
            // if B not dead, shoot
            if (round.shot_b.health > 0) {
                shoot_apply_damage(world, 'shoot_b', challenge.duelist_b, round, ref round.shot_b, ref round.shot_a);
            }
        } else {
            // B shoots first
            shoot_apply_damage(world, 'shoot_b', challenge.duelist_b, round, ref round.shot_b, ref round.shot_a);
            // if A not dead, shoot
            if (round.shot_a.health > 0) {
                shoot_apply_damage(world, 'shoot_a', challenge.duelist_a, round, ref round.shot_a, ref round.shot_b);
            }
        }
    }

    fn shoot_apply_damage(world: IWorldDispatcher, seed: felt252, duelist: ContractAddress, round: Round, ref attack: Shot, ref defense: Shot) {
        let steps: u8 = attack.action;
        // dice 1: miss or hit + damage
        // ex: chance 60%: 1..30 = double, 31..60 = single, 61..100 = miss
        attack.dice_hit = throw_dice(seed, round, 100);
        let hit_chance: u8 = utils::get_pistols_hit_chance(world, duelist, attack.health, steps);
        if (attack.dice_hit <= hit_chance) {
            // dice 1: execution!
            attack.dice_crit = throw_dice(seed * 2, round, 100);
            let kill_chance: u8 = utils::get_pistols_kill_chance(world, duelist, attack.health, steps);
            if (attack.dice_crit <= kill_chance) {
                defense.damage = constants::FULL_HEALTH;
            } else if (attack.dice_hit <= hit_chance/2) {
                defense.damage = constants::DOUBLE_DAMAGE;
            } else {
                defense.damage = constants::SINGLE_DAMAGE;
            }
            apply_damage(ref defense);
        }
    }

    fn apply_damage(ref shot: Shot) {
        shot.health = MathU8::sub(shot.health, MathU8::sub(shot.damage, shot.block));
    }


    //-----------------------------------
    // Blades duel
    //
    // Heavy - Execute with 3 damage or inclict 2 damage
    // Light - hits 1 damage, early
    // Block - blocks 1 damage
    //
    fn blades_clash(world: IWorldDispatcher, challenge: Challenge, ref round: Round) {

        thow_blades_dices(world, 'clash_a', challenge.duelist_a, round, ref round.shot_a, ref round.shot_b);
        thow_blades_dices(world, 'clash_b', challenge.duelist_b, round, ref round.shot_b, ref round.shot_a);

        // Execution executes first (Heavy)
        if (round.shot_a.damage == constants::FULL_HEALTH || round.shot_b.damage == constants::FULL_HEALTH) {
            if (round.shot_a.damage == constants::FULL_HEALTH) {
                round.shot_a.block = 0; // execution overrides block
                apply_damage(ref round.shot_a);
            }
            if (round.shot_b.damage == constants::FULL_HEALTH) {
                round.shot_b.block = 0; // execution overrides block
                apply_damage(ref round.shot_b);
            }
            return ();
        }

        let blade_a: Blades = round.shot_a.action.try_into().unwrap();
        let blade_b: Blades = round.shot_b.action.try_into().unwrap();

        // Light strikes before Heavy
        if (blade_a == Blades::Light && blade_b == Blades::Heavy) {
            light_vs_heavy_apply_damage(ref round.shot_a, ref round.shot_b)
        } else if (blade_b == Blades::Light && blade_a == Blades::Heavy) {
            light_vs_heavy_apply_damage(ref round.shot_b, ref round.shot_a)
        } else {
            // clash at same time
            apply_damage(ref round.shot_a);
            apply_damage(ref round.shot_b);
        }
    }

    fn light_vs_heavy_apply_damage(ref attack: Shot, ref defense: Shot) {
        // attack!
        apply_damage(ref defense);
        if (defense.health == 0) {
            // defender is dead! no damage to attacker
            attack.damage = 0;
        } else {
            // defender is alive! strike attacker...
            apply_damage(ref attack);
        }
    }

    fn thow_blades_dices(world: IWorldDispatcher, seed: felt252, duelist: ContractAddress, round: Round, ref attack: Shot, ref defense: Shot) {
        let blade: Blades = attack.action.try_into().unwrap();
        if (blade != Blades::Idle) {
            // dice 1: execution or double damage/block
            attack.dice_crit = throw_dice(seed, round, 100);
            let kill_chance: u8 = utils::get_blades_kill_chance(world, duelist, attack.health, blade);
            if (attack.dice_hit <= kill_chance) {
                if (blade == Blades::Heavy) {
                    defense.damage = constants::FULL_HEALTH;
                } else if (blade == Blades::Light) {
                    defense.damage = constants::DOUBLE_DAMAGE;
                } else if (blade == Blades::Block) {
                    attack.block = constants::DOUBLE_DAMAGE;
                }
            } else {
                // dice 2: miss or normal damage
                attack.dice_hit = throw_dice(seed * 2, round, 100);
                let hit_chance: u8 = utils::get_blades_hit_chance(world, duelist, attack.health, blade);
                if (attack.dice_hit <= hit_chance) {
                    if (blade == Blades::Heavy) {
                        defense.damage = constants::DOUBLE_DAMAGE;
                    } else if (blade == Blades::Light) {
                        defense.damage = constants::SINGLE_DAMAGE;
                    } else if (blade == Blades::Block) {
                        attack.block = constants::SINGLE_DAMAGE;
                    }
                }
            }
        }
    }


    //-----------------------------------
    // Randomizer
    //
    fn throw_dice(seed: felt252, round: Round, faces: u128) -> u8 {
        let salt: u64 = utils::make_round_salt(round);
        (utils::throw_dice(seed, salt.into(), faces).try_into().unwrap())
    }
    fn check_dice(seed: felt252, round: Round, faces: u128, limit: u128) -> bool {
        let salt: u64 = utils::make_round_salt(round);
        (utils::check_dice(seed, salt.into(), faces, limit))
    }

}






//------------------------------------------------------
// Unit tests
//
#[cfg(test)]
mod tests {
    use debug::PrintTrait;
    use core::traits::{Into, TryInto};

    use pistols::systems::shooter::{shooter};
    use pistols::models::models::{Shot};
    use pistols::types::blades::{Blades, BLADES};

    #[test]
    #[available_gas(1_000_000)]
    fn test_validated_action() {
        assert(shooter::validated_action(1, 0) == 1, '1_0');
        assert(shooter::validated_action(1, 1) == 1, '1_1');
        assert(shooter::validated_action(1, 10) == 10, '1_10');
        assert(shooter::validated_action(1, 11) == 10, '1_11');
        assert(shooter::validated_action(2, BLADES::IDLE) == BLADES::IDLE, '2_IDLE');
        assert(shooter::validated_action(2, BLADES::HEAVY) == BLADES::HEAVY, '2_HEAVY');
        assert(shooter::validated_action(2, BLADES::LIGHT) == BLADES::LIGHT, '2_LIGHT');
        assert(shooter::validated_action(2, BLADES::BLOCK) == BLADES::BLOCK, '2_BLOCK');
        assert(shooter::validated_action(2, 10) == BLADES::IDLE, '2_10');
        assert(shooter::validated_action(3, BLADES::HEAVY) == BLADES::IDLE, '3_HEAVY');
    }

    #[test]
    #[available_gas(1_000_000)]
    fn test_apply_damage() {
        let mut shot = Shot {
            hash: 0,
            salt: 0,
            action: 0,
            dice_crit: 0,
            dice_hit: 0,
            damage: 0,
            block: 0,
            health: 0,
        };
        // damages
        shot.health = 3;
        shot.damage = 1;
        shooter::apply_damage(ref shot);
        assert(shot.health == 2, '3-1');
        shooter::apply_damage(ref shot);
        assert(shot.health == 1, '2-1');
        shooter::apply_damage(ref shot);
        assert(shot.health == 0, '1-1');
        shooter::apply_damage(ref shot);
        assert(shot.health == 0, '0-1');
        // overflow
        shot.health = 1;
        shot.damage = 3;
        shooter::apply_damage(ref shot);
        assert(shot.health == 0, '1-3');
        // blocks
        shot.health = 1;
        shot.damage = 0;
        shot.block = 1;
        shooter::apply_damage(ref shot);
        assert(shot.health == 1, '1-0+1');
        shot.health = 1;
        shot.damage = 1;
        shot.block = 1;
        shooter::apply_damage(ref shot);
        assert(shot.health == 1, '1-1+1');
        shot.health = 1;
        shot.damage = 2;
        shot.block = 1;
        shooter::apply_damage(ref shot);
        assert(shot.health == 0, '1-2+1');
        shot.health = 2;
        shot.damage = 4;
        shot.block = 1;
        shooter::apply_damage(ref shot);
        assert(shot.health == 0, '2-4+1');
        shot.health = 1;
        shot.damage = 2;
        shot.block = 5;
        shooter::apply_damage(ref shot);
        assert(shot.health == 1, '1-2+5');
    }
}
