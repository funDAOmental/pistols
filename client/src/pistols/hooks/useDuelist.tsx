import { useMemo } from 'react'
import { useComponentValue } from '@dojoengine/react'
import { useDojoComponents } from '@/lib/dojo/DojoContext'
import { bigintToEntity } from '@/lib/utils/types'
import { feltToString } from "@/lib/utils/starknet"
import { useEntityKeys } from '@/lib/dojo/hooks/useEntityKeys'
import { BigNumberish } from 'starknet'


//------------------
// All Duels
//

export const useAllDuelistIds = () => {
  const { Duelist } = useDojoComponents()
  const duelistIds: bigint[] = useEntityKeys(Duelist, 'address')
  return {
    duelistIds,
    duelistCount: duelistIds.length,
  }
}


//------------------
// Single Duel
//

export const useDuelist = (address: BigNumberish) => {
  const { Duelist } = useDojoComponents()
  const duelist: any = useComponentValue(Duelist, bigintToEntity(address ?? 0n))
  // console.log(`Duelist`, address, bigintToEntity(address ?? 0n), duelist)

  const name = useMemo(() => duelist?.name ? feltToString(duelist.name) : null, [duelist])
  const profilePic = useMemo(() => (duelist?.profile_pic ?? null), [duelist])
  const isRegistered = useMemo(() => (name && name.length > 0), [name])
  const timestamp = useMemo(() => (duelist?.timestamp ?? 0), [duelist])

  // scores
  const total_duels = useMemo(() => (duelist?.score?.total_duels ?? 0), [duelist])
  const total_wins = useMemo(() => (duelist?.score?.total_wins ?? 0), [duelist])
  const total_losses = useMemo(() => (duelist?.score?.total_losses ?? 0), [duelist])
  const total_draws = useMemo(() => (duelist?.score?.total_draws ?? 0), [duelist])
  const total_honour = useMemo(() => (duelist?.score?.total_honour ?? 0), [duelist])
  const honour = useMemo(() => (parseFloat((duelist?.score?.honour ?? 0)) / 10.0), [duelist, total_duels])
  const honourDisplay = useMemo(() => (total_duels > 0 && honour > 0 ? honour.toFixed(1) : '—'), [honour, total_duels])
  const honourAndTotal = useMemo(() => (total_duels > 0 && honour > 0 ? <>{honour.toFixed(1)}<span className='Smaller'>/{total_duels}</span></> : '—'), [honour, total_duels])
  const winRatio = useMemo(() => (total_duels > 0 ? (total_wins / total_duels) : null), [total_wins, total_duels])

  const level_villain = useMemo(() => (parseFloat((duelist?.score?.level_villain ?? 0)) / 10.0), [duelist, total_duels])
  const level_trickster = useMemo(() => (parseFloat((duelist?.score?.level_trickster ?? 0)) / 10.0), [duelist, total_duels])
  const level_lord = useMemo(() => (parseFloat((duelist?.score?.level_lord ?? 0)) / 10.0), [duelist, total_duels])
  const level = useMemo(() => Math.max(level_villain, level_trickster, level_lord), [level_villain, level_trickster, level_lord])
  const levelDisplay = useMemo(() => (total_duels > 0 && level > 0 ? level.toFixed(1) : '—'), [level, total_duels])
  const levelAndTotal = useMemo(() => (total_duels > 0 && level > 0 ? <>{level.toFixed(1)}<span className='Smaller'>/{total_duels}</span></> : '—'), [level, total_duels])

  return {
    address,
    name,
    profilePic,
    isRegistered,
    timestamp,
    total_duels,
    total_wins,
    total_losses,
    total_draws,
    total_honour,
    level_villain,
    level_trickster,
    level_lord,
    level,
    levelDisplay,
    levelAndTotal,
    is_villain: (level_villain > 0),
    is_trickster: (level_trickster > 0),
    is_lord: (level_lord > 0),
    honour,
    honourDisplay,
    honourAndTotal,
    winRatio,
  }
}

