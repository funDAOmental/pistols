#[cfg(test)]
mod tests {
    use debug::PrintTrait;
    use core::traits::Into;
    use starknet::{ContractAddress};

    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

    use pistols::systems::admin::{IAdminDispatcher, IAdminDispatcherTrait};
    use pistols::models::config::{Config};
    use pistols::models::table::{TTable, tables};
    use pistols::systems::utils::{zero_address};
    use pistols::types::constants::{constants};
    use pistols::tests::tester::{tester};

    const INVALID_TABLE: felt252 = 'TheBookIsOnTheTable';

    //
    // Initialize
    //

    #[test]
    #[available_gas(1_000_000_000)]
    // #[should_panic(expected:('Not initialized','ENTRYPOINT_FAILED'))]
    fn test_initialize_defaults() {
        let sys = tester::setup_world_sys(false, false);
        let config: Config = sys.admin.get_config();
        assert(config.initialized == false, 'initialized == false');
        tester::execute_admin_initialize(sys, sys.owner, zero_address(), zero_address(), zero_address());
        let config: Config = sys.admin.get_config();
        assert(config.initialized == true, 'initialized == true');
        assert(config.owner_address == sys.owner, 'owner_address');
        assert(config.treasury_address == sys.owner, 'treasury_address');
        assert(config.paused == false, 'paused');
        // get
        let get_config: Config = tester::get_Config(sys);
        assert(config.initialized == get_config.initialized, 'get_config.initialized');
        assert(config.owner_address == get_config.owner_address, 'get_config.owner_address');
        assert(config.treasury_address == get_config.treasury_address, 'get_config.treasury_address');
        assert(config.paused == get_config.paused, 'get_config.paused');
    }

    #[test]
    #[available_gas(1_000_000_000)]
    fn test_set_owner_defaults() {
        let sys = tester::setup_world_sys(false, false);
        tester::execute_admin_initialize(sys, sys.owner, zero_address(), zero_address(), zero_address());
        let config: Config = sys.admin.get_config();
        assert(config.owner_address == sys.owner, 'owner_address_param');
        // set
        let new_owner: ContractAddress = starknet::contract_address_const::<0x121212>();
        tester::execute_admin_set_owner(sys, sys.owner, new_owner);
        let config: Config = sys.admin.get_config();
        assert(config.owner_address == new_owner, 'set_owner_new');
        // set
        tester::execute_admin_set_owner(sys, new_owner, sys.bummer);
        let config: Config = sys.admin.get_config();
        assert(config.owner_address == sys.bummer, 'owner_address_newer');
    }

    #[test]
    #[available_gas(1_000_000_000)]
    fn test_set_owner() {
        let sys = tester::setup_world_sys(false, false);
        tester::execute_admin_initialize(sys, sys.owner, sys.other, zero_address(), zero_address());
        let config: Config = sys.admin.get_config();
        assert(config.owner_address == sys.other, 'owner_address_param');
        // set
        tester::execute_admin_set_owner(sys, sys.other, sys.bummer);
        let config: Config = sys.admin.get_config();
        assert(config.owner_address == sys.bummer, 'set_owner_new');
    }

    #[test]
    #[available_gas(1_000_000_000)]
    fn test_set_treasury() {
        let sys = tester::setup_world_sys(false, false);
        tester::execute_admin_initialize(sys, sys.owner, zero_address(), sys.other, zero_address());
        let config: Config = sys.admin.get_config();
        assert(config.treasury_address == sys.other, 'treasury_address_param');
        // set
        let new_treasury: ContractAddress = starknet::contract_address_const::<0x121212>();
        tester::execute_admin_set_treasury(sys, sys.owner, new_treasury);
        let config: Config = sys.admin.get_config();
        assert(config.treasury_address == new_treasury, 'set_treasury_new');
        // set
        tester::execute_admin_set_treasury(sys, sys.owner, sys.bummer);
        let config: Config = sys.admin.get_config();
        assert(config.treasury_address == sys.bummer, 'treasury_address_newer');
    }

    #[test]
    #[available_gas(1_000_000_000)]
    #[should_panic(expected:('Null owner_address','ENTRYPOINT_FAILED'))]
    fn test_set_owner_null() {
        let sys = tester::setup_world_sys(false, false);
        tester::execute_admin_initialize(sys, sys.owner, zero_address(), zero_address(), zero_address());
        tester::execute_admin_set_owner(sys, sys.owner, zero_address());
    }

    #[test]
    #[available_gas(1_000_000_000)]
    #[should_panic(expected:('Null treasury_address','ENTRYPOINT_FAILED'))]
    fn test_set_treasury_null() {
        let sys = tester::setup_world_sys(false, false);
        tester::execute_admin_initialize(sys, sys.owner, zero_address(), zero_address(), zero_address());
        tester::execute_admin_set_treasury(sys, sys.owner, zero_address());
    }

