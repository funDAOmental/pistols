#[cfg(test)]
mod tests {
    use debug::PrintTrait;
    use core::traits::Into;
    use starknet::{ContractAddress};

    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

    use pistols::models::models::{Duelist, Round};
    use pistols::types::challenge::{ChallengeState, ChallengeStateTrait};
    use pistols::systems::utils::{zero_address};
    use pistols::utils::timestamp::{timestamp};
    use pistols::tests::utils::{utils};

    const PLAYER_NAME: felt252 = 'Sensei';
    const OTHER_NAME: felt252 = 'Senpai';
    const PASS_CODE_1: felt252 = 'Ohayo';
    const MESSAGE_1: felt252 = 'Challenge yaa for a duuel!!';

    #[test]
    #[available_gas(1_000_000_000)]
    #[should_panic(expected:('Challenger not registered','ENTRYPOINT_FAILED'))]
    fn test_invalid_challenger() {
        let (world, system, owner, other) = utils::setup_world();
        let duel_id: u128 = utils::execute_create_challenge(system, owner, other, PASS_CODE_1, MESSAGE_1, 0);
    }

    #[test]
    #[available_gas(1_000_000_000)]
    #[should_panic(expected:('Missing challenged address','ENTRYPOINT_FAILED'))]
    // #[should_panic(expected:('Challenge a player or pass_code','ENTRYPOINT_FAILED'))]
    fn test_invalid_code() {
        let (world, system, owner, other) = utils::setup_world();
        utils::execute_register_duelist(system, owner, PLAYER_NAME);
        let challenged_1 = zero_address();
        let duel_id: u128 = utils::execute_create_challenge(system, owner, challenged_1, 0, MESSAGE_1, 0);
    }

    #[test]
    #[available_gas(1_000_000_000)]
    #[should_panic(expected:('Invalid expire_seconds','ENTRYPOINT_FAILED'))]
    fn test_invalid_expire() {
        let (world, system, owner, other) = utils::setup_world();
        utils::execute_register_duelist(system, owner, PLAYER_NAME);
        let expire_seconds: u64 = 24 * 60 * 60 - 1;
        let duel_id: u128 = utils::execute_create_challenge(system, owner, other, PASS_CODE_1, MESSAGE_1, expire_seconds);
    }

    #[test]
    #[available_gas(1_000_000_000)]
    fn test_challenge_address() {
        let (world, system, owner, other) = utils::setup_world();
        utils::execute_register_duelist(system, owner, PLAYER_NAME);

        let duel_id: u128 = utils::execute_create_challenge(system, owner, other, 0, MESSAGE_1, 0);
        let ch = utils::get_Challenge(world, duel_id);
        assert(ch.state == ChallengeState::Awaiting, 'state');
        assert(ch.pass_code == 0, 'pass_code');
        assert(ch.duelist_a == owner, 'challenged');
        assert(ch.duelist_b == other, 'challenged');
        assert(ch.message == MESSAGE_1, 'message');
        assert(ch.timestamp > 0, 'timestamp');
        assert(ch.timestamp_expire == 0, 'timestamp_expire');
        assert(ch.timestamp_start == 0, 'timestamp_start');
        assert(ch.timestamp_end == 0, 'timestamp_end');
    }

    #[test]
    #[available_gas(1_000_000_000)]
    fn test_challenge_pass_code() {
        let (world, system, owner, other) = utils::setup_world();
        utils::execute_register_duelist(system, owner, PLAYER_NAME);

        let challenged = zero_address();
        let duel_id: u128 = utils::execute_create_challenge(system, owner, challenged, PASS_CODE_1, MESSAGE_1, 0);
        let ch = utils::get_Challenge(world, duel_id);
        assert(ch.state == ChallengeState::Awaiting, 'state');
        assert(ch.pass_code == PASS_CODE_1, 'pass_code');
        assert(ch.duelist_a == owner, 'challenged');
        assert(ch.duelist_b == challenged, 'challenged');
        assert(ch.message == MESSAGE_1, 'message');
        assert(ch.timestamp > 0, 'timestamp');
        assert(ch.timestamp_expire == 0, 'timestamp_expire');
        assert(ch.timestamp_start == 0, 'timestamp_start');
        assert(ch.timestamp_end == 0, 'timestamp_end');
    }

    #[test]
    #[available_gas(1_000_000_000)]
    fn test_challenge_expire_ok() {
        let (world, system, owner, other) = utils::setup_world();
        utils::execute_register_duelist(system, owner, PLAYER_NAME);

        let expire_seconds: u64 = 24 * 60 * 60;
        let duel_id: u128 = utils::execute_create_challenge(system, owner, other, PASS_CODE_1, MESSAGE_1, expire_seconds);
        let ch = utils::get_Challenge(world, duel_id);
        assert(ch.timestamp > 0, 'timestamp');
        assert(ch.timestamp_expire == ch.timestamp + expire_seconds, 'timestamp_expire');
        assert(ch.timestamp_start == 0, 'timestamp_start');
        assert(ch.timestamp_end == 0, 'timestamp_end');
    }


    //-----------------------------------------
    // REPLY
    //

