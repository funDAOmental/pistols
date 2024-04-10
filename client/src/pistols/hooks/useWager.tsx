import { useMemo } from 'react'
import { getComponentValue } from '@dojoengine/recs'
import { useComponentValue } from "@dojoengine/react"
import { useDojoComponents } from '@/lib/dojo/DojoContext'
import { useChallengesByDuelist } from '@/pistols/hooks/useChallenge'
import { bigintToEntity } from '@/lib/utils/types'
import { ChallengeState } from '@/pistols/utils/pistols'
import { BigNumberish } from 'starknet'

export const useWager = (duelId: BigNumberish) => {
  const { Wager } = useDojoComponents()
  const wager: any = useComponentValue(Wager, bigintToEntity(duelId))

  return {
    coin: wager?.coin ?? null,
    value: wager?.value ?? null,
    fee: wager?.fee ?? null,
    formatted: wager?.coin ?? null,
    feeFormatted: wager?.fee ?? null,
  }
}

export const useLockedWagerTotals = (address: bigint, coin: number) => {
  const { Wager } = useDojoComponents()
  const { challenges, challengerIds } = useChallengesByDuelist(address)
  const { wagers, fees, total } = useMemo(() => {
    let wagers = 0n
    let fees = 0n
    challenges.forEach((challenge) => {
      if (challenge.state == ChallengeState.InProgress || (challenge.state == ChallengeState.Awaiting && challengerIds.includes(challenge.duel_id))) {
        const wager = getComponentValue(Wager, bigintToEntity(challenge.duel_id))
        if (wager && wager.coin == coin) {
          wagers += wager.value
          fees += wager.fee
        }
      }
    })
    return {
      wagers,
      fees,
      total: (wagers + fees)
    }

  }, [challenges])
  return {
    wagers,
    fees,
    total,
  }
}
