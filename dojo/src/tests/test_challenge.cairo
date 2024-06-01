#[cfg(test)]
mod tests {
    use debug::PrintTrait;
    use core::traits::Into;
    use starknet::{ContractAddress};

    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

    use pistols::systems::actions::{IActionsDispatcherTrait};
    use pistols::models::models::{Duelist, Round};
    use pistols::models::table::{tables};
    use pistols::types::challenge::{ChallengeState, ChallengeStateTrait};
    use pistols::systems::utils::{zero_address};
    use pistols::utils::timestamp::{timestamp};
    use pistols::tests::tester::{tester};

    const PLAYER_NAME: felt252 = 'Sensei';
    const OTHER_NAME: felt252 = 'Senpai';
    const MESSAGE_1: felt252 = 'For honour!!!';
    const TABLE_ID: felt252 = tables::LORDS;

    #[test]
    #[available_gas(1_000_000_000)]
    #[should_panic(expected:('Challenger not registered','ENTRYPOINT_FAILED'))]
    fn test_invalid_challenger() {
        let sys = tester::setup_world_sys(true, true);
        let _duel_id: u128 = tester::execute_create_challenge(sys, sys.owner, sys.other, MESSAGE_1, TABLE_ID, 0, 0);
    }

    #[test]
    #[available_gas(1_000_000_000)]
    #[should_panic(expected:('Challenging thyself, you fool!','ENTRYPOINT_FAILED'))]
    fn test_challenge_thyself() {
        let sys = tester::setup_world_sys(true, true);
        tester::execute_register_duelist(sys, sys.owner, PLAYER_NAME, 1);
        let _duel_id: u128 = tester::execute_create_challenge(sys, sys.owner, sys.owner, MESSAGE_1, TABLE_ID, 0, 0);
    }

    #[test]
    #[available_gas(1_000_000_000)]
    #[should_panic(expected:('Missing challenged address','ENTRYPOINT_FAILED'))]
    // #[should_panic(expected:('Challenge a player','ENTRYPOINT_FAILED'))]
    fn test_invalid_code() {
        let sys = tester::setup_world_sys(true, true);
        tester::execute_register_duelist(sys, sys.owner, PLAYER_NAME, 1);
        let challenged_1 = zero_address();
        let _duel_id: u128 = tester::execute_create_challenge(sys, sys.owner, challenged_1, MESSAGE_1, TABLE_ID, 0, 0);
    }

    #[test]
    #[available_gas(1_000_000_000)]
    #[should_panic(expected:('Duplicated challenge','ENTRYPOINT_FAILED'))]
    fn test_duplicated_challenge() {
        let sys = tester::setup_world_sys(true, true);
        tester::execute_register_duelist(sys, sys.owner, PLAYER_NAME, 1);
        tester::execute_register_duelist(sys, sys.other, OTHER_NAME, 1);
        tester::execute_create_challenge(sys, sys.owner, sys.other, MESSAGE_1,TABLE_ID, 0, 0);
        tester::execute_create_challenge(sys, sys.owner, sys.other, MESSAGE_1, TABLE_ID, 0, 0);
    }

    #[test]
    #[available_gas(1_000_000_000)]
    #[should_panic(expected:('Duplicated challenge','ENTRYPOINT_FAILED'))]
    fn test_duplicated_challenge_from_challenged() {
        let sys = tester::setup_world_sys(true, true);
        tester::execute_register_duelist(sys, sys.owner, PLAYER_NAME, 1);
        tester::execute_register_duelist(sys, sys.other, OTHER_NAME, 1);
        tester::execute_create_challenge(sys, sys.owner, sys.other, MESSAGE_1, TABLE_ID, 0, 0);
        tester::execute_create_challenge(sys, sys.other, sys.owner, MESSAGE_1, TABLE_ID, 0, 0);
    }

