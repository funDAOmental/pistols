#[cfg(test)]
mod tester {
    use starknet::{ContractAddress, testing};
    use core::traits::Into;
    use array::ArrayTrait;
    use debug::PrintTrait;

    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    use dojo::test_utils::{spawn_test_world, deploy_contract};

    use pistols::interfaces::ierc20::{IERC20Dispatcher, IERC20DispatcherTrait};
    // use token::erc20::interface::{IERC20Dispatcher, IERC20DispatcherTrait};
    use pistols::systems::admin::{admin, IAdminDispatcher, IAdminDispatcherTrait};
    use pistols::systems::actions::{actions, IActionsDispatcher, IActionsDispatcherTrait};
    use pistols::mocks::lords_mock::{lords_mock, ILordsMockDispatcher, ILordsMockDispatcherTrait};
    use pistols::types::challenge::{ChallengeState};
    use pistols::types::constants::{constants};
    use pistols::types::action::{Action};
    use pistols::models::models::{
        Duelist, duelist,
        Scoreboard, scoreboard,
        Challenge, challenge,
        Snapshot, snapshot,
        Wager, wager,
        Round, round,
    };
    use pistols::models::config::{Config, config};
    use pistols::models::table::{TTable, t_table};
    use pistols::utils::string::{String};

    extern fn pedersen(a: felt252, b: felt252) -> felt252 implicits(Pedersen) nopanic;

    #[derive(Copy, Drop)]
    struct TesterSys {
        world: IWorldDispatcher,
        actions: IActionsDispatcher,
        admin: IAdminDispatcher,
        lords: ILordsMockDispatcher,
        ierc20: IERC20Dispatcher,
        owner: ContractAddress,
        other: ContractAddress,
        bummer: ContractAddress,
        treasury: ContractAddress,
    }

    //
    // starknet testing cheats
    // https://github.com/starkware-libs/cairo/blob/main/corelib/src/starknet/testing.cairo
    //

    const INITIAL_TIMESTAMP: u64 = 0x100000000;
    const INITIAL_STEP: u64 = 0x10;

    fn deploy_system(world: IWorldDispatcher, class_hash_felt: felt252) -> ContractAddress {
        let contract_address = world.deploy_contract(class_hash_felt, class_hash_felt.try_into().unwrap());
        (contract_address)
    }

    fn setup_world_sys(initialize: bool, approve: bool) -> TesterSys {
        let mut models = array![
            duelist::TEST_CLASS_HASH,
            scoreboard::TEST_CLASS_HASH,
            challenge::TEST_CLASS_HASH,
            snapshot::TEST_CLASS_HASH,
            wager::TEST_CLASS_HASH,
            round::TEST_CLASS_HASH,
            config::TEST_CLASS_HASH,
            t_table::TEST_CLASS_HASH,
        ];
        // accounts
        let owner: ContractAddress = starknet::contract_address_const::<0x111111>();
        let other: ContractAddress = starknet::contract_address_const::<0x222>();
        let bummer: ContractAddress = starknet::contract_address_const::<0x333>();
        let treasury: ContractAddress = starknet::contract_address_const::<0x444>();
        // setup testing
        // testing::set_caller_address(owner);   // not used??
        testing::set_contract_address(owner); // this is the CALLER!!
        testing::set_block_number(1);
        testing::set_block_timestamp(INITIAL_TIMESTAMP);
        // systems
        let world: IWorldDispatcher = spawn_test_world(models);
        let actions = IActionsDispatcher{ contract_address: deploy_system(world, actions::TEST_CLASS_HASH) };
        let admin = IAdminDispatcher{ contract_address: deploy_system(world, admin::TEST_CLASS_HASH) };
        let lords = ILordsMockDispatcher{ contract_address: deploy_system(world, lords_mock::TEST_CLASS_HASH) };
        let ierc20 = IERC20Dispatcher{ contract_address:lords.contract_address };
        let sys = TesterSys{ world, actions, admin, lords, ierc20, owner, other, bummer, treasury };
        // initializers
        execute_lords_initializer(sys, owner);
        execute_lords_faucet(sys, owner);
        execute_lords_faucet(sys, other);
        if (initialize) {
            execute_admin_initialize(sys, owner, owner, treasury, lords.contract_address);
        }
        if (approve) {
            execute_lords_approve(sys, owner, actions.contract_address, 1_000_000 * constants::ETH_TO_WEI);
            execute_lords_approve(sys, other, actions.contract_address, 1_000_000 * constants::ETH_TO_WEI);
            execute_lords_approve(sys, bummer, actions.contract_address, 1_000_000 * constants::ETH_TO_WEI);
        }
        (sys)
    }

    fn elapse_timestamp(delta: u64) -> (u64, u64) {
        let block_info = starknet::get_block_info().unbox();
        let new_block_number = block_info.block_number + 1;
        let new_block_timestamp = block_info.block_timestamp + delta;
        testing::set_block_number(new_block_number);
        testing::set_block_timestamp(new_block_timestamp);
        (new_block_number, new_block_timestamp)
    }