    #[test]
    #[available_gas(1_000_000_000)]
    fn test_set_paused() {
        let sys = tester::setup_world_sys(false, false);
        tester::execute_admin_initialize(sys, sys.owner, zero_address(), zero_address(), zero_address());
        let config: Config = sys.admin.get_config();
        assert(config.paused == false, 'paused_1');
        // set
        tester::execute_admin_set_paused(sys, sys.owner, true);
        let config: Config = sys.admin.get_config();
        assert(config.paused == true, 'paused_2');
        // set
        tester::execute_admin_set_paused(sys, sys.owner, false);
        let config: Config = sys.admin.get_config();
        assert(config.paused == false, 'paused_3');
    }

    #[test]
    #[available_gas(1_000_000_000)]
    #[should_panic(expected:('Already initialized','ENTRYPOINT_FAILED'))]
    fn test_initialized() {
        let sys = tester::setup_world_sys(false, false);
        tester::execute_admin_initialize(sys, sys.owner, zero_address(), zero_address(), zero_address());
        tester::execute_admin_initialize(sys, sys.owner, zero_address(), zero_address(), zero_address());
    }

    #[test]
    #[available_gas(1_000_000_000)]
    #[should_panic(expected:('Not initialized','ENTRYPOINT_FAILED'))]
    fn test_set_owner_not_initialized() {
        let sys = tester::setup_world_sys(false, false);
        tester::execute_admin_set_owner(sys, sys.owner, zero_address());
    }

    #[test]
    #[available_gas(1_000_000_000)]
    #[should_panic(expected:('Not initialized','ENTRYPOINT_FAILED'))]
    fn test_set_treasury_not_initialized() {
        let sys = tester::setup_world_sys(false, false);
        tester::execute_admin_set_treasury(sys, sys.owner, zero_address());
    }

    #[test]
    #[available_gas(1_000_000_000)]
    #[should_panic(expected:('Not deployer','ENTRYPOINT_FAILED'))]
    fn test_initialize_not_deployer() {
        let sys = tester::setup_world_sys(false, false);
        tester::execute_admin_initialize(sys, sys.other, zero_address(), zero_address(), zero_address());
    }

    #[test]
    #[available_gas(1_000_000_000)]
    #[should_panic(expected:('Not owner','ENTRYPOINT_FAILED'))]
    fn test_set_owner_not_owner() {
        let sys = tester::setup_world_sys(false, false);
        tester::execute_admin_initialize(sys, sys.owner, zero_address(), zero_address(), zero_address());
        let new_treasury: ContractAddress = starknet::contract_address_const::<0x121212>();
        tester::execute_admin_set_owner(sys, sys.other, new_treasury);
    }

    #[test]
    #[available_gas(1_000_000_000)]
    #[should_panic(expected:('Not owner','ENTRYPOINT_FAILED'))]
    fn test_set_treasury_not_owner() {
        let sys = tester::setup_world_sys(false, false);
        tester::execute_admin_initialize(sys, sys.owner, zero_address(), zero_address(), zero_address());
        let new_treasury: ContractAddress = starknet::contract_address_const::<0x121212>();
        tester::execute_admin_set_treasury(sys, sys.other, new_treasury);
    }

    #[test]
    #[available_gas(1_000_000_000)]
    #[should_panic(expected:('Not owner','ENTRYPOINT_FAILED'))]
    fn test_set_paused_not_owner() {
        let sys = tester::setup_world_sys(false, false);
        tester::execute_admin_initialize(sys, sys.owner, zero_address(), zero_address(), zero_address());
        tester::execute_admin_set_paused(sys, sys.other, true);
    }

    //
    // Tables
    //

    #[test]
    #[available_gas(1_000_000_000)]
    fn test_initialize_table_defaults() {
        let sys = tester::setup_world_sys(false, false);
        tester::execute_admin_initialize(sys, sys.owner, zero_address(), zero_address(), zero_address());
        let table: TTable = sys.admin.get_table(tables::LORDS);
        assert(table.contract_address == zero_address(), 'contract_address');
        assert(table.is_open == false, 'enabled');
    }

    #[test]
    #[available_gas(1_000_000_000)]
    fn test_initialize_table() {
        let sys = tester::setup_world_sys(false, false);
        tester::execute_admin_initialize(sys, sys.owner, zero_address(), zero_address(), sys.lords.contract_address);
        let table: TTable = sys.admin.get_table(tables::LORDS);
        assert(table.contract_address == sys.lords.contract_address, 'contract_address');
        assert(table.fee_min == 4 * constants::ETH_TO_WEI, 'fee_min');
        assert(table.fee_pct == 10, 'fee_pct');
        assert(table.is_open == true, 'enabled');
    }