    #[test]
    #[available_gas(1_000_000_000)]
    #[should_panic(expected:('Invalid expire_seconds','ENTRYPOINT_FAILED'))]
    fn test_invalid_expire() {
        let sys = tester::setup_world_sys(true, true);
        tester::execute_register_duelist(sys, sys.owner, PLAYER_NAME, 1);
        let expire_seconds: u64 = 60 * 60 - 1;
        let _duel_id: u128 = tester::execute_create_challenge(sys, sys.owner, sys.other, MESSAGE_1, TABLE_ID, 0, expire_seconds);
    }

    #[test]
    #[available_gas(1_000_000_000)]
    fn test_challenge_address() {
        let sys = tester::setup_world_sys(true, true);
        tester::execute_register_duelist(sys, sys.owner, PLAYER_NAME, 1);
        let timestamp = tester::get_block_timestamp();
        let duel_id: u128 = tester::execute_create_challenge(sys, sys.owner, sys.other, MESSAGE_1, TABLE_ID, 0, 0);
        let ch = tester::get_Challenge(sys, duel_id);
        assert(ch.state == ChallengeState::Awaiting.into(), 'state');
        assert(ch.duelist_a == sys.owner, 'challenged');
        assert(ch.duelist_b == sys.other, 'challenged');
        assert(ch.message == MESSAGE_1, 'message');
        assert(ch.timestamp_start == timestamp, 'timestamp_start');
        assert(ch.timestamp_end == 0, 'timestamp_end');
    }

    #[test]
    #[available_gas(1_000_000_000)]
    fn test_challenge_expire_ok() {
        let sys = tester::setup_world_sys(true, true);
        tester::execute_register_duelist(sys, sys.owner, PLAYER_NAME, 1);
        let expire_seconds: u64 = 24 * 60 * 60;
        let timestamp = tester::get_block_timestamp();
        let duel_id: u128 = tester::execute_create_challenge(sys, sys.owner, sys.other, MESSAGE_1, TABLE_ID, 0, expire_seconds);
        let ch = tester::get_Challenge(sys, duel_id);
        assert(ch.timestamp_start == timestamp, 'timestamp_start');
        assert(ch.timestamp_end == ch.timestamp_start + expire_seconds, 'timestamp_end');
    }

    #[test]
    #[available_gas(1_000_000_000)]
    fn test_challenge_address_pact() {
        let sys = tester::setup_world_sys(true, true);
        tester::execute_register_duelist(sys, sys.owner, PLAYER_NAME, 1);
        assert(sys.actions.get_pact(sys.owner, sys.other) == 0, 'get_pact_0_1');
        assert(sys.actions.get_pact(sys.other, sys.owner) == 0, 'get_pact_0_2');
        assert(sys.actions.has_pact(sys.owner, sys.other) == false, 'has_pact_0_1');
        assert(sys.actions.has_pact(sys.other, sys.owner) == false, 'has_pact_0_2');
        let duel_id: u128 = tester::execute_create_challenge(sys, sys.owner, sys.other, MESSAGE_1, TABLE_ID, 0, 0);
        assert(sys.actions.get_pact(sys.owner, sys.other) == duel_id, 'get_pact_1_1');
        assert(sys.actions.get_pact(sys.other, sys.owner) == duel_id, 'get_pact_1_2');
        assert(sys.actions.has_pact(sys.owner, sys.other) == true, 'has_pact_1_1');
        assert(sys.actions.has_pact(sys.other, sys.owner) == true, 'has_pact_1_2');
    }


    //-----------------------------------------
    // REPLY
    //

    #[test]
    #[available_gas(1_000_000_000)]
    #[should_panic(expected:('Challenge do not exist','ENTRYPOINT_FAILED'))]
    fn test_challenge_reply_invalid() {
        let sys = tester::setup_world_sys(true, true);
        tester::execute_register_duelist(sys, sys.owner, PLAYER_NAME, 1);

        let expire_seconds: u64 = timestamp::from_days(2);
        let duel_id: u128 = tester::execute_create_challenge(sys, sys.owner, sys.other, MESSAGE_1, TABLE_ID, 0, expire_seconds);
        tester::elapse_timestamp(timestamp::from_days(1));
        tester::execute_reply_challenge(sys, sys.owner, duel_id + 1, true);
    }

