/* Autogenerated file. Do not edit manually. */

import { defineComponent, Type as RecsType, World } from "@dojoengine/recs";

export function defineContractComponents(world: World) {
  return {
	  Coin: (() => {
	    return defineComponent(
	      world,
	      { key: RecsType.Number, contract_address: RecsType.BigInt, description: RecsType.BigInt, fee_min: RecsType.BigInt, fee_pct: RecsType.Number, enabled: RecsType.Boolean },
	      {
	        metadata: {
	          name: "Coin",
	          types: ["u8","contractaddress","felt252","u256","u8","bool"],
	          customTypes: [],
	        },
	      }
	    );
	  })(),
	  Config: (() => {
	    return defineComponent(
	      world,
	      { key: RecsType.Number, initialized: RecsType.Boolean, owner_address: RecsType.BigInt, treasury_address: RecsType.BigInt, paused: RecsType.Boolean },
	      {
	        metadata: {
	          name: "Config",
	          types: ["u8","bool","contractaddress","contractaddress","bool"],
	          customTypes: [],
	        },
	      }
	    );
	  })(),
	  Challenge: (() => {
	    return defineComponent(
	      world,
	      { duel_id: RecsType.BigInt, duelist_a: RecsType.BigInt, duelist_b: RecsType.BigInt, message: RecsType.BigInt, state: RecsType.Number, round_number: RecsType.Number, winner: RecsType.Number, timestamp_start: RecsType.Number, timestamp_end: RecsType.Number },
	      {
	        metadata: {
	          name: "Challenge",
	          types: ["u128","contractaddress","contractaddress","felt252","u8","u8","u8","u64","u64"],
	          customTypes: [],
	        },
	      }
	    );
	  })(),
	  Duelist: (() => {
	    return defineComponent(
	      world,
	      { address: RecsType.BigInt, name: RecsType.BigInt, profile_pic: RecsType.Number, total_duels: RecsType.Number, total_wins: RecsType.Number, total_losses: RecsType.Number, total_draws: RecsType.Number, total_honour: RecsType.Number, honour: RecsType.Number, timestamp: RecsType.Number },
	      {
	        metadata: {
	          name: "Duelist",
	          types: ["contractaddress","felt252","u8","u16","u16","u16","u16","u32","u8","u64"],
	          customTypes: [],
	        },
	      }
	    );
	  })(),
	  Pact: (() => {
	    return defineComponent(
	      world,
	      { pair: RecsType.BigInt, duel_id: RecsType.BigInt },
	      {
	        metadata: {
	          name: "Pact",
	          types: ["u128","u128"],
	          customTypes: [],
	        },
	      }
	    );
	  })(),
	  Round: (() => {
	    return defineComponent(
	      world,
	      { duel_id: RecsType.BigInt, round_number: RecsType.Number, state: RecsType.Number, shot_a: { hash: RecsType.Number, salt: RecsType.Number, action: RecsType.Number, chance_crit: RecsType.Number, chance_hit: RecsType.Number, dice_crit: RecsType.Number, dice_hit: RecsType.Number, damage: RecsType.Number, block: RecsType.Number, win: RecsType.Number, wager: RecsType.Number, health: RecsType.Number, honour: RecsType.Number }, shot_b: { hash: RecsType.Number, salt: RecsType.Number, action: RecsType.Number, chance_crit: RecsType.Number, chance_hit: RecsType.Number, dice_crit: RecsType.Number, dice_hit: RecsType.Number, damage: RecsType.Number, block: RecsType.Number, win: RecsType.Number, wager: RecsType.Number, health: RecsType.Number, honour: RecsType.Number } },
	      {
	        metadata: {
	          name: "Round",
	          types: ["u128","u8","u8","u64","u64","u16","u8","u8","u8","u8","u8","u8","u8","u8","u8","u8","u64","u64","u16","u8","u8","u8","u8","u8","u8","u8","u8","u8","u8"],
	          customTypes: ["Shot","Shot"],
	        },
	      }
	    );
	  })(),
	  Wager: (() => {
	    return defineComponent(
	      world,
	      { duel_id: RecsType.BigInt, coin: RecsType.Number, value: RecsType.BigInt, fee: RecsType.BigInt },
	      {
	        metadata: {
	          name: "Wager",
	          types: ["u128","u8","u256","u256"],
	          customTypes: [],
	        },
	      }
	    );
	  })(),
	  InitializableModel: (() => {
	    return defineComponent(
	      world,
	      { token: RecsType.BigInt, initialized: RecsType.Boolean },
	      {
	        metadata: {
	          name: "InitializableModel",
	          types: ["contractaddress","bool"],
	          customTypes: [],
	        },
	      }
	    );
	  })(),
	  ERC20AllowanceModel: (() => {
	    return defineComponent(
	      world,
	      { token: RecsType.BigInt, owner: RecsType.BigInt, spender: RecsType.BigInt, amount: RecsType.BigInt },
	      {
	        metadata: {
	          name: "ERC20AllowanceModel",
	          types: ["contractaddress","contractaddress","contractaddress","u256"],
	          customTypes: [],
	        },
	      }
	    );
	  })(),
	  ERC20BalanceModel: (() => {
	    return defineComponent(
	      world,
	      { token: RecsType.BigInt, account: RecsType.BigInt, amount: RecsType.BigInt },
	      {
	        metadata: {
	          name: "ERC20BalanceModel",
	          types: ["contractaddress","contractaddress","u256"],
	          customTypes: [],
	        },
	      }
	    );
	  })(),
	  ERC20BridgeableModel: (() => {
	    return defineComponent(
	      world,
	      { token: RecsType.BigInt, l2_bridge_address: RecsType.BigInt },
	      {
	        metadata: {
	          name: "ERC20BridgeableModel",
	          types: ["contractaddress","contractaddress"],
	          customTypes: [],
	        },
	      }
	    );
	  })(),
	  ERC20MetadataModel: (() => {
	    return defineComponent(
	      world,
	      { token: RecsType.BigInt, name: RecsType.BigInt, symbol: RecsType.BigInt, decimals: RecsType.Number, total_supply: RecsType.BigInt },
	      {
	        metadata: {
	          name: "ERC20MetadataModel",
	          types: ["contractaddress","felt252","felt252","u8","u256"],
	          customTypes: [],
	        },
	      }
	    );
	  })(),
  };
}
