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
    use pistols::models::coins::{Coin, CoinManagerTrait, CoinTrait, coins, ETH_TO_WEI};
    use pistols::types::challenge::{ChallengeState, ChallengeStateTrait};
    use pistols::utils::timestamp::{timestamp};
    use pistols::utils::math::{MathU256};
    use pistols::tests::tester::{tester};

    const PLAYER_NAME: felt252 = 'Sensei';
    const OTHER_NAME: felt252 = 'Senpai';
    const BUMMER_NAME: felt252 = 'Bummer';
    const MESSAGE_1: felt252 = 'For honour!!!';
    const WAGER_COIN: u8 = 1;

    //
    // Fees balance
    //

    #[test]
    #[available_gas(1_000_000_000)]
    fn test_calc_fee() {
        let (_world, system, admin, _lords, _ierc20, _owner, _other, _bummer, _treasury) = tester::setup_world(true, false);
        let coin: Coin = admin.get_coin(WAGER_COIN);
        // no wager
        let fee: u256 = system.calc_fee(WAGER_COIN, 0);
        assert(fee == coin.fee_min, 'fee > 0');
        // low wager
        let fee: u256 = system.calc_fee(WAGER_COIN, 10 * ETH_TO_WEI);
        assert(fee == coin.fee_min, 'fee == min');
        // high wager
        let fee: u256 = system.calc_fee(WAGER_COIN, 100 * ETH_TO_WEI);
        assert(fee > coin.fee_min, 'fee > min');
    }

    fn _test_balance_ok(wager_value: u256) {
        let (world, system, admin, lords, ierc20, owner, other, _bummer, _treasury) = tester::setup_world(true, false);
        tester::execute_register_duelist(system, owner, PLAYER_NAME, 1);
        tester::execute_register_duelist(system, other, OTHER_NAME, 1);
        let S = system.contract_address;
        let A = other;
        let B = owner;
        let balance_contract: u256 = ierc20.balance_of(S);
        let balance_a: u256 = ierc20.balance_of(A);
        let balance_b: u256 = ierc20.balance_of(B);
        // approve fees
        let coin: Coin = admin.get_coin(WAGER_COIN);
        let fee: u256 = system.calc_fee(WAGER_COIN, wager_value);
        assert(fee >= coin.fee_min, 'fee >= min');
        let approved_value: u256 = wager_value + fee;
        tester::execute_lords_approve(lords, A, S, approved_value);
        tester::execute_lords_approve(lords, B, S, approved_value);
        // create challenge
        let duel_id: u128 = tester::execute_create_challenge(system, A, B, MESSAGE_1, WAGER_COIN, wager_value, 0);
        let ch = tester::get_Challenge(world, duel_id);
        assert(ch.state == ChallengeState::Awaiting.into(), 'Awaiting');
        // check stored wager
        let wager = tester::get_Wager(world, duel_id);
        let total: u256 = wager.value + wager.fee;
        assert(total == approved_value, 'wager total = approved_value');
        assert(wager.coin == WAGER_COIN, 'wager.coin');
        assert(wager.value == wager_value, 'wager.value');
        assert(wager.fee == fee, '== fee');
        // check balances
        let _balance_a: u256 = tester::assert_balance(ierc20, A, balance_a, approved_value, 0, 'balance_a');
        let balance_contract: u256 = tester::assert_balance(ierc20, S, balance_contract, 0, approved_value, 'balance_contract+a');
        // accept
        tester::execute_reply_challenge(system, B, duel_id, true);
        let _balance_b: u256 = tester::assert_balance(ierc20, B, balance_b, approved_value, 0, 'balance_b');
        let _balance_contract: u256 = tester::assert_balance(ierc20, S, balance_contract, 0, approved_value, 'balance_contract+b');
    }

    #[test]
    #[available_gas(1_000_000_000)]
    fn test_fee_balance_ok() {
        _test_balance_ok(0);
    }

    #[test]
    #[available_gas(1_000_000_000)]
    fn test_wager_balance_ok() {
        _test_balance_ok(100 * ETH_TO_WEI);
    }

    //
    // Challenge
    //

    #[test]
    #[available_gas(1_000_000_000)]
    #[should_panic(expected:('Insufficient balance for Fees','ENTRYPOINT_FAILED'))]
    fn test_fee_funds_nok() {
        let (_world, system, _admin, _lords, _ierc20, _owner, other, bummer, _treasury) = tester::setup_world(true, true);
        tester::execute_register_duelist(system, other, OTHER_NAME, 1);
        tester::execute_register_duelist(system, bummer, BUMMER_NAME, 1);
        let _duel_id: u128 = tester::execute_create_challenge(system, bummer, other, MESSAGE_1, WAGER_COIN, 0, 0);
    }

    #[test]
    #[available_gas(1_000_000_000)]
    #[should_panic(expected:('Insufficient balance for Fees','ENTRYPOINT_FAILED'))]
    fn test_wager_funds_nok() {
        let (_world, system, _admin, _lords, _ierc20, _owner, other, bummer, _treasury) = tester::setup_world(true, true);
        tester::execute_register_duelist(system, other, OTHER_NAME, 1);
        tester::execute_register_duelist(system, bummer, BUMMER_NAME, 1);
        let _duel_id: u128 = tester::execute_create_challenge(system, bummer, other, MESSAGE_1, WAGER_COIN, 100, 0);
    }


    //
    // Challenge OK (baseline)
    //

    #[test]
    #[available_gas(1_000_000_000)]
    fn test_fee_funds_ok() {
        let (world, system, _admin, _lords, ierc20, _owner, other, bummer, _treasury) = tester::setup_world(true, true);
        tester::execute_register_duelist(system, other, OTHER_NAME, 1);
        tester::execute_register_duelist(system, bummer, BUMMER_NAME, 1);
        let _balance: u256 = ierc20.balance_of(other);
        let duel_id: u128 = tester::execute_create_challenge(system, other, bummer, MESSAGE_1, WAGER_COIN, 0, 0);
        let ch = tester::get_Challenge(world, duel_id);
        assert(ch.state == ChallengeState::Awaiting.into(), 'Awaiting');
    }

    #[test]
    #[available_gas(1_000_000_000)]
    fn test_wager_funds_ok() {
        let (world, system, _admin, _lords, ierc20, _owner, other, bummer, _treasury) = tester::setup_world(true, true);
        tester::execute_register_duelist(system, other, OTHER_NAME, 1);
        tester::execute_register_duelist(system, bummer, BUMMER_NAME, 1);
        let _balance: u256 = ierc20.balance_of(other);
        let duel_id: u128 = tester::execute_create_challenge(system, other, bummer, MESSAGE_1, WAGER_COIN, 100, 0);
        let ch = tester::get_Challenge(world, duel_id);
        assert(ch.state == ChallengeState::Awaiting.into(), 'Awaiting');
    }

    //
    // Balance NOK
    //

    #[test]
    #[available_gas(1_000_000_000)]
    #[should_panic(expected:('Insufficient balance for Fees','ENTRYPOINT_FAILED'))]
    fn test_fee_funds_ok_resp_nok() {
        let (_world, system, _admin, _lords, _ierc20, _owner, other, bummer, _treasury) = tester::setup_world(true, true);
        tester::execute_register_duelist(system, other, OTHER_NAME, 1);
        tester::execute_register_duelist(system, bummer, BUMMER_NAME, 1);
        // verified by test_fee_funds_ok
        let duel_id: u128 = tester::execute_create_challenge(system, other, bummer, MESSAGE_1, WAGER_COIN, 0, 0);
        // panic here
        tester::execute_reply_challenge(system, bummer, duel_id, true);
    }

    #[test]
    #[available_gas(1_000_000_000)]
    #[should_panic(expected:('Insufficient balance for Fees','ENTRYPOINT_FAILED'))]
    fn test_wager_funds_ok_resp_nok() {
        let (_world, system, _admin, _lords, _ierc20, _owner, other, bummer, _treasury) = tester::setup_world(true, true);
        tester::execute_register_duelist(system, other, OTHER_NAME, 1);
        tester::execute_register_duelist(system, bummer, BUMMER_NAME, 1);
        // verified by test_wager_funds_ok
        let duel_id: u128 = tester::execute_create_challenge(system, other, bummer, MESSAGE_1, WAGER_COIN, 100, 0);
        // panic here
        tester::execute_reply_challenge(system, bummer, duel_id, true);
    }

    //
    // Allowance NOK
    //

    #[test]
    #[available_gas(1_000_000_000)]
    #[should_panic(expected:('Not allowed to transfer Fees','ENTRYPOINT_FAILED'))]
    fn test_fee_funds_ok_allowance_nok() {
        let (_world, system, _admin, lords, _ierc20, _owner, other, bummer, _treasury) = tester::setup_world(true, true);
        tester::execute_register_duelist(system, other, OTHER_NAME, 1);
        tester::execute_register_duelist(system, bummer, BUMMER_NAME, 1);
        // verified by test_fee_funds_ok
        // remove allowance
        tester::execute_lords_approve(lords, other, system.contract_address, 0);
        let _duel_id: u128 = tester::execute_create_challenge(system, other, bummer, MESSAGE_1, WAGER_COIN, 0, 0);
    }

    #[test]
    #[available_gas(1_000_000_000)]
    #[should_panic(expected:('Not allowed to transfer Fees','ENTRYPOINT_FAILED'))]
    fn test_wager_funds_ok_allowance_nok() {
        let (_world, system, _admin, lords, _ierc20, _owner, other, bummer, _treasury) = tester::setup_world(true, true);
        tester::execute_register_duelist(system, other, OTHER_NAME, 1);
        tester::execute_register_duelist(system, bummer, BUMMER_NAME, 1);
        // verified by test_fee_funds_ok
        // remove allowance
        tester::execute_lords_approve(lords, other, system.contract_address, 0);
        let _duel_id: u128 = tester::execute_create_challenge(system, other, bummer, MESSAGE_1, WAGER_COIN, 100, 0);
    }


    //
    // Cances, transfer fees back...
    //

    #[test]
    #[available_gas(1_000_000_000)]
    fn test_withdraw_fees() {
        let (world, system, _admin, _lords, ierc20, owner, other, _bummer, _treasury) = tester::setup_world(true, true);
        tester::execute_register_duelist(system, owner, PLAYER_NAME, 1);
        tester::execute_register_duelist(system, other, OTHER_NAME, 1);
        let S = system.contract_address;
        let A = other;
        let B = owner;
        let balance_contract: u256 = ierc20.balance_of(S);
        let balance_a: u256 = ierc20.balance_of(A);
        // create challenge
        let wager_value: u256 = 100 * ETH_TO_WEI;
        let fee: u256 = system.calc_fee(WAGER_COIN, wager_value);
        let approved_value: u256 = wager_value + fee;
        let duel_id: u128 = tester::execute_create_challenge(system, A, B, MESSAGE_1, WAGER_COIN, wager_value, 0);
        let ch = tester::get_Challenge(world, duel_id);
        assert(ch.state == ChallengeState::Awaiting.into(), 'Awaiting');
        tester::assert_balance(ierc20, A, balance_a, approved_value, 0, 'balance_a_1');
        tester::assert_balance(ierc20, S, balance_contract, 0, approved_value, 'balance_contract_1');
        // Withdraw
        let new_state: ChallengeState = tester::execute_reply_challenge(system, A, duel_id, false);
        assert(new_state == ChallengeState::Withdrawn, 'Withdrawn');
        tester::assert_balance(ierc20, A, balance_a, 0, 0, 'balance_a_2');
        tester::assert_balance(ierc20, S, balance_contract, 0, 0, 'balance_contract_2');
    }

    #[test]
    #[available_gas(1_000_000_000)]
    fn test_refused_fees() {
        let (world, system, _admin, _lords, ierc20, owner, other, _bummer, _treasury) = tester::setup_world(true, true);
        tester::execute_register_duelist(system, owner, PLAYER_NAME, 1);
        tester::execute_register_duelist(system, other, OTHER_NAME, 1);
        let S = system.contract_address;
        let A = other;
        let B = owner;
        let balance_contract: u256 = ierc20.balance_of(S);
        let balance_a: u256 = ierc20.balance_of(A);
        // create challenge
        let wager_value: u256 = 100 * ETH_TO_WEI;
        let fee: u256 = system.calc_fee(WAGER_COIN, wager_value);
        let approved_value: u256 = wager_value + fee;
        let duel_id: u128 = tester::execute_create_challenge(system, A, B, MESSAGE_1, WAGER_COIN, wager_value, 0);
        let ch = tester::get_Challenge(world, duel_id);
        assert(ch.state == ChallengeState::Awaiting.into(), 'Awaiting');
        tester::assert_balance(ierc20, A, balance_a, approved_value, 0, 'balance_a_1');
        tester::assert_balance(ierc20, S, balance_contract, 0, approved_value, 'balance_contract_1');
        // Withdraw
        let new_state: ChallengeState = tester::execute_reply_challenge(system, B, duel_id, false);
        assert(new_state == ChallengeState::Refused, 'Refused');
        tester::assert_balance(ierc20, A, balance_a, 0, 0, 'balance_a_2');
        tester::assert_balance(ierc20, S, balance_contract, 0, 0, 'balance_contract_2');
    }

    #[test]
    #[available_gas(1_000_000_000)]
    fn test_expired_fees() {
        let (world, system, _admin, _lords, ierc20, owner, other, _bummer, _treasury) = tester::setup_world(true, true);
        tester::execute_register_duelist(system, owner, PLAYER_NAME, 1);
        tester::execute_register_duelist(system, other, OTHER_NAME, 1);
        let S = system.contract_address;
        let A = other;
        let B = owner;
        let balance_contract: u256 = ierc20.balance_of(S);
        let balance_a: u256 = ierc20.balance_of(A);
        // create challenge
        let wager_value: u256 = 100 * ETH_TO_WEI;
        let fee: u256 = system.calc_fee(WAGER_COIN, wager_value);
        let approved_value: u256 = wager_value + fee;
        let expire_seconds: u64 = timestamp::from_days(1);
        let duel_id: u128 = tester::execute_create_challenge(system, A, B, MESSAGE_1, WAGER_COIN, wager_value, expire_seconds);
        let ch = tester::get_Challenge(world, duel_id);
        assert(ch.state == ChallengeState::Awaiting.into(), 'Awaiting');
        tester::assert_balance(ierc20, A, balance_a, approved_value, 0, 'balance_a_1');
        tester::assert_balance(ierc20, S, balance_contract, 0, approved_value, 'balance_contract_1');
        // Expire
        let (_block_number, _timestamp) = tester::elapse_timestamp(timestamp::from_date(1, 0, 1));
        let new_state: ChallengeState = tester::execute_reply_challenge(system, B, duel_id, true);
        assert(new_state == ChallengeState::Expired, 'Expired');
        tester::assert_balance(ierc20, A, balance_a, 0, 0, 'balance_a_2');
        tester::assert_balance(ierc20, S, balance_contract, 0, 0, 'balance_contract_2');
    }

}
