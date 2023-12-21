import React, { useEffect, useMemo, useState } from 'react'
import { useRouter } from 'next/navigation'
import { Grid, Table, Modal, Form, Divider, Dropdown } from 'semantic-ui-react'
import { useDojoAccount, useDojoSystemCalls } from '@/dojo/DojoContext'
import { usePistolsContext } from '@/pistols/hooks/PistolsContext'
import { useDuelist } from '@/pistols/hooks/useDuelist'
import { ProfileDescription } from '@/pistols/components/account/ProfileDescription'
import { ProfilePic } from '@/pistols/components/account/ProfilePic'
import { ChallengeListByDuelist } from './ChallengeList'
import { ActionButton } from '@/pistols/components/ui/Buttons'

const Row = Grid.Row
const Col = Grid.Column
const Cell = Table.HeaderCell

export default function DuelistModal() {
  const { create_challenge } = useDojoSystemCalls()
  const { account } = useDojoAccount()

  const { atDuelists, duelistAddress, dispatchSetDuelist } = usePistolsContext()
  const { name, profilePic } = useDuelist(duelistAddress)
  const [isChallenging, setIsChallenging] = useState(false)
  const [challengeArgs, setChallengeArgs] = useState(null)

  const isYou = useMemo(() => (duelistAddress == BigInt(account.address)), [duelistAddress, account])
  const isOpen = useMemo(() => (atDuelists && duelistAddress > 0), [atDuelists, duelistAddress])

  useEffect(() => {
    setIsChallenging(false)
  }, [isOpen])

  const _close = () => { dispatchSetDuelist(0n) }
  const _challenge = () => {
    if (challengeArgs) {
      create_challenge(account, duelistAddress, '', challengeArgs.message, challengeArgs.expire_seconds)
    }
  }
  
  return (
    <Modal
      // size='small'
      dimmer='inverted'
      onClose={() => _close()}
      // onOpen={() => setIsChallenging(false)}
      open={isOpen}
    >
      <Modal.Header>Duelist</Modal.Header>
      <Modal.Content image>
        <ProfilePic profilePic={profilePic} />
        <Modal.Description>
          <ProfileDescription address={duelistAddress} />
          <br />
          {/* <p>We've found the following gravatar image associated with your e-mail address.</p> */}

          {!isChallenging && <ChallengesList duelistAddress={duelistAddress}/>}
          {isChallenging && <CreateChallenge setChallengeArgs={setChallengeArgs}/>}
        </Modal.Description>
      </Modal.Content>
      <Modal.Actions>
        <Grid className='FillParent Padded' textAlign='center'>
          <Row columns='equal'>
            <Col>
              {!isChallenging && <ActionButton fill label='Close' onClick={() => _close()} />}
              {isChallenging && <ActionButton fill label='Cancel' onClick={() => setIsChallenging(false)} />}
            </Col>
            <Col>
              {!isChallenging && <ActionButton fill disabled={isYou} label='Challenge for a Duel!' onClick={() => setIsChallenging(true)} />}
              {isChallenging && <ActionButton fill disabled={isYou || !challengeArgs} label='Submit Challenge!' onClick={() => _challenge()}/>}
            </Col>
          </Row>
        </Grid>
      </Modal.Actions>
    </Modal>
  )
}

function ChallengesList({
  duelistAddress
}) {
  return (
    <div style={{ width: '550px' }}>
      <ChallengeListByDuelist address={duelistAddress} />
    </div>
  )
}

function CreateChallenge({
  setChallengeArgs
}) {
  const _defaultMessage = 'I challenge ya!'
  const [message, setMessage] = useState(_defaultMessage)
  const [days, setDays] = useState(1)
  const [hours, setHours] = useState(0)

  const canSubmit = useMemo(() => (message.length > 3 && days >= 1 && hours < 24), [message, days, hours])

  useEffect(() => {
    setChallengeArgs(canSubmit ? {
      message,
      expire_seconds: (days * 24 * 60 * 60) + (hours * 60 * 60),
    } : null)
  }, [canSubmit])
  // console.log(canSubmit, days, hours, message)

  const daysOptions: any[] = useMemo(() => Array.from(Array(7).keys()).map(index => ({
    key: `${index + 1}d`,
    value: `${index + 1}`,
    text: `${index + 1} days`,
  })), [])
  const hoursOptions: any[] = useMemo(() => Array.from(Array(24).keys()).map(index => ({
    key: `${index}h`,
    value: `${index}`,
    text: `${index} hours`,
  })), [])

  return (
    <div>
      <Divider />

      <h1>Create New Challenge</h1>

      <Form>
        <Form.Field>
          <label>Insult Message</label>
          <input placeholder={_defaultMessage} value={message} maxLength={31} onChange={(e) => setMessage(e.target.value)} />
        </Form.Field>
        <Form.Field>
          <label>Expiry</label>
          <Grid className='NoMargin' columns={'equal'}>
            <Row>
              <Col>
                <Dropdown defaultValue='1' placeholder='Days' selection options={daysOptions} onChange={(e, { value }) => setDays(parseInt(value as string))} />
              </Col>
              <Col>
                <Dropdown defaultValue='0' placeholder='Hours' selection options={hoursOptions} onChange={(e, { value }) => setHours(parseInt(value as string))} />
              </Col>
            </Row>
          </Grid>
        </Form.Field>

      </Form>


    </div>
  )
}

