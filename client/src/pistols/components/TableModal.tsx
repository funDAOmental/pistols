import React, { useEffect, useMemo, useState } from 'react'
import { useRouter } from 'next/router'
import { Grid, Modal, Dropdown } from 'semantic-ui-react'
import { useEffectOnce } from '@/lib/utils/hooks/useEffectOnce'
import { useDojoConstants } from '@/lib/dojo/ConstantsContext'
import { useActiveDuelists, useLiveChallengeIds, usePastChallengeIds } from '@/pistols/hooks/useChallenge'
import { useRouterTable } from '@/pistols/hooks/useRouterListener'
import { useERC20TokenName } from '@/lib/utils/hooks/useERC20'
import { useTable } from '@/pistols/hooks/useTable'
import { Opener } from '@/lib/ui/useOpener'
import { Divider } from '@/lib/ui/Divider'
import { Balance } from '@/pistols/components/account/Balance'
import { ActionButton } from '@/pistols/components/ui/Buttons'
import { getKeyByValue } from '@/lib/utils/types'
import { makeTavernUrl } from '@/pistols/utils/pistols'

const Row = Grid.Row
const Col = Grid.Column

export default function TableModal({
  opener,
}: {
  opener: Opener
}) {
  const { tableId } = useRouterTable()
  const [selectedTableId, setSelectedTableId] = useState('')
  const { tableIsOpen } = useTable(selectedTableId)

  // always closed on mount
  const [mounted, setMounted] = useState(false)
  useEffectOnce(() => {
    setMounted(true)
    opener.close()
  }, [])

  // initialize
  useEffect(() => {
    if (opener.isOpen) {
      setSelectedTableId(tableId)
    }
  }, [opener.isOpen])

  const { tables } = useDojoConstants()
  const unknownTable = useMemo(() => (tableId !== undefined && getKeyByValue(tables, tableId) === undefined), [tableId])
  useEffect(() => {
    if (unknownTable && !opener.isOpen) {
      opener.open()
    }
  }, [unknownTable, opener.isOpen])
  // console.log(unknownTable, tableId, selectedTableId)

  const router = useRouter()
  const _joinTable = () => {
    router.push(makeTavernUrl(selectedTableId))
    opener.close()
  }

  return (
    <Modal
      size='tiny'
      // dimmer='inverted'
      onClose={() => opener.close()}
      open={mounted && opener.isOpen}
    >
      <Modal.Header>
        <Grid>
          <Row columns={'equal'}>
            <Col textAlign='left'>
              Tables
            </Col>
            <Col textAlign='center'>
            </Col>
            <Col textAlign='right'>
            </Col>
          </Row>
        </Grid>
      </Modal.Header>
      <Modal.Content>
        <Modal.Description className='FillParent TitleCase'>
          <TableSwitcher tableId={selectedTableId} setSelectedTableId={setSelectedTableId}/>
          <Divider hidden />
          <TableDescription tableId={selectedTableId} />
        </Modal.Description>
      </Modal.Content>
      <Modal.Actions className='NoPadding'>
        <Grid className='FillParent Padded' textAlign='center'>
          <Row columns='equal'>
            <Col>
              <ActionButton fill label='Close' onClick={() => opener.close()} />
            </Col>
            <Col>
              <ActionButton fill label='Leave Tavern' onClick={() => router.push(`/gate`)} />
            </Col>
            <Col>
              <ActionButton fill important label='Join Table' disabled={!tableIsOpen || !selectedTableId} onClick={() => _joinTable()} />
            </Col>
          </Row>
        </Grid>
      </Modal.Actions>
    </Modal>
  )
}


function TableDescription({
  tableId,
}) {
  const { contractAddress,
    description,
    wagerMin,
    feeMin,
    feePct,
    tableIsOpen,
 } = useTable(tableId)
  const { tokenName, tokenSymbol } = useERC20TokenName(contractAddress)
  const { challengeIds: liveChallengeIds } = useLiveChallengeIds(tableId)
  const { challengeIds: pastChallengeIds } = usePastChallengeIds(tableId)
  const { activeDuelistsCount } = useActiveDuelists(tableId)
  return (
    <Grid className='H4'>
      <Row className='NoPadding' verticalAlign='middle'>
        <Col width={8} textAlign='right'>
          Wager Coin:
        </Col>
        <Col width={8} className='Bold'>
          {/* {tokenName && <Balance tableId={tableId}>{tokenName}</Balance>} */}
          {/* {!tokenName && <>N/A</>} */}
          {tokenName ?? <>N/A</>}
        </Col>
      </Row>

      <Row className='NoPadding' verticalAlign='middle'>
        <Col width={8} textAlign='right'>
          Minimun Wager:
        </Col>
        <Col width={8} className='Bold'>
          <Balance tableId={tableId} wei={wagerMin} />
        </Col>
      </Row>

      <Row className='NoPadding' verticalAlign='middle'>
        <Col width={8} textAlign='right'>
          Minimun Fee:
        </Col>
        <Col width={8} className='Bold'>
          {(Boolean(feePct) && !Boolean(feeMin)) ?
            <span className='Wager'>{feePct}%</span>
            : <>
              <Balance tableId={tableId} wei={feeMin ?? 0} />
              {Boolean(feePct) && <> (or {feePct}%)</>}
            </>
          }
        </Col>
      </Row>

      <Row className='NoPadding' verticalAlign='middle'>
        <Col width={8} textAlign='right'>
          Live Duels:
        </Col>
        <Col width={8} className='Wager PaddedLeft Bold'>
          {liveChallengeIds.length}
        </Col>
      </Row>

      <Row className='NoPadding' verticalAlign='middle'>
        <Col width={8} textAlign='right'>
          Past Duels:
        </Col>
        <Col width={8} className='Wager PaddedLeft Bold'>
          {pastChallengeIds.length}
        </Col>
      </Row>

      <Row className='NoPadding' verticalAlign='middle'>
        <Col width={8} textAlign='right'>
          Active Duelists:
        </Col>
        <Col width={8} className='Wager PaddedLeft Bold'>
          {activeDuelistsCount}
        </Col>
      </Row>

      <Row columns={'equal'} className='NoPadding H5' textAlign='center'>
        <Col>
          <Divider />
          <h5>Table is {tableIsOpen ? <span className='Important'>Open</span> : <span className='Negative'>Closed</span>}</h5>
        </Col>
      </Row>

    </Grid>
  )
}

function TableSwitcher({
  tableId,
  setSelectedTableId,
}) {
  const { tables } = useDojoConstants()
  const { description } = useTable(tableId)
  return (
    <Dropdown
      text={`${description}`}
      className='icon AlignCenter Padded'
      // icon='chain'
      button
      fluid
    >
      <Dropdown.Menu>
        {Object.keys(tables).map(key => (
          <TableSwitcherItem key={tables[key]} tableId={tables[key]} setSelectedTableId={setSelectedTableId}/>
        ))}
      </Dropdown.Menu>
    </Dropdown>
  )
}

function TableSwitcherItem({
  tableId,
  setSelectedTableId,
}) {
  const { description } = useTable(tableId)
  return (
    <Dropdown.Item key={tableId} onClick={() => { setSelectedTableId(tableId) }}>{description}</Dropdown.Item>
  )
}
