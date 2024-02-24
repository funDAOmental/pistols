import { useEffect, useState } from 'react'
import { useDojoSystemCalls } from '@/dojo/DojoContext'
import { BigNumberish } from 'starknet'

export const useCalcHitBonus = (address: BigNumberish, defaultValue = null) => {
  const [value, setValue] = useState(defaultValue)
  const { calc_hit_bonus } = useDojoSystemCalls()
  useEffect(() => {
    let _mounted = true
    const _get = async () => {
      const value = await calc_hit_bonus(BigInt(address))
      if (_mounted) setValue(value)
    }
    if (address != null) _get()
    else setValue(defaultValue)
    return () => { _mounted = false }
  }, [address])
  return {
    hitBonus: value,
  }
}

export const useCalcHitChances = (address: BigNumberish, duelId: bigint, roundNumber: number, action: number, defaultValue = null) => {
  const [value, setValue] = useState(defaultValue)
  const { calc_hit_chances } = useDojoSystemCalls()
  useEffect(() => {
    let _mounted = true
    const _get = async () => {
      const value = await calc_hit_chances(BigInt(address), duelId, roundNumber, action)
      if (_mounted) setValue(value)
    }
    if (address != null && duelId && roundNumber && action != null) _get()
    else setValue(defaultValue)
    return () => { _mounted = false }
  }, [address, duelId, roundNumber, action])
  return {
    hitChances: value,
  }
}

export const useCalcCritChances = (address: BigNumberish, duelId: bigint, roundNumber: number, action: number, defaultValue = null) => {
  const [value, setValue] = useState(defaultValue)
  const { calc_crit_chances } = useDojoSystemCalls()
  useEffect(() => {
    let _mounted = true
    const _get = async () => {
      const value = await calc_crit_chances(BigInt(address), duelId, roundNumber, action)
      if (_mounted) setValue(value)
    }
    if (address != null && duelId && roundNumber && action != null) _get()
    else setValue(defaultValue)
    return () => { _mounted = false }
  }, [address, duelId, roundNumber, action])
  return {
    critChances: value,
  }
}

export const useCalcGlanceChances = (address: BigNumberish, duelId: bigint, roundNumber: number, action: number, defaultValue = null) => {
  const [value, setValue] = useState(defaultValue)
  const { calc_glance_chances } = useDojoSystemCalls()
  useEffect(() => {
    let _mounted = true
    const _get = async () => {
      const value = await calc_glance_chances(BigInt(address), duelId, roundNumber, action)
      if (_mounted) setValue(value)
    }
    if (address != null && duelId && roundNumber && action != null) _get()
    else setValue(defaultValue)
    return () => { _mounted = false }
  }, [address, duelId, roundNumber, action])
  return {
    glanceChances: value,
  }
}

export const useCalcHonourForAction = (address: BigNumberish, action: number, defaultValue = null) => {
  const [value, setValue] = useState(defaultValue)
  const { calc_honour_for_action } = useDojoSystemCalls()
  useEffect(() => {
    let _mounted = true
    const _get = async () => {
      const value = await calc_honour_for_action(BigInt(address), action)
      if (_mounted) setValue(value)
    }
    if (address != null && action != null) _get()
    else setValue(defaultValue)
    return () => { _mounted = false }
  }, [address, action])
  return {
    honourForAction: value,
  }
}

export const useGetValidPackedActions = (round_number: number, defaultValue = []) => {
  const [value, setValue] = useState(defaultValue)
  const { get_valid_packed_actions } = useDojoSystemCalls()
  useEffect(() => {
    let _mounted = true
    const _get = async () => {
      const value = await get_valid_packed_actions(round_number)
      if (_mounted) setValue(value)
    }
    if (round_number != null) _get()
    else setValue(defaultValue)
    return () => { _mounted = false }
  }, [round_number])
  return {
    validPackedActions: value,
  }
}

// export const usePackActionSlots = (slot1: number, slot2: number, defaultValue = null) => {
//   const [value, setValue] = useState(defaultValue)
//   const { pack_action_slots } = useDojoSystemCalls()
//   useEffect(() => {
//     let _mounted = true
//     const _get = async () => {
//       const value = await pack_action_slots(slot1, slot2)
//       if (_mounted) setValue(value)
//     }
//     if (slot1 != null && slot2 != null) _get()
//     else setValue(defaultValue)
//     return () => { _mounted = false }
//   }, [slot1, slot2])
//   return {
//     packed: value,
//   }
// }

// export const useUnpackActionSlots = (packed: number, defaultValue = []) => {
//   const [value, setValue] = useState(defaultValue)
//   const { unpack_action_slots } = useDojoSystemCalls()
//   useEffect(() => {
//     let _mounted = true
//     const _get = async () => {
//       const value = await unpack_action_slots(packed)
//       if (_mounted) setValue(value)
//     }
//     if (packed != null) _get()
//     else setValue(defaultValue)
//     return () => { _mounted = false }
//   }, [packed])
//   return {
//     unpacked: value,
//   }
// }