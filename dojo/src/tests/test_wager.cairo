#[cfg(test)]
mod tests {
    use debug::PrintTrait;
    use core::traits::Into;
    use starknet::{ContractAddress};

    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

    use token::erc20::interface::{IERC20Dispatcher, IERC20DispatcherTrait};
    use pistols::systems::actions::{IActionsDispatcher, IActionsDispatcherTrait};
    use pistols::systems::admin::{IAdminDispatcher, IAdminDispatcherTrait};
    use pistols::systems::utils::{zero_address};
    use pistols::models::config::{Config};
    use pistols::models::table::{TTable, TableTrait, TableManagerTrait, tables};
    use pistols::types::challenge::{ChallengeState, ChallengeStateTrait};
    use pistols::types::constants::{constants};
    use pistols::utils::timestamp::{timestamp};
    use pistols::utils::math::{MathU256};
    use pistols::tests::tester::{tester};

    const PLAYER_NAME: felt252 = 'Sensei';
    const OTHER_NAME: felt252 = 'Senpai';
    const BUMMER_NAME: felt252 = 'Bummer';
    const MESSAGE_1: felt252 = 'For honour!!!';
    const TABLE_ID: felt252 = tables::LORDS;

    //
    // Fees balance
    //

    #[test]
    #[available_gas(1_000_000_000)]
    fn test_calc_fee() {
        let sys = tester::setup_world_sys(true, false);
        let table: TTable = sys.admin.get_table(TABLE_ID);
        // no wager
        let fee: u256 = sys.actions.calc_fee(TABLE_ID, 0);
        assert(fee == table.fee_min, 'fee > 0');
        // low wager
        let fee: u256 = sys.actions.calc_fee(TABLE_ID, 10 * constants::ETH_TO_WEI);
        assert(fee == table.fee_min, 'fee == min');
        // high wager
        let fee: u256 = sys.actions.calc_fee(TABLE_ID, 100 * constants::ETH_TO_WEI);
        assert(fee > table.fee_min, 'fee > min');
    }

    fn _test_balance_ok(table_id: felt252, wager_value: u256, wager_min: u256) {
        let sys = tester::setup_world_sys(true, false);
        tester::execute_register_duelist(sys, sys.owner, PLAYER_NAME, 1);
        tester::execute_register_duelist(sys, sys.other, OTHER_NAME, 1);
        let S = sys.actions.contract_address;
        let A = sys.other;
        let B = sys.owner;
        let balance_contract: u256 = sys.ierc20.balance_of(S);
        let balance_a: u256 = sys.ierc20.balance_of(A);
        let balance_b: u256 = sys.ierc20.balance_of(B);
        // approve fees
        let mut table: TTable = sys.admin.get_table(table_id);
        if (wager_min > 0) {
            table.wager_min = wager_min;
            set!(sys.world, (table));
        }
        let fee: u256 = sys.actions.calc_fee(table_id, wager_value);
        assert(fee >= table.fee_min, 'fee >= min');
        let approved_value: u256 = wager_value + fee;
        tester::execute_lords_approve(sys, A, S, approved_value);
        tester::execute_lords_approve(sys, B, S, approved_value);
        // create challenge
        let duel_id: u128 = tester::execute_create_challenge(sys, A, B, MESSAGE_1, table_id, wager_value, 0);
        let ch = tester::get_Challenge(sys, duel_id);
        assert(ch.table_id == table_id, 'ch.table_id');
        assert(ch.state == ChallengeState::Awaiting.into(), 'Awaiting');
        // check stored wager
        let wager = tester::get_Wager(sys, duel_id);
        let total: u256 = wager.value + wager.fee;
        assert(total == approved_value, 'wager total = approved_value');
        assert(wager.value >= table.wager_min, 'waager >= wager_min');
        assert(wager.value == wager_value, 'wager.value');
        assert(wager.fee == fee, 'wager.fee');
        // check balances
        let final_balance_a: u256 = tester::assert_balance(sys, A, balance_a, approved_value, 0, 'balance_a');
        let fina_balance_contract: u256 = tester::assert_balance(sys, S, balance_contract, 0, approved_value, 'balance_contract+a');
        // accept
        tester::execute_reply_challenge(sys, B, duel_id, true);
        let final_balance_b: u256 = tester::assert_balance(sys, B, balance_b, approved_value, 0, 'balance_b');
        let final_balance_contract: u256 = tester::assert_balance(sys, S, fina_balance_contract, 0, approved_value, 'balance_contract+b');
        if (table_id == tables::LORDS) {
            assert(fee > 0, 'fee > 0');
            assert(final_balance_a < balance_a, 'final_balance_a');
            assert(final_balance_b < balance_b, 'final_balance_b');
            assert(final_balance_contract > balance_contract, 'final_balance_contract');
        } else if (table_id == tables::COMMONERS) {
            assert(fee == 0, 'fee == 0');
            assert(final_balance_a == balance_a, 'final_balance_a');
            assert(final_balance_b == balance_b, 'final_balance_b');
            assert(final_balance_contract == balance_contract, 'final_balance_contract');
        }
    }