    #[test]
    #[available_gas(1_000_000_000)]
    #[should_panic(expected:('Challenge is not Awaiting','ENTRYPOINT_FAILED'))]
    fn test_challenge_reply_twice() {
        let sys = tester::setup_world_sys(true, true);
        tester::execute_register_duelist(sys, sys.owner, PLAYER_NAME, 1);

        let expire_seconds: u64 = timestamp::from_days(2);
        let duel_id: u128 = tester::execute_create_challenge(sys, sys.owner, sys.other, MESSAGE_1, TABLE_ID, 0, expire_seconds);
        let _ch = tester::get_Challenge(sys, duel_id);
        let (_block_number, _timestamp) = tester::elapse_timestamp(timestamp::from_days(3));
        let new_state: ChallengeState = tester::execute_reply_challenge(sys, sys.other, duel_id, false);
        assert(new_state != ChallengeState::Awaiting, '!awaiting');
        
        tester::execute_reply_challenge(sys, sys.other, duel_id, true);
    }

    #[test]
    #[available_gas(1_000_000_000)]
    fn test_challenge_reply_expired() {
        let sys = tester::setup_world_sys(true, true);
        tester::execute_register_duelist(sys, sys.owner, PLAYER_NAME, 1);

        let expire_seconds: u64 = timestamp::from_days(1);
        let duel_id: u128 = tester::execute_create_challenge(sys, sys.owner, sys.other, MESSAGE_1, TABLE_ID, 0, expire_seconds);
        let _ch = tester::get_Challenge(sys, duel_id);

        assert(sys.actions.has_pact(sys.other, sys.owner) == true, 'has_pact_yes');
        let (_block_number, timestamp) = tester::elapse_timestamp(timestamp::from_date(1, 0, 1));
        let new_state: ChallengeState = tester::execute_reply_challenge(sys, sys.owner, duel_id, true);
        assert(new_state == ChallengeState::Expired, 'expired');
        assert(sys.actions.has_pact(sys.other, sys.owner) == false, 'has_pact_no');

        let ch = tester::get_Challenge(sys, duel_id);
        assert(ch.state == new_state.into(), 'state');
        assert(ch.round_number == 0, 'round_number');
        assert(ch.winner == 0, 'winner');
        assert(ch.timestamp_start > 0, 'timestamp_start');
        assert(ch.timestamp_end == timestamp, 'timestamp_end');
    }

    #[test]
    #[available_gas(1_000_000_000)]
    #[should_panic(expected:('Cannot accept own challenge','ENTRYPOINT_FAILED'))]
    fn test_challenge_owner_accept() {
        let sys = tester::setup_world_sys(true, true);
        tester::execute_register_duelist(sys, sys.owner, PLAYER_NAME, 1);

        let expire_seconds: u64 = timestamp::from_days(2);
        let duel_id: u128 = tester::execute_create_challenge(sys, sys.owner, sys.other, MESSAGE_1, TABLE_ID, 0, expire_seconds);
        let _ch = tester::get_Challenge(sys, duel_id);

        tester::elapse_timestamp(timestamp::from_days(1));
        tester::execute_reply_challenge(sys, sys.owner, duel_id, true);
    }