    #[test]
    #[available_gas(1_000_000_000)]
    fn test_set_table() {
        let sys = tester::setup_world_sys(false, false);
        // not initialized
        tester::execute_admin_initialize(sys, sys.owner, zero_address(), zero_address(), zero_address());
        let table: TTable = sys.admin.get_table(tables::LORDS);
        assert(table.contract_address == zero_address(), 'zero');
        assert(table.is_open == false, 'zero');
        // set
        tester::execute_admin_set_table(sys, sys.owner, tables::LORDS, sys.lords.contract_address, 'LORDS+', 5, 10, true);
        let table: TTable = sys.admin.get_table(tables::LORDS);
        assert(table.contract_address == sys.lords.contract_address, 'contract_address_1');
        assert(table.description == 'LORDS+', 'description_1');
        assert(table.fee_min == 5, 'fee_min_1');
        assert(table.fee_pct == 10, 'fee_pct_1');
        assert(table.is_open == true, 'enabled_1');
        // set
        tester::execute_admin_set_table(sys, sys.owner, tables::LORDS, sys.other, 'LORDS+++', 22, 33, false);
        let table: TTable = sys.admin.get_table(tables::LORDS);
        assert(table.contract_address == sys.other, 'contract_address_2');
        assert(table.description == 'LORDS+++', 'description_2');
        assert(table.fee_min == 22, 'fee_min_2');
        assert(table.fee_pct == 33, 'fee_pct_2');
        assert(table.is_open == false, 'enabled_2');
        // get
        let table: TTable = tester::get_Table(sys, tables::LORDS);
        assert(table.contract_address == table.contract_address, 'get_table.contract_address');
        assert(table.fee_min == table.fee_min, 'get_table.fee_min');
        assert(table.fee_pct == table.fee_pct, 'get_table.fee_pct');
        assert(table.is_open == table.is_open, 'get_table.is_open');
    }

    #[test]
    #[available_gas(1_000_000_000)]
    #[should_panic(expected:('Invalid table','ENTRYPOINT_FAILED'))]
    fn test_set_table_count() {
        let sys = tester::setup_world_sys(true, false);
        let _table: TTable = sys.admin.get_table(INVALID_TABLE);
        // assert(table.contract_address == sys.lords.contract_address, 'zero');
        // // set must work
        // tester::execute_admin_set_table(sys, sys.owner, INVALID_TABLE, sys.bummer, 'LORDS+', 5, 10, true);
        // let table: TTable = sys.admin.get_table(INVALID_TABLE);
        // assert(table.contract_address == sys.bummer, 'contract_address');
        // assert(table.description == 'LORDS+', 'description');
        // assert(table.fee_min == 5, 'fee_min');
        // assert(table.fee_pct == 10, 'fee_pct');
        // assert(table.is_open == true, 'enabled');
    }

    #[test]
    #[available_gas(1_000_000_000)]
    fn test_enable_table_count() {
        let sys = tester::setup_world_sys(true, false);
        tester::execute_admin_set_table(sys, sys.owner, tables::LORDS, sys.lords.contract_address, 'LORDS+', 5, 10, false);
        let table: TTable = sys.admin.get_table(tables::LORDS);
        assert(table.is_open == false, 'enabled_1');
        tester::execute_admin_enable_table(sys, sys.owner, tables::LORDS, true);
        let table: TTable = sys.admin.get_table(tables::LORDS);
        assert(table.is_open == true, 'enabled_2');
        tester::execute_admin_enable_table(sys, sys.owner, tables::LORDS, false);
        let table: TTable = sys.admin.get_table(tables::LORDS);
        assert(table.is_open == false, 'enabled_3');
    }

    #[test]
    #[available_gas(1_000_000_000)]
    #[should_panic(expected:('Not owner','ENTRYPOINT_FAILED'))]
    fn test_set_table_not_owner() {
        let sys = tester::setup_world_sys(true, false);
        tester::execute_admin_set_table(sys, sys.other, tables::LORDS, sys.lords.contract_address, 'LORDS+', 5, 10, true);
    }

    #[test]
    #[available_gas(1_000_000_000)]
    #[should_panic(expected:('Not owner','ENTRYPOINT_FAILED'))]
    fn test_enable_table_not_owner() {
        let sys = tester::setup_world_sys(true, false);
        tester::execute_admin_enable_table(sys, sys.other, tables::LORDS, true);
    }

    #[test]
    #[available_gas(1_000_000_000)]
    #[should_panic(expected:('Invalid table','ENTRYPOINT_FAILED'))]
    fn test_set_table_zero() {
        let sys = tester::setup_world_sys(true, false);
        tester::execute_admin_set_table(sys, sys.owner, 0, sys.lords.contract_address, 'LORDS+', 5, 10, true);
    }

    #[test]
    #[available_gas(1_000_000_000)]
    #[should_panic(expected:('Invalid table','ENTRYPOINT_FAILED'))]
    fn test_set_table_invalid() {
        let sys = tester::setup_world_sys(true, false);
        tester::execute_admin_set_table(sys, sys.owner, INVALID_TABLE, sys.lords.contract_address, 'LORDS+', 5, 10, true);
    }

    #[test]
    #[available_gas(1_000_000_000)]
    #[should_panic(expected:('Invalid table','ENTRYPOINT_FAILED'))]
    fn test_enable_table_zero() {
        let sys = tester::setup_world_sys(true, false);
        tester::execute_admin_enable_table(sys, sys.owner, 0, false);
    }

    #[test]
    #[available_gas(1_000_000_000)]
    #[should_panic(expected:('Invalid table','ENTRYPOINT_FAILED'))]
    fn test_enable_table_invalid() {
        let sys = tester::setup_world_sys(true, false);
        tester::execute_admin_enable_table(sys, sys.owner, INVALID_TABLE, false);
    }


}
