import React, { useEffect, useMemo, useState } from 'react'
import { useRouter } from 'next/navigation'
import { Grid, Table, Modal, Form, Divider, Dropdown } from 'semantic-ui-react'
import { useDojoAccount, useDojoSystemCalls } from '@/dojo/DojoContext'
import { MenuKey, usePistolsContext } from '@/pistols/hooks/PistolsContext'
import { useDuelist } from '@/pistols/hooks/useDuelist'
import { ProfileDescription } from '@/pistols/components/account/ProfileDescription'
import { ProfilePic } from '@/pistols/components/account/ProfilePic'
import { ChallengeTableByDuelist } from '@/pistols/components/ChallengeTable'
import { ActionButton } from '@/pistols/components/ui/Buttons'
import { ChallengeMessages } from '@/pistols/utils/pistols'
import { useEffectOnce } from '@/pistols/hooks/useEffectOnce'
import { randomArrayElement, validateCairoString } from '@/pistols/utils/utils'
import { usePact } from '@/pistols/hooks/usePact'

const Row = Grid.Row
const Col = Grid.Column
const Cell = Table.HeaderCell

export default function DuelistModal() {
  const { create_challenge } = useDojoSystemCalls()
  const { account } = useDojoAccount()

  const { atDuelists, duelistAddress, dispatchSetDuelist, dispatchSetDuel } = usePistolsContext()
  const { name, profilePic } = useDuelist(duelistAddress)
  const { hasPact, pactDuelId } = usePact(account.address, duelistAddress)
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

          {!isChallenging && <div className='TableModal'><ChallengesList duelistAddress={duelistAddress} /></div>}
          {isChallenging && <CreateChallenge setChallengeArgs={setChallengeArgs}/>}
        </Modal.Description>
      </Modal.Content>
      <Modal.Actions>
        <Grid className='FillParent Padded' textAlign='center'>
          <Row columns='equal'>
            <Col>
              {!isChallenging && <ActionButton fill label='Close' onClick={() => _close()} />}
              {isChallenging && <ActionButton fill label='Cancel Challenge' onClick={() => setIsChallenging(false)} />}
            </Col>
            {!isYou &&
              <Col>
                {
                  hasPact ? <ActionButton fill label='Go to Challenge' onClick={() => dispatchSetDuel(pactDuelId, MenuKey.YourDuels)} />
                    : isChallenging ? <ActionButton fill disabled={!challengeArgs} label='Submit Challenge!' onClick={() => _challenge()} />
                      : <ActionButton fill label='Challenge for a Duel!' onClick={() => setIsChallenging(true)} />
                }
              </Col>
            }
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
      <ChallengeTableByDuelist address={duelistAddress} />
    </div>
  )
}

function CreateChallenge({
  setChallengeArgs
}) {
  const [message, setMessage] = useState('')
  const [days, setDays] = useState(1)
  const [hours, setHours] = useState(0)
  const [lords, setLords] = useState(0)

  useEffectOnce(() => {
    setMessage(randomArrayElement(ChallengeMessages))
  }, [])

  const canSubmit = useMemo(() => (message.length > 3 && (days + hours) > 0), [message, days, hours, lords])

  useEffect(() => {
    setChallengeArgs(canSubmit ? {
      message,
      expire_seconds: (days * 24 * 60 * 60) + (hours * 60 * 60),
      lords,
    } : null)
  }, [message, days, hours, lords])
  // console.log(canSubmit, days, hours, lords, message)

  const [customMessage, setCustomMessage] = useState('')
  const messageOptions: any[] = useMemo(() =>
    (ChallengeMessages.includes(customMessage) ? ChallengeMessages : [customMessage, ...ChallengeMessages]).map(msg => ({
      key: msg.replace(' ', '_'),
      value: msg,
      text: msg,
    })), [customMessage])
  const daysOptions: any[] = useMemo(() => Array.from(Array(8).keys()).map(index => ({
    key: `${index}d`,
    value: `${index}`,
    text: `${index} days`,
  })), [])
  const hoursOptions: any[] = useMemo(() => Array.from(Array(24).keys()).map(index => ({
    key: `${index}h`,
    value: `${index}`,
    text: `${index} hours`,
  })), [])

  return (
    <div>
      <Divider />

      <h1>Issue a Challenge</h1>
      <br />

      <Form>
        <Form.Field>
          <label>What do you have to say?</label>
          {/* <input placeholder={_defaultMessage} value={message} maxLength={31} onChange={(e) => setMessage(e.target.value)} /> */}
          <Dropdown
            options={messageOptions}
            placeholder={'say something!'}
            search
            selection
            fluid
            allowAdditions
            value={message}
            onAddItem={() => { }}
            onChange={(e, { value }) => {
              const _msg = validateCairoString(value as string)
              if (!ChallengeMessages.includes(_msg)) {
                setCustomMessage(_msg)
              }
              setMessage(_msg)
            }}
          />
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
        <Form.Field>
          <label>$LORDS deposit (disabled)</label>
          <input placeholder={'$LORDS'} value={lords} maxLength={6} onChange={(e) => {
            const _lords = parseInt(e.target.value as string)
            if(!isNaN(_lords)) {
              setLords(_lords)
            }
          }} />
        </Form.Field>

      </Form>


    </div>
  )
}

