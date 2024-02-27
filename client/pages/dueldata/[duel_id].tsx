import React, { useEffect, useMemo } from 'react'
import { useRouter } from 'next/router'
import { Container, Divider, Table } from 'semantic-ui-react'
import { bigintToHex, formatTimestamp } from '@/pistols/utils/utils'
import AppDojo from '@/pistols/components/AppDojo'
import { useDuel } from '@/pistols/hooks/useDuel'
import { useDuelist } from '@/pistols/hooks/useDuelist'
import { ActionEmojis, ActionNames, ChallengeStateNames, RoundState, RoundStateNames } from '@/pistols/utils/pistols'

const Row = Table.Row
const Cell = Table.Cell
const Body = Table.Body
const Header = Table.Header
const HeaderCell = Table.HeaderCell

export default function StatsPage() {
  const router = useRouter()
  const { duel_id } = router.query

  return (
    <AppDojo title={'Duel'} backgroundImage={null}>
      {router.isReady &&
        <DuelStats duelId={BigInt(duel_id as string)} />
      }
    </AppDojo>
  );
}

function DuelStats({
  duelId
}: {
  duelId: bigint
}) {
  const { challenge, round1, round2, round3 } = useDuel(duelId)
  const { name: nameA } = useDuelist(challenge.duelistA)
  const { name: nameB } = useDuelist(challenge.duelistB)

  return (
    <Container text>
      <Divider />

      <div className='Code'>
        <Table celled striped>
          <Header>
            <Row>
              <HeaderCell width={4}><h5>Challenge</h5></HeaderCell>
              <HeaderCell>{bigintToHex(duelId)}</HeaderCell>
            </Row>
          </Header>

          <Body>
            <Row>
              <Cell>Challenger</Cell>
              <Cell>
                <b>{nameA}</b>
                <br />
                {bigintToHex(challenge.duelistA)}
              </Cell>
            </Row>
            <Row>
              <Cell>Challenged</Cell>
              <Cell>
                <b>{nameB}</b>
                <br />
                {bigintToHex(challenge.duelistB)}
              </Cell>
            </Row>
            <Row>
              <Cell>State</Cell>
              <Cell>
                {challenge.state}: {ChallengeStateNames[challenge.state]}
              </Cell>
            </Row>
            <Row>
              <Cell>Round Number</Cell>
              <Cell>
                {challenge.roundNumber}
              </Cell>
            </Row>
            <Row>
              <Cell>Winner</Cell>
              <Cell>
                {challenge.winner}: {challenge.winner == 1 ? 'Challenger' : challenge.winner == 2 ? 'Challenged' : null}
              </Cell>
            </Row>
            <Row>
              <Cell>Timestamp Start</Cell>
              <Cell>
                {formatTimestamp(challenge.timestamp_end)}
              </Cell>
            </Row>
            <Row>
              <Cell>Timestamp End</Cell>
              <Cell>
                {formatTimestamp(challenge.timestamp_end)}
              </Cell>
            </Row>
            <Row>
              <Cell>Message</Cell>
              <Cell>
                {challenge.message}
              </Cell>
            </Row>
          </Body>
        </Table>

        {round1 && <>
          <br />
          <RoundStats duelId={duelId} roundNumber={1} round={round1} />
        </>}
        {round2 && <>
          <br />
          <RoundStats duelId={duelId} roundNumber={2} round={round2} />
        </>}
        {round3 && <>
          <br />
          <RoundStats duelId={duelId} roundNumber={3} round={round3} />
        </>}

      </div>
      <Divider />
    </Container>
  )
}

function RoundStats({
  roundNumber,
  round,
}: {
  duelId: bigint
  roundNumber: number
  round: any
}) {

  return (
    <>
      <Table celled striped attached='top'>
        <Header>
          <Row>
            <HeaderCell width={4}><h5>Round</h5></HeaderCell>
            <HeaderCell><h2>{roundNumber}</h2></HeaderCell>
          </Row>
        </Header>

        <Body>
          <Row>
            <Cell>State</Cell>
            <Cell>
              {round.state}: {RoundStateNames[round.state]}
            </Cell>
          </Row>
        </Body>
      </Table>

      <ShotStats shot={round.shot_a} shotNumber='A' title='Challenger' />
      <ShotStats shot={round.shot_b} shotNumber='B' title='Challenged' />
    </>
  )
}

function ShotStats({
  shotNumber,
  title,
  shot,
}) {

  return (
    <>
      <Table attached>
        <Header fullWidth>
          <Row >
            <HeaderCell width={4}><h5>Shot {shotNumber}</h5></HeaderCell>
            <HeaderCell><h5>{title}</h5></HeaderCell>
          </Row>
        </Header>

        <Body>
          <Row>
            <Cell>Hash</Cell>
            <Cell>
              {bigintToHex(shot.hash)}
            </Cell>
          </Row>
          <Row>
            <Cell>Salt</Cell>
            <Cell>
              {bigintToHex(shot.salt)}
            </Cell>
          </Row>
          <Row>
            <Cell>Action</Cell>
            <Cell>
              {shot.action}: {ActionNames[shot.action]} {ActionEmojis[shot.action]}
            </Cell>
          </Row>
          <Row>
            <Cell>Crit Dice / Chances</Cell>
            <Cell>
              {shot.chance_crit} / {shot.dice_crit}
            </Cell>
          </Row>
          <Row>
            <Cell>Hit Dice / Chances</Cell>
            <Cell>
              {shot.chance_hit} / {shot.dice_hit}
            </Cell>
          </Row>
        </Body>
      </Table>

      <Table attached>
        <Header fullWidth>
          <Row>
            <HeaderCell><h5>Damage</h5></HeaderCell>
            <HeaderCell><h5>Block</h5></HeaderCell>
            <HeaderCell><h5>Health</h5></HeaderCell>
            <HeaderCell><h5>Honour</h5></HeaderCell>
            <HeaderCell><h5>Win</h5></HeaderCell>
            <HeaderCell><h5>Wager</h5></HeaderCell>
          </Row>
        </Header>

        <Body>
          <Row>
            <Cell>{shot.damage}</Cell>
            <Cell>{shot.block}</Cell>
            <Cell>{shot.health}</Cell>
            <Cell>{shot.honour}</Cell>
            <Cell>{shot.win}</Cell>
            <Cell>{shot.wager}</Cell>
          </Row>
        </Body>
      </Table>
    </>
  )
}