    #[test]
    #[available_gas(1_000_000_000)]
    #[should_panic(expected:('Challenge do not exist','ENTRYPOINT_FAILED'))]
    fn test_challenge_reply_invalid() {
        let (world, system, owner, other) = utils::setup_world();
        utils::execute_register_duelist(system, owner, PLAYER_NAME);

        let expire_seconds: u64 = timestamp::from_days(2);
        let duel_id: u128 = utils::execute_create_challenge(system, owner, other, PASS_CODE_1, MESSAGE_1, expire_seconds);
        utils::elapse_timestamp(timestamp::from_days(1));
        utils::execute_reply_challenge(system, owner, duel_id + 1, true);
    }

    #[test]
    #[available_gas(1_000_000_000)]
    #[should_panic(expected:('Challenge is not Awaiting','ENTRYPOINT_FAILED'))]
    fn test_challenge_reply_twice() {
        let (world, system, owner, other) = utils::setup_world();
        utils::execute_register_duelist(system, owner, PLAYER_NAME);

        let expire_seconds: u64 = timestamp::from_days(2);
        let duel_id: u128 = utils::execute_create_challenge(system, owner, other, PASS_CODE_1, MESSAGE_1, expire_seconds);
        let ch = utils::get_Challenge(world, duel_id);
        let (block_number, timestamp) = utils::elapse_timestamp(timestamp::from_days(3));
        let new_state: ChallengeState = utils::execute_reply_challenge(system, other, duel_id, false);
        assert(new_state != ChallengeState::Awaiting, '!awaiting');
        
        utils::execute_reply_challenge(system, other, duel_id, true);
    }

    #[test]
    #[available_gas(1_000_000_000)]
    fn test_challenge_reply_expired() {
        let (world, system, owner, other) = utils::setup_world();
        utils::execute_register_duelist(system, owner, PLAYER_NAME);

        let expire_seconds: u64 = timestamp::from_days(1);
        let duel_id: u128 = utils::execute_create_challenge(system, owner, other, PASS_CODE_1, MESSAGE_1, expire_seconds);
        let ch = utils::get_Challenge(world, duel_id);

        let (block_number, timestamp) = utils::elapse_timestamp(timestamp::from_date(1, 0, 1));
        let new_state: ChallengeState = utils::execute_reply_challenge(system, owner, duel_id, true);
        assert(new_state == ChallengeState::Expired, 'expired');

        let ch = utils::get_Challenge(world, duel_id);
        assert(ch.state == new_state, 'state');
        assert(ch.round == 0, 'round');
        assert(ch.winner == zero_address(), 'winner');
        assert(ch.timestamp_start == 0, 'timestamp_start');
        assert(ch.timestamp_end == timestamp, 'timestamp_end');
    }

    #[test]
    #[available_gas(1_000_000_000)]
    #[should_panic(expected:('Cannot accept own challenge','ENTRYPOINT_FAILED'))]
    fn test_challenge_owner_accept() {
        let (world, system, owner, other) = utils::setup_world();
        utils::execute_register_duelist(system, owner, PLAYER_NAME);

        let expire_seconds: u64 = timestamp::from_days(2);
        let duel_id: u128 = utils::execute_create_challenge(system, owner, other, PASS_CODE_1, MESSAGE_1, expire_seconds);
        let ch = utils::get_Challenge(world, duel_id);

        utils::elapse_timestamp(timestamp::from_days(1));
        utils::execute_reply_challenge(system, owner, duel_id, true);
    }

    #[test]
    #[available_gas(1_000_000_000)]
    fn test_challenge_owner_cancel() {
        let (world, system, owner, other) = utils::setup_world();
        utils::execute_register_duelist(system, owner, PLAYER_NAME);

        let expire_seconds: u64 = timestamp::from_days(2);
        let duel_id: u128 = utils::execute_create_challenge(system, owner, other, PASS_CODE_1, MESSAGE_1, expire_seconds);
        let ch = utils::get_Challenge(world, duel_id);
        let (block_number, timestamp) = utils::elapse_timestamp(timestamp::from_days(1));
        let new_state: ChallengeState = utils::execute_reply_challenge(system, owner, duel_id, false);
        assert(new_state == ChallengeState::Canceled, 'canceled');

        let ch = utils::get_Challenge(world, duel_id);
        assert(ch.state == new_state, 'state');
        assert(ch.round == 0, 'round');
        assert(ch.winner == zero_address(), 'winner');
        assert(ch.timestamp_start == 0, 'timestamp_start');
        assert(ch.timestamp_end == timestamp, 'timestamp_end');
    }

    #[test]
    #[available_gas(1_000_000_000)]
    #[should_panic(expected:('Not the Challenged','ENTRYPOINT_FAILED'))]
    fn test_challenge_impersonator() {
        let (world, system, owner, other) = utils::setup_world();
        let impersonator: ContractAddress = starknet::contract_address_const::<0x333>();
        utils::execute_register_duelist(system, owner, PLAYER_NAME);
        utils::execute_register_duelist(system, other, OTHER_NAME);
        utils::execute_register_duelist(system, impersonator, 'Impersonator');

        let expire_seconds: u64 = timestamp::from_days(2);
        let duel_id: u128 = utils::execute_create_challenge(system, owner, other, PASS_CODE_1, MESSAGE_1, expire_seconds);
        let ch = utils::get_Challenge(world, duel_id);
        let (block_number, timestamp) = utils::elapse_timestamp(timestamp::from_days(1));
        utils::execute_reply_challenge(system, impersonator, duel_id, false);
    }