    #[inline(always)]
    fn get_block_number() -> u64 {
        let block_info = starknet::get_block_info().unbox();
        (block_info.block_number)
    }

    #[inline(always)]
    fn get_block_timestamp() -> u64 {
        let block_info = starknet::get_block_info().unbox();
        (block_info.block_timestamp)
    }

    #[inline(always)]
    fn _next_block() -> (u64, u64) {
        elapse_timestamp(INITIAL_STEP)
    }

    //
    // execute calls
    //

    // ::admin
    fn execute_admin_initialize(sys: TesterSys, sender: ContractAddress, owner_address: ContractAddress, treasury_address: ContractAddress, lords_address: ContractAddress) {
        testing::set_contract_address(sender);
        sys.admin.initialize(owner_address, treasury_address, lords_address);
        _next_block();
    }
    fn execute_admin_set_owner(sys: TesterSys, sender: ContractAddress, owner_address: ContractAddress) {
        testing::set_contract_address(sender);
        sys.admin.set_owner(owner_address);
        _next_block();
    }
    fn execute_admin_set_treasury(sys: TesterSys, sender: ContractAddress, treasury_address: ContractAddress) {
        testing::set_contract_address(sender);
        sys.admin.set_treasury(treasury_address);
        _next_block();
    }
    fn execute_admin_set_paused(sys: TesterSys, sender: ContractAddress, paused: bool) {
        testing::set_contract_address(sender);
        sys.admin.set_paused(paused);
        _next_block();
    }
    fn execute_admin_set_table(sys: TesterSys, sender: ContractAddress, table_id: felt252, contract_address: ContractAddress, description: felt252, fee_min: u256, fee_pct: u8, enabled: bool) {
        testing::set_contract_address(sender);
        sys.admin.set_table(table_id, contract_address, description, fee_min, fee_pct, enabled);
        _next_block();
    }
    fn execute_admin_enable_table(sys: TesterSys, sender: ContractAddress, table_id: felt252, enabled: bool) {
        testing::set_contract_address(sender);
        sys.admin.enable_table(table_id, enabled);
        _next_block();
    }

    // ::ierc20
    fn execute_lords_initializer(sys: TesterSys, sender: ContractAddress) {
        testing::set_contract_address(sender);
        sys.lords.initializer();
        _next_block();
    }
    fn execute_lords_faucet(sys: TesterSys, sender: ContractAddress) {
        testing::set_contract_address(sender);
        sys.lords.faucet();
        _next_block();
    }
    fn execute_lords_approve(sys: TesterSys, owner: ContractAddress, spender: ContractAddress, value: u256) {
        testing::set_contract_address(sys.owner);
        sys.lords.approve(spender, value);
        _next_block();
    }

    // ::actions
    fn execute_register_duelist(sys: TesterSys, sender: ContractAddress, name: felt252, profile_pic: u8) {
        testing::set_contract_address(sender);
        sys.actions.register_duelist(name, profile_pic);
        _next_block();
    }
    fn execute_create_challenge(sys: TesterSys, sender: ContractAddress,
        challenged: ContractAddress,
        message: felt252,
        table_id: felt252,
        wager_value: u256,
        expire_seconds: u64,
    ) -> u128 {
        testing::set_contract_address(sender);
        let duel_id: u128 = sys.actions.create_challenge(challenged, message, table_id, wager_value, expire_seconds);
        _next_block();
        (duel_id)
    }
    fn execute_reply_challenge(sys: TesterSys, sender: ContractAddress,
        duel_id: u128,
        accepted: bool,
    ) -> ChallengeState {
        testing::set_contract_address(sender);
        let new_state: ChallengeState = sys.actions.reply_challenge(duel_id, accepted);
        _next_block();
        (new_state)
    }
    fn execute_commit_action(sys: TesterSys, sender: ContractAddress,
        duel_id: u128,
        round_number: u8,
        hash: u64,
    ) {
        testing::set_contract_address(sender);
        sys.actions.commit_action(duel_id, round_number, hash);
        _next_block();
    }
    fn execute_reveal_action(sys: TesterSys, sender: ContractAddress,
        duel_id: u128,
        round_number: u8,
        salt: u64,
        slot1: u8,
        slot2: u8,
    ) {
        testing::set_contract_address(sender);
        sys.actions.reveal_action(duel_id, round_number, salt, slot1, slot2);
        _next_block();
    }

    //
    // read-only calls
    //

    // fn execute_get_pact(system: IActionsDispatcher, a: ContractAddress, b: ContractAddress) -> u128 {
    //     let result: u128 = sys.actions.get_pact(a, b);
    //     (result)
    // }

    //
    // getters
    //