    #[test]
    #[available_gas(1_000_000_000)]
    fn test_challenge_owner_cancel() {
        let sys = tester::setup_world_sys(true, true);
        tester::execute_register_duelist(sys, sys.owner, PLAYER_NAME, 1);

        let expire_seconds: u64 = timestamp::from_days(2);
        let duel_id: u128 = tester::execute_create_challenge(sys, sys.owner, sys.other, MESSAGE_1, TABLE_ID, 0, expire_seconds);
        let _ch = tester::get_Challenge(sys, duel_id);
        let (_block_number, timestamp) = tester::elapse_timestamp(timestamp::from_days(1));

        assert(sys.actions.has_pact(sys.other, sys.owner) == true, 'has_pact_yes');
        let new_state: ChallengeState = tester::execute_reply_challenge(sys, sys.owner, duel_id, false);
        assert(new_state == ChallengeState::Withdrawn, 'canceled');
        assert(sys.actions.has_pact(sys.owner, sys.other) == false, 'has_pact_no');

        let ch = tester::get_Challenge(sys, duel_id);
        assert(ch.state == new_state.into(), 'state');
        assert(ch.round_number == 0, 'round_number');
        assert(ch.winner == 0, 'winner');
        assert(ch.timestamp_start < timestamp, 'timestamp_start');
        assert(ch.timestamp_end == timestamp, 'timestamp_end');
    }

    #[test]
    #[available_gas(1_000_000_000)]
    #[should_panic(expected:('Not the Challenged','ENTRYPOINT_FAILED'))]
    fn test_challenge_impersonator() {
        let sys = tester::setup_world_sys(true, true);
        let impersonator: ContractAddress = starknet::contract_address_const::<0x333>();
        tester::execute_register_duelist(sys, sys.owner, PLAYER_NAME, 1);
        tester::execute_register_duelist(sys, sys.other, OTHER_NAME, 2);
        tester::execute_register_duelist(sys, impersonator, 'Impersonator', 3);

        let expire_seconds: u64 = timestamp::from_days(2);
        let duel_id: u128 = tester::execute_create_challenge(sys, sys.owner, sys.other, MESSAGE_1, TABLE_ID, 0, expire_seconds);
        let _ch = tester::get_Challenge(sys, duel_id);
        let (_block_number, _timestamp) = tester::elapse_timestamp(timestamp::from_days(1));
        tester::execute_reply_challenge(sys, impersonator, duel_id, false);
    }

    #[test]
    #[available_gas(1_000_000_000)]
    #[should_panic(expected:('Challenged not registered','ENTRYPOINT_FAILED'))]
    fn test_challenge_other_not_registered() {
        let sys = tester::setup_world_sys(true, true);
        tester::execute_register_duelist(sys, sys.owner, PLAYER_NAME, 1);
        let expire_seconds: u64 = timestamp::from_days(2);
        let duel_id: u128 = tester::execute_create_challenge(sys, sys.owner, sys.other, MESSAGE_1, TABLE_ID, 0, expire_seconds);
        tester::elapse_timestamp(timestamp::from_days(1));
        tester::execute_reply_challenge(sys, sys.other, duel_id, true);
    }

    #[test]
    #[available_gas(1_000_000_000)]
    fn test_challenge_other_refuse() {
        let sys = tester::setup_world_sys(true, true);
        tester::execute_register_duelist(sys, sys.owner, PLAYER_NAME, 1);
        tester::execute_register_duelist(sys, sys.other, OTHER_NAME, 2);

        let expire_seconds: u64 = timestamp::from_days(2);
        let duel_id: u128 = tester::execute_create_challenge(sys, sys.owner, sys.other, MESSAGE_1, TABLE_ID, 0, expire_seconds);

        assert(sys.actions.has_pact(sys.other, sys.owner) == true, 'has_pact_yes');
        let (_block_number, timestamp) = tester::elapse_timestamp(timestamp::from_days(1));
        let new_state: ChallengeState = tester::execute_reply_challenge(sys, sys.other, duel_id, false);
        assert(new_state == ChallengeState::Refused, 'refused');
        assert(sys.actions.has_pact(sys.other, sys.owner) == false, 'has_pact_no');

        let ch = tester::get_Challenge(sys, duel_id);
        assert(ch.state == new_state.into(), 'state');
        assert(ch.round_number == 0, 'round_number');
        assert(ch.winner == 0, 'winner');
        assert(ch.timestamp_start < timestamp, 'timestamp_start');
        assert(ch.timestamp_end == timestamp, 'timestamp_end');
    }

    //-----------------------------------------
    // ACCEPT CHALLENGE
    //
    // at test_duel.cairo
    //
}
