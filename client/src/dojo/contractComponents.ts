/* Autogenerated file. Do not edit manually. */

import { defineComponent, Type as RecsType, World } from "@dojoengine/recs";

export function defineContractComponents(world: World) {
  return {
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
	          types: ["contractaddress","felt252","u8","u32","u32","u32","u32","u32","u8","u64"],
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
	      { duel_id: RecsType.BigInt, round_number: RecsType.Number, state: RecsType.Number, duelist_a: { hash: RecsType.BigInt, salt: RecsType.Number, move: RecsType.Number, damage: RecsType.Number, health: RecsType.Number }, duelist_b: { hash: RecsType.BigInt, salt: RecsType.Number, move: RecsType.Number, damage: RecsType.Number, health: RecsType.Number } },
	      {
	        metadata: {
	          name: "Round",
	          types: ["u128","u8","u8","felt252","u64","u8","u8","u8","felt252","u64","u8","u8","u8"],
	          customTypes: ["Move","Move"],
	        },
	      }
	    );
	  })(),
  };
}