    #[inline(always)]
    fn get_Config(sys: TesterSys) -> Config {
        (get!(sys.world, 1, Config))
    }
    #[inline(always)]
    fn get_Table(sys: TesterSys, table_id: felt252) -> TTable {
        (get!(sys.world, table_id, TTable))
    }
    #[inline(always)]
    fn get_Duelist(sys: TesterSys, address: ContractAddress) -> Duelist {
        (get!(sys.world, address, Duelist))
    }
    #[inline(always)]
    fn get_Scoreboard(sys: TesterSys, address: ContractAddress, table: felt252) -> Scoreboard {
        (get!(sys.world, (address, table), Scoreboard))
    }
    #[inline(always)]
    fn get_Challenge(sys: TesterSys, duel_id: u128) -> Challenge {
        (get!(sys.world, duel_id, Challenge))
    }
    #[inline(always)]
    fn get_Snapshot(sys: TesterSys, duel_id: u128) -> Snapshot {
        (get!(sys.world, duel_id, Snapshot))
    }
    #[inline(always)]
    fn get_Wager(sys: TesterSys, duel_id: u128) -> Wager {
        (get!(sys.world, duel_id, Wager))
    }
    #[inline(always)]
    fn get_Round(sys: TesterSys, duel_id: u128, round_number: u8) -> Round {
        (get!(sys.world, (duel_id, round_number), Round))
    }
    #[inline(always)]
    fn get_Challenge_Round(sys: TesterSys, duel_id: u128) -> (Challenge, Round) {
        let challenge = get!(sys.world, duel_id, Challenge);
        let round = get!(sys.world, (duel_id, challenge.round_number), Round);
        (challenge, round)
    }

    //
    // Asserts
    //

    fn assert_balance(sys: TesterSys, address: ContractAddress, balance_before: u256, subtract: u256, add: u256, prefix: felt252) -> u256 {
        let balance: u256 = sys.ierc20.balance_of(address);
        if (subtract > add) {
            assert(balance < balance_before, String::concat(prefix, ' <'));
        } else if (add > subtract) {
            assert(balance > balance_before, String::concat(prefix, ' >'));
        } else {
            assert(balance == balance_before, String::concat(prefix, ' =='));
        }
        assert(balance == balance_before - subtract + add, String::concat(prefix, ' =>'));
        (balance)
    }

    fn assert_winner_balance(sys: TesterSys,
        winner: u8,
        duelist_a: ContractAddress, duelist_b: ContractAddress,
        balance_a: u256, balance_b: u256,
        fee: u256, wager_value: u256,
        prefix: felt252,
    ) {
        if (winner == 1) {
            assert_balance(sys, duelist_a, balance_a, fee, wager_value, String::concat('A_A_', prefix));
            assert_balance(sys, duelist_b, balance_b, fee + wager_value, 0, String::concat('A_B_', prefix));
        } else if (winner == 2) {
            assert_balance(sys, duelist_a, balance_a, fee + wager_value, 0, String::concat('B_A_', prefix));
            assert_balance(sys, duelist_b, balance_b, fee, wager_value, String::concat('B_B_', prefix));
        } else {
            assert_balance(sys, duelist_a, balance_a, fee, 0, String::concat('D_A_', prefix));
            assert_balance(sys, duelist_b, balance_b, fee, 0, String::concat('D_B_', prefix));
        }
    }


}

#[cfg(test)]
mod tests {
    use core::traits::{Into, TryInto};
    use debug::PrintTrait;
    use starknet::{ContractAddress};

    // https://github.com/starkware-libs/cairo/blob/main/corelib/src/pedersen.cairo
    extern fn pedersen(a: felt252, b: felt252) -> felt252 implicits(Pedersen) nopanic;

    #[test]
    #[available_gas(1_000_000)]
    fn test_utils() {
        assert(true != false, 'utils');
    }

    #[test]
    #[available_gas(1_000_000)]
    fn test_pedersen_hash() {
        let a: felt252 = 0x49d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7;
        let b: felt252 = 0x4d07e40e93398ed3c76981e72dd1fd22557a78ce36c0515f679e27f0bb5bc5f;
        let a_b = pedersen(a, b);
        let b_a = pedersen(b, a);
        // pedersen hashes are DIFFERENT for (a,b) and (b,a)
        assert(a_b != b_a, 'pedersen');
    }

    #[test]
    #[available_gas(1_000_000)]
    fn test_pedersen_hash_from_zero() {
        let a: felt252 = 0;
        let b: felt252 = 0x4d07e40e93398ed3c76981e72dd1fd22557a78ce36c0515f679e27f0bb5bc5f;
        let a_b = pedersen(a, b);
        // pedersen hashes are DIFFERENT if (a == zero)
        assert(a_b != b, 'pedersen');
    }

    #[test]
    #[available_gas(1_000_000)]
    fn test_xor_hash() {
        let a: felt252 = 0x49d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7;
        let b: felt252 = 0x4d07e40e93398ed3c76981e72dd1fd22557a78ce36c0515f679e27f0bb5bc5f;
        let aa: u256 = a.into();
        let bb: u256 = b.into();
        let a_b = aa ^ bb;
        let b_a = bb ^ aa;
        // xor hashes are EQUAL for (a,b) and (b,a)
        assert(a_b == b_a, 'felt_to_u128');
    }
}
