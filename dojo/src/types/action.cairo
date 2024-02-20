use traits::Into;
use debug::PrintTrait;

use pistols::types::constants::{constants};
use pistols::utils::math::{MathU8};

// constants
mod ACTION {
    const IDLE: u8 = 0;
    const PACES_MASK: u8 = 0x0f;
    const BLADES_MASK: u8 = 0xf0;
    // Paces
    const PACES_1: u8 = 1;
    const PACES_2: u8 = 2;
    const PACES_3: u8 = 3;
    const PACES_4: u8 = 4;
    const PACES_5: u8 = 5;
    const PACES_6: u8 = 6;
    const PACES_7: u8 = 7;
    const PACES_8: u8 = 8;
    const PACES_9: u8 = 9;
    const PACES_10: u8 = 10;
    // Blades
    const FAST_BLADE: u8 = 0x10;
    const SLOW_BLADE: u8 = 0x20;
    const BLOCK: u8 = 0x30;
    // const FLEE: u8 = 0x40;
    // const STEAL: u8 = 0x50;
    // const SEPPUKU: u8 = 0x60;
}

#[derive(Copy, Drop, Serde, PartialEq, Introspect)]
enum Action {
    Idle,
    // Paces
    Paces1,
    Paces2,
    Paces3,
    Paces4,
    Paces5,
    Paces6,
    Paces7,
    Paces8,
    Paces9,
    Paces10,
    // Blades
    FastBlade,
    SlowBlade,
    Block,
}


//--------------------------------------
// Traits
//

trait ActionTrait {
    fn is_paces(self: Action) -> bool;
    fn is_blades(self: Action) -> bool;
    fn as_paces(self: Action) -> u8;
    fn crit_chance(self: Action) -> u8;
    fn hit_chance(self: Action) -> u8;
}

impl ActionTraitImpl of ActionTrait {
    fn is_paces(self: Action) -> bool {
        match self {
            Action::Idle =>         false,
            Action::Paces1 =>       true,
            Action::Paces2 =>       true,
            Action::Paces3 =>       true,
            Action::Paces4 =>       true,
            Action::Paces5 =>       true,
            Action::Paces6 =>       true,
            Action::Paces7 =>       true,
            Action::Paces8 =>       true,
            Action::Paces9 =>       true,
            Action::Paces10 =>      true,
            Action::FastBlade =>    false,
            Action::SlowBlade =>    false,
            Action::Block =>        false,
        }
    }
    fn is_blades(self: Action) -> bool {
        match self {
            Action::Idle =>         false,
            Action::Paces1 =>       false,
            Action::Paces2 =>       false,
            Action::Paces3 =>       false,
            Action::Paces4 =>       false,
            Action::Paces5 =>       false,
            Action::Paces6 =>       false,
            Action::Paces7 =>       false,
            Action::Paces8 =>       false,
            Action::Paces9 =>       false,
            Action::Paces10 =>      false,
            Action::FastBlade =>    true,
            Action::SlowBlade =>    true,
            Action::Block =>        true,
        }
    }
    fn as_paces(self: Action) -> u8 {
        if (self.is_paces()) { self.into() } else { (ACTION::IDLE) }
    }

    //-----------------
    // Flat chances
    //
    fn crit_chance(self: Action) -> u8 {
        if (self.is_paces()) {
            (MathU8::map(self.as_paces(), 1, 10, constants::PISTOLS_KILL_CHANCE_AT_STEP_1, constants::PISTOLS_KILL_CHANCE_AT_STEP_10))
        } else if (self.is_blades()) {
            (constants::BLADES_HIT_CHANCE)
        } else {
            (0)
        }
    }
    fn hit_chance(self: Action) -> u8 {
        if (self.is_paces()) {
            (MathU8::map(self.as_paces(), 1, 10, constants::PISTOLS_HIT_CHANCE_AT_STEP_1, constants::PISTOLS_HIT_CHANCE_AT_STEP_10))
        } else if (self.is_blades()) {
            (constants::BLADES_KILL_CHANCE)
        } else {
            (0)
        }
    }
}




//--------------------------------------
// Into / TryInto
//

impl ActionIntoU8 of Into<Action, u8> {
    fn into(self: Action) -> u8 {
        match self {
            Action::Idle =>         ACTION::IDLE,
            // Paces
            Action::Paces1 =>       ACTION::PACES_1,
            Action::Paces2 =>       ACTION::PACES_2,
            Action::Paces3 =>       ACTION::PACES_3,
            Action::Paces4 =>       ACTION::PACES_4,
            Action::Paces5 =>       ACTION::PACES_5,
            Action::Paces6 =>       ACTION::PACES_6,
            Action::Paces7 =>       ACTION::PACES_7,
            Action::Paces8 =>       ACTION::PACES_8,
            Action::Paces9 =>       ACTION::PACES_9,
            Action::Paces10 =>      ACTION::PACES_10,
            // Blades
            Action::FastBlade =>    ACTION::FAST_BLADE,
            Action::SlowBlade =>    ACTION::SLOW_BLADE,
            Action::Block =>        ACTION::BLOCK,
        }
    }
}

impl ActionIntoU16 of Into<Action, u16> {
    fn into(self: Action) -> u16 {
        let action: u8 = self.into();
        return action.into();
    }
}

