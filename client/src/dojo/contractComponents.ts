/* Autogenerated file. Do not edit manually. */

import { defineComponent, Type as RecsType, World } from "@dojoengine/recs";

export type ContractComponents = Awaited<ReturnType<typeof defineContractComponents>>;

export function defineContractComponents(world: World) {
  return {
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
        { duel_id: RecsType.BigInt, duelist_a: RecsType.BigInt, duelist_b: RecsType.BigInt, message: RecsType.BigInt, table_id: RecsType.BigInt, state: RecsType.Number, round_number: RecsType.Number, winner: RecsType.Number, timestamp_start: RecsType.BigInt, timestamp_end: RecsType.BigInt },
        {
          metadata: {
            name: "Challenge",
            types: ["u128","contractaddress","contractaddress","felt252","felt252","u8","u8","u8","u64","u64"],
            customTypes: [],
          },
        }
      );
    })(),
    Chances: (() => {
      return defineComponent(
        world,
        { key: RecsType.BigInt, crit_chances: RecsType.Number, crit_bonus: RecsType.Number, hit_chances: RecsType.Number, hit_bonus: RecsType.Number, lethal_chances: RecsType.Number, lethal_bonus: RecsType.Number },
        {
          metadata: {
            name: "Chances",
            types: ["felt252","u8","u8","u8","u8","u8","u8"],
            customTypes: [],
          },
        }
      );
    })(),
    Duelist: (() => {
      return defineComponent(
        world,
        { address: RecsType.BigInt, name: RecsType.BigInt, profile_pic: RecsType.Number, score: { honour: RecsType.Number, level_villain: RecsType.Number, level_trickster: RecsType.Number, level_lord: RecsType.Number, total_duels: RecsType.Number, total_wins: RecsType.Number, total_losses: RecsType.Number, total_draws: RecsType.Number, total_honour: RecsType.Number }, timestamp: RecsType.BigInt },
        {
          metadata: {
            name: "Duelist",
            types: ["contractaddress","felt252","u8","u8","u8","u8","u8","u16","u16","u16","u16","u32","u64"],
            customTypes: ["Score"],
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
        { duel_id: RecsType.BigInt, round_number: RecsType.Number, state: RecsType.Number, shot_a: { hash: RecsType.BigInt, salt: RecsType.BigInt, action: RecsType.Number, chance_crit: RecsType.Number, chance_hit: RecsType.Number, dice_crit: RecsType.Number, dice_hit: RecsType.Number, damage: RecsType.Number, block: RecsType.Number, win: RecsType.Number, wager: RecsType.Number, health: RecsType.Number, honour: RecsType.Number }, shot_b: { hash: RecsType.BigInt, salt: RecsType.BigInt, action: RecsType.Number, chance_crit: RecsType.Number, chance_hit: RecsType.Number, dice_crit: RecsType.Number, dice_hit: RecsType.Number, damage: RecsType.Number, block: RecsType.Number, win: RecsType.Number, wager: RecsType.Number, health: RecsType.Number, honour: RecsType.Number } },
        {
          metadata: {
            name: "Round",
            types: ["u128","u8","u8","u64","u64","u16","u8","u8","u8","u8","u8","u8","u8","u8","u8","u8","u64","u64","u16","u8","u8","u8","u8","u8","u8","u8","u8","u8","u8"],
            customTypes: ["Shot","Shot"],
          },
        }
      );
    })(),
    Scoreboard: (() => {
      return defineComponent(
        world,
        { address: RecsType.BigInt, table_id: RecsType.BigInt, score: { honour: RecsType.Number, level_villain: RecsType.Number, level_trickster: RecsType.Number, level_lord: RecsType.Number, total_duels: RecsType.Number, total_wins: RecsType.Number, total_losses: RecsType.Number, total_draws: RecsType.Number, total_honour: RecsType.Number }, wager_won: RecsType.BigInt, wager_lost: RecsType.BigInt },
        {
          metadata: {
            name: "Scoreboard",
            types: ["contractaddress","felt252","u8","u8","u8","u8","u16","u16","u16","u16","u32","u256","u256"],
            customTypes: ["Score"],
          },
        }
      );
    })(),
    Snapshot: (() => {
      return defineComponent(
        world,
        { duel_id: RecsType.BigInt, score_a: { honour: RecsType.Number, level_villain: RecsType.Number, level_trickster: RecsType.Number, level_lord: RecsType.Number, total_duels: RecsType.Number, total_wins: RecsType.Number, total_losses: RecsType.Number, total_draws: RecsType.Number, total_honour: RecsType.Number }, score_b: { honour: RecsType.Number, level_villain: RecsType.Number, level_trickster: RecsType.Number, level_lord: RecsType.Number, total_duels: RecsType.Number, total_wins: RecsType.Number, total_losses: RecsType.Number, total_draws: RecsType.Number, total_honour: RecsType.Number } },
        {
          metadata: {
            name: "Snapshot",
            types: ["u128","u8","u8","u8","u8","u16","u16","u16","u16","u32","u8","u8","u8","u8","u16","u16","u16","u16","u32"],
            customTypes: ["Score","Score"],
          },
        }
      );
    })(),
    Wager: (() => {
      return defineComponent(
        world,
        { duel_id: RecsType.BigInt, value: RecsType.BigInt, fee: RecsType.BigInt },
        {
          metadata: {
            name: "Wager",
            types: ["u128","u256","u256"],
            customTypes: [],
          },
        }
      );
    })(),
    Table: (() => {
      return defineComponent(
        world,
        { table_id: RecsType.BigInt, description: RecsType.BigInt, contract_address: RecsType.BigInt, wager_min: RecsType.BigInt, fee_min: RecsType.BigInt, fee_pct: RecsType.Number, is_open: RecsType.Boolean },
        {
          metadata: {
            name: "Table",
            types: ["felt252","felt252","contractaddress","u256","u256","u8","bool"],
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