    #[test]
    #[available_gas(1_000_000_000)]
    fn test_LORDS_fee_balance_ok() {
        _test_balance_ok(tables::LORDS, 0, 0);
    }
    fn test_COMMONERS_fee_balance_ok() {
        _test_balance_ok(tables::COMMONERS, 0, 0);
    }
    #[test]
    #[available_gas(1_000_000_000)]
    fn test_LORDS_wager_balance_ok() {
        _test_balance_ok(tables::LORDS, 100 * constants::ETH_TO_WEI, 0);
    }
    #[test]
    #[available_gas(1_000_000_000)]
    #[should_panic(expected:('No wager on this table','ENTRYPOINT_FAILED'))]
    fn test_COMMONERS_wager_balance_ok() {
        _test_balance_ok(tables::COMMONERS, 100 * constants::ETH_TO_WEI, 0);
    }
    #[test]
    #[available_gas(1_000_000_000)]
    #[should_panic(expected:('Minimum wager not met','ENTRYPOINT_FAILED'))]
    fn test_LORDS_wager_balance_min_wager() {
        _test_balance_ok(tables::LORDS, 99 * constants::ETH_TO_WEI, 100 * constants::ETH_TO_WEI);
    }


    //
    // Challenge
    //

    #[test]
    #[available_gas(1_000_000_000)]
    #[should_panic(expected:('Insufficient balance for Fees','ENTRYPOINT_FAILED'))]
    fn test_fee_funds_nok() {
        let sys = tester::setup_world_sys(true, true);
        tester::execute_register_duelist(sys, sys.other, OTHER_NAME, 1);
        tester::execute_register_duelist(sys, sys.bummer, BUMMER_NAME, 1);
        let _duel_id: u128 = tester::execute_create_challenge(sys, sys.bummer, sys.other, MESSAGE_1, TABLE_ID, 0, 0);
    }

    #[test]
    #[available_gas(1_000_000_000)]
    #[should_panic(expected:('Insufficient balance for Fees','ENTRYPOINT_FAILED'))]
    fn test_wager_funds_nok() {
        let sys = tester::setup_world_sys(true, true);
        tester::execute_register_duelist(sys, sys.other, OTHER_NAME, 1);
        tester::execute_register_duelist(sys, sys.bummer, BUMMER_NAME, 1);
        let _duel_id: u128 = tester::execute_create_challenge(sys, sys.bummer, sys.other, MESSAGE_1, TABLE_ID, 100, 0);
    }


    //
    // Challenge OK (baseline)
    //

    #[test]
    #[available_gas(1_000_000_000)]
    fn test_fee_funds_ok() {
        let sys = tester::setup_world_sys(true, true);
        tester::execute_register_duelist(sys, sys.other, OTHER_NAME, 1);
        tester::execute_register_duelist(sys, sys.bummer, BUMMER_NAME, 1);
        let _balance: u256 = sys.ierc20.balance_of(sys.other);
        let duel_id: u128 = tester::execute_create_challenge(sys, sys.other, sys.bummer, MESSAGE_1, TABLE_ID, 0, 0);
        let ch = tester::get_Challenge(sys, duel_id);
        assert(ch.state == ChallengeState::Awaiting.into(), 'Awaiting');
    }