impl U8IntoAction of Into<u8, Action> {
    fn into(self: u8) -> Action {
        if self == ACTION::IDLE             { Action::Idle }
        // Paces
        else if self == ACTION::PACES_1     { Action::Paces1 }
        else if self == ACTION::PACES_2     { Action::Paces2 }
        else if self == ACTION::PACES_3     { Action::Paces3 }
        else if self == ACTION::PACES_4     { Action::Paces4 }
        else if self == ACTION::PACES_5     { Action::Paces5 }
        else if self == ACTION::PACES_6     { Action::Paces6 }
        else if self == ACTION::PACES_7     { Action::Paces7 }
        else if self == ACTION::PACES_8     { Action::Paces8 }
        else if self == ACTION::PACES_9     { Action::Paces9 }
        else if self == ACTION::PACES_10    { Action::Paces10 }
        // Blades
        else if self == ACTION::FAST_BLADE  { Action::FastBlade }
        else if self == ACTION::SLOW_BLADE  { Action::SlowBlade }
        else if self == ACTION::BLOCK       { Action::Block }
        // invalid is always Idle
        else { Action::Idle }
    }
}

impl U16IntoAction of Into<u16, Action> {
    fn into(self: u16) -> Action {
        let action: u8 = self.try_into().unwrap();
        return action.into();
    }
}


//--------------------------------------
// PrintTrait
//

impl ActionIntoFelt252 of Into<Action, felt252> {
    fn into(self: Action) -> felt252 {
        match self {
            Action::Idle =>         'Idle',
            // Paces
            Action::Paces1 =>       '1 Pace',
            Action::Paces2 =>       '2 Paces',
            Action::Paces3 =>       '3 Paces',
            Action::Paces4 =>       '4 Paces',
            Action::Paces5 =>       '5 Paces',
            Action::Paces6 =>       '6 Paces',
            Action::Paces7 =>       '7 Paces',
            Action::Paces8 =>       '8 Paces',
            Action::Paces9 =>       '9 Paces',
            Action::Paces10 =>      '10 Paces',
            // Blades
            Action::FastBlade =>    'Fast Blade',
            Action::SlowBlade =>    'Slow Blade',
            Action::Block =>        'Block',
        }
    }
}

impl PrintAction of PrintTrait<Action> {
    fn print(self: Action) {
        let num: felt252 = self.into();
        num.print();
    }
}




//----------------------------------------
// Unit  tests
//
#[cfg(test)]
mod tests {
    use debug::PrintTrait;
    use core::traits::Into;
    use core::traits::TryInto;

    use pistols::types::action::{Action, ActionTrait, ACTION};

    #[test]
    #[available_gas(1_000_000)]
    fn test_paces() {
        assert(0_u8 == Action::Idle.into(), 'Action > 0');
        assert(1_u8 == Action::Paces1.into(), 'Action > 1');
        assert(2_u8 == Action::Paces2.into(), 'Action > 2');
        assert(3_u8 == Action::Paces3.into(), 'Action > 3');
        assert(4_u8 == Action::Paces4.into(), 'Action > 4');
        assert(5_u8 == Action::Paces5.into(), 'Action > 5');
        assert(6_u8 == Action::Paces6.into(), 'Action > 6');
        assert(7_u8 == Action::Paces7.into(), 'Action > 7');
        assert(8_u8 == Action::Paces8.into(), 'Action > 8');
        assert(9_u8 == Action::Paces9.into(), 'Action > 9');
        assert(10_u8 == Action::Paces10.into(), 'Action > 10');

        assert(Action::Idle == 0_u8.into(), '0 > Action');
        assert(Action::Paces1 == 1_u8.into(), '1 > Action');
        assert(Action::Paces2 == 2_u8.into(), '2 > Action');
        assert(Action::Paces3 == 3_u8.into(), '3 > Action');
        assert(Action::Paces4 == 4_u8.into(), '4 > Action');
        assert(Action::Paces5 == 5_u8.into(), '5 > Action');
        assert(Action::Paces6 == 6_u8.into(), '6 > Action');
        assert(Action::Paces7 == 7_u8.into(), '7 > Action');
        assert(Action::Paces8 == 8_u8.into(), '8 > Action');
        assert(Action::Paces9 == 9_u8.into(), '9 > Action');
        assert(Action::Paces10 == 10_u8.into(), '10 > Steps');
    }

    #[test]
    #[available_gas(1_000_000_000)]
    fn test_is_paces() {
        let mut n: u8 = 0;
        loop {
            if (n > 0xf0) {
                break;
            }
            let action: Action = n.into();
            if (action != Action::Idle) {
                // let paces: u8 = action.into();
                // assert(paces == n, 'Action value is pace');
                let is_pace = action.is_paces();
                assert(is_pace == (n >= 1 && n <= 10), 'action.is_paces()');
                if (is_pace) {
                    let paces: u8 = action.as_paces();
                    assert(paces == n, 'action.as_paces()');
                }
            }
            n += 1;
        }
    }

    #[test]
    #[available_gas(1_000_000_000)]
    fn test_mask() {
        let mut n: u8 = 0;
        loop {
            if (n > 0xf0) {
                break;
            }
            let action: Action = n.into();
            if (action != Action::Idle) {
                let is_pace = action.is_paces();
                if (is_pace) {
                    assert(n & ACTION::PACES_MASK == n, 'pace & ACTION::PACES_MASK');
                    assert(n & ACTION::BLADES_MASK == 0, 'pace & ACTION::BLADES_MASK');
                } else {
                    assert(n & ACTION::PACES_MASK == 0, 'blade & ACTION::PACES_MASK');
                    assert(n & ACTION::BLADES_MASK == n, 'blade & ACTION::BLADES_MASK');
                }
            }
            n += 1;
        }
    }
}
