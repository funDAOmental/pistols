import React, { useMemo } from 'react'
import { useRouter } from 'next/navigation'
import { Grid, Table, Modal, Divider, Header } from 'semantic-ui-react'
import { useDojoAccount, useDojoSystemCalls } from '@/dojo/DojoContext'
import { usePistolsContext } from '@/pistols/hooks/PistolsContext'
import { useChallenge, useChallengeDescription } from '@/pistols/hooks/useChallenge'
import { useDuelist } from '@/pistols/hooks/useDuelist'
import { ProfileDescription } from '@/pistols/components/account/ProfileDescription'
import { ProfilePicButton } from '@/pistols/components/account/ProfilePic'
import { ActionButton } from '@/pistols/components/ui/Buttons'
import { ChallengeState, makeDuelUrl } from '@/pistols/utils/pistols'
import { AccountShort } from './ui/Account'

const Row = Grid.Row
const Col = Grid.Column
const Cell = Table.HeaderCell

export default function ChallengeModal() {
  const router = useRouter()
  const { reply_challenge } = useDojoSystemCalls()
  const { account } = useDojoAccount()

  const { atYourDuels, atLiveDuels, atPastDuels, duelId, dispatchSetDuel, dispatchSetDuelist } = usePistolsContext()

  const { state, message, duelistA, duelistB, lords } = useChallenge(duelId)

  const { challengeDescription } = useChallengeDescription(duelId)

  const { profilePic: profilePicA } = useDuelist(duelistA)
  const { profilePic: profilePicB } = useDuelist(duelistB)

  const isChallenger = useMemo(() => (duelistA == BigInt(account.address)), [duelistA, account])
  const isChallenged = useMemo(() => (duelistB == BigInt(account.address)), [duelistB, account])

  const _close = () => { dispatchSetDuel(0n) }
  const _reply = (accepted: boolean) => {
    reply_challenge(account, duelId, accepted)
  }
  const _watch = () => {
    router.push(makeDuelUrl(duelId))
  }
  
  return (
    <Modal
      // size='large'
      dimmer='inverted'
      onClose={() => _close()}
      onOpen={() => {}}
      open={(atYourDuels || atLiveDuels || atPastDuels) && duelId > 0}
    >
      <Modal.Header>Challenge&nbsp;&nbsp;&nbsp;<AccountShort address={duelId} suffix='' /></Modal.Header>
      <Modal.Content image>
        <ProfilePicButton profilePic={profilePicA} onClick={() => dispatchSetDuelist(duelistA)} />
        <Modal.Description style={{ width: '550px' }}>
          <Grid style={{ width: '350px' }}>
            <Row columns='equal' textAlign='left'>
              <Col>
                <ProfileDescription address={duelistA} />
              </Col>
            </Row>
            <Row columns='equal' textAlign='right'>
              <Col>
                <Divider horizontal>
                  <Header as='h4'>challenged</Header>
                </Divider>
              </Col>
            </Row>
            <Row columns='equal' textAlign='right'>
              <Col>
                <ProfileDescription address={duelistB} />
              </Col>
            </Row>
            <Row columns='equal' textAlign='right'>
              <Col>
                <Divider horizontal>
                  <Header as='h4'>for a duel</Header>
                </Divider>
              </Col>
            </Row>
            <Row columns='equal' textAlign='center'>
              <Col>
                <h3 className='Quote'>{`“${message}”`}</h3>
              </Col>
            </Row>
            <Row columns='equal' textAlign='right'>
              <Col>
                {lords == 0 ? <Divider /> :
                  <Divider horizontal>
                    <Header as='h4'>for <span className='Code Important'>{lords}</span> $LORDS each</Header>
                  </Divider>
                }
              </Col>
            </Row>
            <Row columns='equal' textAlign='center'>
              <Col>
                <h3>{challengeDescription}</h3>
              </Col>
            </Row>
          </Grid>
        </Modal.Description>
        <ProfilePicButton profilePic={profilePicB} onClick={() => dispatchSetDuelist(duelistB)} />
      </Modal.Content>
      <Modal.Actions>
        <Grid className='FillParent Padded' textAlign='center'>
          <Row columns='equal'>
            <Col>
              <ActionButton fill label='Close' onClick={() => _close()} />
            </Col>
            {(state == ChallengeState.Awaiting && isChallenger) &&
              <Col>
                <ActionButton fill label='Cowardly withdraw' onClick={() => _reply(false)} />
              </Col>
            }
            {(state == ChallengeState.Awaiting && isChallenged) &&
              <Col>
                <ActionButton fill label='Cowardly refuse' onClick={() => _reply(false)} />
              </Col>
            }
            {(state == ChallengeState.Awaiting && isChallenged) &&
              <Col>
                <ActionButton fill label='Accept Challenge!' onClick={() => _reply(true)} />
              </Col>
            }
            {(state == ChallengeState.InProgress) &&
              <Col>
                <ActionButton fill attention label='Go to Live Duel!' onClick={() => _watch()} />
              </Col>
            }
            {(state > ChallengeState.InProgress) &&
              <Col>
                <ActionButton fill attention label='Replay Duel!' onClick={() => _watch()} />
              </Col>
            }
          </Row>
        </Grid>
      </Modal.Actions>
    </Modal>
  )
}