    #[test]
    #[available_gas(1_000_000_000)]
    fn test_wager_funds_ok() {
        let sys = tester::setup_world_sys(true, true);
        tester::execute_register_duelist(sys, sys.other, OTHER_NAME, 1);
        tester::execute_register_duelist(sys, sys.bummer, BUMMER_NAME, 1);
        let _balance: u256 = sys.ierc20.balance_of(sys.other);
        let duel_id: u128 = tester::execute_create_challenge(sys, sys.other, sys.bummer, MESSAGE_1, TABLE_ID, 100, 0);
        let ch = tester::get_Challenge(sys, duel_id);
        assert(ch.state == ChallengeState::Awaiting.into(), 'Awaiting');
    }

    //
    // Balance NOK
    //

    #[test]
    #[available_gas(1_000_000_000)]
    #[should_panic(expected:('Insufficient balance for Fees','ENTRYPOINT_FAILED'))]
    fn test_fee_funds_ok_resp_nok() {
        let sys = tester::setup_world_sys(true, true);
        tester::execute_register_duelist(sys, sys.other, OTHER_NAME, 1);
        tester::execute_register_duelist(sys, sys.bummer, BUMMER_NAME, 1);
        // verified by test_fee_funds_ok
        let duel_id: u128 = tester::execute_create_challenge(sys, sys.other, sys.bummer, MESSAGE_1, TABLE_ID, 0, 0);
        // panic here
        tester::execute_reply_challenge(sys, sys.bummer, duel_id, true);
    }

    #[test]
    #[available_gas(1_000_000_000)]
    #[should_panic(expected:('Insufficient balance for Fees','ENTRYPOINT_FAILED'))]
    fn test_wager_funds_ok_resp_nok() {
        let sys = tester::setup_world_sys(true, true);
        tester::execute_register_duelist(sys, sys.other, OTHER_NAME, 1);
        tester::execute_register_duelist(sys, sys.bummer, BUMMER_NAME, 1);
        // verified by test_wager_funds_ok
        let duel_id: u128 = tester::execute_create_challenge(sys, sys.other, sys.bummer, MESSAGE_1, TABLE_ID, 100, 0);
        // panic here
        tester::execute_reply_challenge(sys, sys.bummer, duel_id, true);
    }

    //
    // Allowance NOK
    //

    #[test]
    #[available_gas(1_000_000_000)]
    #[should_panic(expected:('Not allowed to transfer Fees','ENTRYPOINT_FAILED'))]
    fn test_fee_funds_ok_allowance_nok() {
        let sys = tester::setup_world_sys(true, true);
        tester::execute_register_duelist(sys, sys.other, OTHER_NAME, 1);
        tester::execute_register_duelist(sys, sys.bummer, BUMMER_NAME, 1);
        // verified by test_fee_funds_ok
        // remove allowance
        tester::execute_lords_approve(sys, sys.other, sys.actions.contract_address, 0);
        let _duel_id: u128 = tester::execute_create_challenge(sys, sys.other, sys.bummer, MESSAGE_1, TABLE_ID, 0, 0);
    }

    #[test]
    #[available_gas(1_000_000_000)]
    #[should_panic(expected:('Not allowed to transfer Fees','ENTRYPOINT_FAILED'))]
    fn test_wager_funds_ok_allowance_nok() {
        let sys = tester::setup_world_sys(true, true);
        tester::execute_register_duelist(sys, sys.other, OTHER_NAME, 1);
        tester::execute_register_duelist(sys, sys.bummer, BUMMER_NAME, 1);
        // verified by test_fee_funds_ok
        // remove allowance
        tester::execute_lords_approve(sys, sys.other, sys.actions.contract_address, 0);
        let _duel_id: u128 = tester::execute_create_challenge(sys, sys.other, sys.bummer, MESSAGE_1, TABLE_ID, 100, 0);
    }


    //
    // Cances, transfer fees back...
    //

