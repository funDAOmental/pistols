#[cfg(test)]
mod tests {
    use core::traits::Into;
    use array::ArrayTrait;
    use debug::PrintTrait;
    use starknet::{ContractAddress};

    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

    use pistols::systems::actions::{IActionsDispatcherTrait};
    use pistols::models::models::{Duelist};
    use pistols::types::constants::{constants};
    use pistols::tests::tester::{tester};

    #[test]
    #[available_gas(1_000_000_000)]
    fn test_register_ChallengeTable() {
        let sys = tester::setup_world_sys(true, true);
        let name: felt252 = 'DuelistName';
        tester::execute_register_duelist(sys, sys.owner, name, 1);
        let duelist: Duelist = tester::get_Duelist(sys, sys.owner);
        assert(duelist.name == name, 'duelist name');
        assert(duelist.profile_pic == 1, 'duelist profile_pic');
        assert(duelist.timestamp > 0, 'duelist timestamp');
        assert(duelist.score.total_duels == 0, 'duelist total_duels');
        assert(duelist.score.total_honour == 0, 'duelist total_honour');
        assert(duelist.score.honour == 0, 'duelist honour');
    }

    #[test]
    #[available_gas(1_000_000_000)]
    fn test_register_challenged() {
        let sys = tester::setup_world_sys(true, true);
        let player1_name: felt252 = 'Player_ONE';
        let player2_name: felt252 = 'Player_TWO';
        tester::execute_register_duelist(sys, sys.owner, player1_name, 1);
        tester::execute_register_duelist(sys, sys.other, player2_name, 2);
        let player1: Duelist = tester::get_Duelist(sys, sys.owner);
        let player2: Duelist = tester::get_Duelist(sys, sys.other);
        assert(player1.name == player1_name, 'player1_name');
        assert(player2.name == player2_name, 'player2_name');
        assert(player1.profile_pic == 1, 'player1_pic');
        assert(player2.profile_pic == 2, 'player2_pic');
    }

}
