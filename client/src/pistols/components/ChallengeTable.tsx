import React, { useEffect, useMemo, useState } from 'react'
import { Grid, SemanticCOLORS, Table } from 'semantic-ui-react'
import { useDuelist } from '@/pistols/hooks/useDuelist'
import { useAllChallengeIds, useChallenge, useChallengeIdsByDuelist, useLiveChallengeIds, usePastChallengeIds } from '@/pistols/hooks/useChallenge'
import { useDojoAccount } from '@/dojo/DojoContext'
import { ProfilePicSquare } from '@/pistols/components/account/ProfilePic'
import { MenuKey, usePistolsContext } from '@/pistols/hooks/PistolsContext'
import { ChallengeState, ChallengeStateNames } from '@/pistols/utils/pistols'
import { formatTimestamp, formatTimestampDelta } from '@/pistols/utils/utils'
import { useTimestampCountdown } from '../hooks/useTimestamp'

const Row = Grid.Row
const Col = Grid.Column
const Cell = Table.Cell
const HeaderCell = Table.HeaderCell

export function ChallengeTableAll() {
  const { challengeIds } = useAllChallengeIds()
  return <ChallengeTableByIds challengeIds={challengeIds} />
}

export function ChallengeTableLive() {
  const { challengeIds } = useLiveChallengeIds()
  return <ChallengeTableByIds challengeIds={challengeIds} color='green' />
}

export function ChallengeTablePast() {
  const { challengeIds } = usePastChallengeIds()
  return <ChallengeTableByIds challengeIds={challengeIds} color='red' />
}

export function ChallengeTableByDuelist({
  address = null,
}) {
  const { challengeIds } = useChallengeIdsByDuelist(address)
  return <ChallengeTableByIds challengeIds={challengeIds} />
}

export function ChallengeTableYour() {
  const { account } = useDojoAccount()
  return <ChallengeTableByDuelist address={account.address} />
}



function ChallengeTableByIds({
  challengeIds,
  color = 'orange'
}) {
  const [order, setOrder] = useState({})
  const _sortCallback = (id, state, timestamp) => {
    setOrder(o => ({ ...o, [id]: { state, timestamp } }))
  }

  const rows = useMemo(() => {
    let result = []
    challengeIds.forEach((duelId, index) => {
      result.push(<DuelItem key={duelId} duelId={duelId} sortCallback={_sortCallback} />)
    })
    return result
  }, [challengeIds])

  const sortedRows = useMemo(() => rows.sort((a, b) => {
    if (order[a.key]?.state != order[b.key]?.state) {
      if (order[a.key]?.state == ChallengeState.InProgress) return -1
      if (order[b.key]?.state == ChallengeState.InProgress) return 1
      if (order[a.key]?.state == ChallengeState.Awaiting) return -1
      if (order[b.key]?.state == ChallengeState.Awaiting) return 1
    }
    return (order[b.key]?.timestamp ?? 0) - (order[a.key]?.timestamp ?? 0)
  }), [rows, order])

  return (
    <Table sortable selectable className='Faded' color={color as SemanticCOLORS}>
      <Table.Header className='TableHeader'>
        <Table.Row textAlign='left' verticalAlign='middle'>
          <HeaderCell width={1}></HeaderCell>
          <HeaderCell>Challenger</HeaderCell>
          <HeaderCell width={1}></HeaderCell>
          <HeaderCell>Challenged</HeaderCell>
          <HeaderCell width={2} textAlign='center'>State</HeaderCell>
          <HeaderCell width={4} textAlign='center'>Time</HeaderCell>
        </Table.Row>
      </Table.Header>

      {sortedRows.length > 0 ?
        <Table.Body className='TableBody'>
          {sortedRows}
        </Table.Body>
        :
        <Table.Footer fullWidth>
          <Table.Row>
            <Cell colSpan='100%' textAlign='center'>
              no duels here
            </Cell>
          </Table.Row>
        </Table.Footer>
      }
    </Table>
  )
}


function DuelItem({
  duelId,
  sortCallback,
}) {
  const { account } = useDojoAccount()
  const { dispatchSetDuel } = usePistolsContext()
  const { duelistA, duelistB, state, isLive, winner, timestamp, timestamp_expire, timestamp_start, timestamp_end } = useChallenge(duelId)
  const { name: nameA, profilePic: profilePicA } = useDuelist(duelistA)
  const { name: nameB, profilePic: profilePicB } = useDuelist(duelistB)
  const timestamp_system = useTimestampCountdown()
  // console.log(timestamp, timestamp_expire, `>`, timestamp_system)
  
  useEffect(() => {
    sortCallback(duelId, state, timestamp)
  }, [state, timestamp])

  const isYours = useMemo(() => (BigInt(account.address) == duelistA || BigInt(account.address) == duelistB), [account, duelistA, duelistB])
  const winnerIsA = useMemo(() => (duelistA == winner), [duelistA, winner])
  const winnerIsB = useMemo(() => (duelistB == winner), [duelistB, winner])
  const isAwaiting = useMemo(() => [ChallengeState.Awaiting].includes(state), [state])
  const isInProgress = useMemo(() => [ChallengeState.InProgress].includes(state), [state])
  const isCanceled = useMemo(() => [ChallengeState.Withdrawn, ChallengeState.Refused].includes(state), [state])
  const isDraw = useMemo(() => [ChallengeState.Draw].includes(state), [state])

  const date = useMemo(() => {
    if (isAwaiting) return '⏱️ ' + formatTimestampDelta(timestamp_system, timestamp_expire)
    if (isInProgress || winnerIsA || winnerIsB) return /*'⚔️ ' +*/ formatTimestamp(timestamp_start)
    if (isCanceled) return /*'🚫 ' +*/ formatTimestamp(timestamp_end)
    if (isDraw) return /*'🤝 ' +*/ formatTimestamp(timestamp_end)
    return formatTimestamp(timestamp)
  }, [state, timestamp, timestamp_expire, timestamp_start, timestamp_end])

  const _gotoChallenge = () => {
    dispatchSetDuel(duelId, isYours ? MenuKey.YourDuels : isLive ? MenuKey.LiveDuels : MenuKey.PastDuels)
  }

  return (
    <Table.Row warning={isDraw} negative={isCanceled} positive={isInProgress || winnerIsA || winnerIsB} textAlign='left' verticalAlign='middle' onClick={() => _gotoChallenge()}>
      <Cell positive={winnerIsA} negative={winnerIsB}>
        <ProfilePicSquare profilePic={profilePicA} />
      </Cell>

      <Cell positive={winnerIsA} negative={winnerIsB}>
        {nameA}
      </Cell>

      <Cell positive={winnerIsB} negative={winnerIsA}>
        <ProfilePicSquare profilePic={profilePicB} />
      </Cell>

      <Cell positive={winnerIsB} negative={winnerIsA}>
        {nameB}
      </Cell>

      <Cell textAlign='center'>
        {ChallengeStateNames[state]}
      </Cell>

      <Cell textAlign='center'>
        {date}
      </Cell>
    </Table.Row>
  )
}