    #[test]
    #[available_gas(1_000_000_000)]
    #[should_panic(expected:('Challenged not registered','ENTRYPOINT_FAILED'))]
    fn test_challenge_other_not_registered() {
        let (world, system, owner, other) = utils::setup_world();
        utils::execute_register_duelist(system, owner, PLAYER_NAME);

        let expire_seconds: u64 = timestamp::from_days(2);
        let duel_id: u128 = utils::execute_create_challenge(system, owner, other, PASS_CODE_1, MESSAGE_1, expire_seconds);
        utils::elapse_timestamp(timestamp::from_days(1));
        utils::execute_reply_challenge(system, other, duel_id, true);
    }

    #[test]
    #[available_gas(1_000_000_000)]
    fn test_challenge_other_refuse() {
        let (world, system, owner, other) = utils::setup_world();
        utils::execute_register_duelist(system, owner, PLAYER_NAME);
        utils::execute_register_duelist(system, other, OTHER_NAME);

        let expire_seconds: u64 = timestamp::from_days(2);
        let duel_id: u128 = utils::execute_create_challenge(system, owner, other, PASS_CODE_1, MESSAGE_1, expire_seconds);
        let ch = utils::get_Challenge(world, duel_id);
        let (block_number, timestamp) = utils::elapse_timestamp(timestamp::from_days(1));
        let new_state: ChallengeState = utils::execute_reply_challenge(system, other, duel_id, false);
        assert(new_state == ChallengeState::Refused, 'refused');

        let ch = utils::get_Challenge(world, duel_id);
        assert(ch.state == new_state, 'state');
        assert(ch.round == 0, 'round');
        assert(ch.winner == zero_address(), 'winner');
        assert(ch.timestamp_start == 0, 'timestamp_start');
        assert(ch.timestamp_end == timestamp, 'timestamp_end');
    }

    //-----------------------------------------
    // ACCEPTED
    //

    // TODO: RE-ENABLE THIS...

    // #[test]
    // #[available_gas(1_000_000_000)]
    // fn test_challenge_other_accept() {
    //     let (world, system, owner, other) = utils::setup_world();
    //     utils::execute_register_duelist(system, owner, PLAYER_NAME);
    //     utils::execute_register_duelist(system, other, OTHER_NAME);

    //     let expire_seconds: u64 = timestamp::from_days(2);
    //     let duel_id: u128 = utils::execute_create_challenge(system, owner, other, PASS_CODE_1, MESSAGE_1, expire_seconds);
    //     let ch = utils::get_Challenge(world, duel_id);
    //     let (block_number, timestamp) = utils::elapse_timestamp(timestamp::from_days(1));
    //     let new_state: ChallengeState = utils::execute_reply_challenge(system, other, duel_id, true);
    //     assert(new_state == ChallengeState::InProgress, 'in_progress');

    //     let ch = utils::get_Challenge(world, duel_id);
    //     assert(ch.state == new_state, 'state');
    //     assert(ch.round == 1, 'round');
    //     assert(ch.timestamp_start == timestamp, 'timestamp_start');
    //     assert(ch.timestamp_end == 0, 'timestamp_end');

    //     <<< test get_Round(1)
    // }


    // TODO: REMODE THIS...
    #[test]
    #[available_gas(1_000_000_000)]
    fn test_challenge_other_accept_solve_TEMPORARY() {
        let (world, system, owner, other) = utils::setup_world();
        utils::execute_register_duelist(system, owner, PLAYER_NAME);
        utils::execute_register_duelist(system, other, OTHER_NAME);

        let expire_seconds: u64 = timestamp::from_days(2);
        let duel_id: u128 = utils::execute_create_challenge(system, owner, other, PASS_CODE_1, MESSAGE_1, expire_seconds);
        let ch = utils::get_Challenge(world, duel_id);
        let (block_number, timestamp) = utils::elapse_timestamp(timestamp::from_days(1));
        let new_state: ChallengeState = utils::execute_reply_challenge(system, other, duel_id, true);
        assert(new_state == ChallengeState::Resolved || new_state == ChallengeState::Draw, 'resolved');

        let ch = utils::get_Challenge(world, duel_id);
        assert(ch.state == new_state, 'state');
        assert(ch.round == 1, 'round');
        assert(ch.timestamp_start == timestamp, 'timestamp_start');
        assert(ch.timestamp_end == timestamp, 'timestamp_end');

        if (new_state == ChallengeState::Resolved) {
            assert(ch.winner == owner || ch.winner == other, 'winner');
        } else if (new_state == ChallengeState::Draw) {
            assert(ch.winner == zero_address(), 'draw');
        }
    }


}
