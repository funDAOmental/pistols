use starknet::ContractAddress;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

mod coins {
    const LORDS: u8 = 1;
    // number of valid coins
    const COUNT: u8 = 1;
}

#[derive(Model, Copy, Drop, Serde)]
struct Coin {
    #[key]
    key: u8,
    //------
    contract_address: ContractAddress,
    fee_min: u8,
    fee_pct: u8,
}

#[derive(Copy, Drop)]
struct CoinManager {
    world: IWorldDispatcher
}

#[generate_trait]
impl CoinManagerTraitImpl of CoinManagerTrait {
    fn new(world: IWorldDispatcher) -> CoinManager {
        CoinManager { world }
    }

    fn exists(self: CoinManager, coin_key: u8) -> bool {
        (coin_key >= 1 && coin_key <= coins::COUNT)
    }

    fn get(self: CoinManager, coin_key: u8) -> Coin {
        get!(self.world, (coin_key), Coin)
    }

    fn set(self: CoinManager, Coin: Coin) {
        set!(self.world, (Coin));
    }
}