    #[test]
    #[available_gas(1_000_000_000)]
    fn test_withdraw_fees() {
        let sys = tester::setup_world_sys(true, true);
        tester::execute_register_duelist(sys, sys.owner, PLAYER_NAME, 1);
        tester::execute_register_duelist(sys, sys.other, OTHER_NAME, 1);
        let S = sys.actions.contract_address;
        let A = sys.other;
        let B = sys.owner;
        let balance_contract: u256 = sys.ierc20.balance_of(S);
        let balance_a: u256 = sys.ierc20.balance_of(A);
        // create challenge
        let wager_value: u256 = 100 * constants::ETH_TO_WEI;
        let fee: u256 = sys.actions.calc_fee(TABLE_ID, wager_value);
        let approved_value: u256 = wager_value + fee;
        let duel_id: u128 = tester::execute_create_challenge(sys, A, B, MESSAGE_1, TABLE_ID, wager_value, 0);
        let ch = tester::get_Challenge(sys, duel_id);
        assert(ch.state == ChallengeState::Awaiting.into(), 'Awaiting');
        tester::assert_balance(sys, A, balance_a, approved_value, 0, 'balance_a_1');
        tester::assert_balance(sys, S, balance_contract, 0, approved_value, 'balance_contract_1');
        // Withdraw
        let new_state: ChallengeState = tester::execute_reply_challenge(sys, A, duel_id, false);
        assert(new_state == ChallengeState::Withdrawn, 'Withdrawn');
        tester::assert_balance(sys, A, balance_a, 0, 0, 'balance_a_2');
        tester::assert_balance(sys, S, balance_contract, 0, 0, 'balance_contract_2');
    }

    #[test]
    #[available_gas(1_000_000_000)]
    fn test_refused_fees() {
        let sys = tester::setup_world_sys(true, true);
        tester::execute_register_duelist(sys, sys.owner, PLAYER_NAME, 1);
        tester::execute_register_duelist(sys, sys.other, OTHER_NAME, 1);
        let S = sys.actions.contract_address;
        let A = sys.other;
        let B = sys.owner;
        let balance_contract: u256 = sys.ierc20.balance_of(S);
        let balance_a: u256 = sys.ierc20.balance_of(A);
        // create challenge
        let wager_value: u256 = 100 * constants::ETH_TO_WEI;
        let fee: u256 = sys.actions.calc_fee(TABLE_ID, wager_value);
        let approved_value: u256 = wager_value + fee;
        let duel_id: u128 = tester::execute_create_challenge(sys, A, B, MESSAGE_1, TABLE_ID, wager_value, 0);
        let ch = tester::get_Challenge(sys, duel_id);
        assert(ch.state == ChallengeState::Awaiting.into(), 'Awaiting');
        tester::assert_balance(sys, A, balance_a, approved_value, 0, 'balance_a_1');
        tester::assert_balance(sys, S, balance_contract, 0, approved_value, 'balance_contract_1');
        // Withdraw
        let new_state: ChallengeState = tester::execute_reply_challenge(sys, B, duel_id, false);
        assert(new_state == ChallengeState::Refused, 'Refused');
        tester::assert_balance(sys, A, balance_a, 0, 0, 'balance_a_2');
        tester::assert_balance(sys, S, balance_contract, 0, 0, 'balance_contract_2');
    }

    #[test]
    #[available_gas(1_000_000_000)]
    fn test_expired_fees() {
        let sys = tester::setup_world_sys(true, true);
        tester::execute_register_duelist(sys, sys.owner, PLAYER_NAME, 1);
        tester::execute_register_duelist(sys, sys.other, OTHER_NAME, 1);
        let S = sys.actions.contract_address;
        let A = sys.other;
        let B = sys.owner;
        let balance_contract: u256 = sys.ierc20.balance_of(S);
        let balance_a: u256 = sys.ierc20.balance_of(A);
        // create challenge
        let wager_value: u256 = 100 * constants::ETH_TO_WEI;
        let fee: u256 = sys.actions.calc_fee(TABLE_ID, wager_value);
        let approved_value: u256 = wager_value + fee;
        let expire_seconds: u64 = timestamp::from_days(1);
        let duel_id: u128 = tester::execute_create_challenge(sys, A, B, MESSAGE_1, TABLE_ID, wager_value, expire_seconds);
        let ch = tester::get_Challenge(sys, duel_id);
        assert(ch.state == ChallengeState::Awaiting.into(), 'Awaiting');
        tester::assert_balance(sys, A, balance_a, approved_value, 0, 'balance_a_1');
        tester::assert_balance(sys, S, balance_contract, 0, approved_value, 'balance_contract_1');
        // Expire
        let (_block_number, _timestamp) = tester::elapse_timestamp(timestamp::from_date(1, 0, 1));
        let new_state: ChallengeState = tester::execute_reply_challenge(sys, B, duel_id, true);
        assert(new_state == ChallengeState::Expired, 'Expired');
        tester::assert_balance(sys, A, balance_a, 0, 0, 'balance_a_2');
        tester::assert_balance(sys, S, balance_contract, 0, 0, 'balance_contract_2');
    }

}
