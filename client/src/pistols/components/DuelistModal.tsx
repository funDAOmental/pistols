import React, { useMemo } from 'react'
import { useRouter } from 'next/navigation'
import { Grid, Modal, Icon } from 'semantic-ui-react'
import { useDojoAccount } from '@/lib/dojo/DojoContext'
import { usePistolsContext } from '@/pistols/hooks/PistolsContext'
import { useDuelist } from '@/pistols/hooks/useDuelist'
import { usePact } from '@/pistols/hooks/usePact'
import { ProfilePic } from '@/pistols/components/account/ProfilePic'
import { ProfileDescription } from '@/pistols/components/account/ProfileDescription'
import { ChallengeTableByDuelist } from '@/pistols/components/ChallengeTable'
import { ActionButton } from '@/pistols/components/ui/Buttons'
import { AddressShort } from '@/lib/ui/AddressShort'

const Row = Grid.Row
const Col = Grid.Column

export default function DuelistModal() {
  const { accountAddress, isGuest, isThisAccount } = useDojoAccount()
  const router = useRouter()

  const { duelistAddress, dispatchSelectDuel, dispatchSelectDuelist, dispatchChallengedDuelist } = usePistolsContext()
  const isOpen = useMemo(() => (duelistAddress > 0), [duelistAddress])
  const isYou = useMemo(() => isThisAccount(duelistAddress), [duelistAddress, isThisAccount])

  const _close = () => { dispatchSelectDuelist(0n) }

  const { profilePic } = useDuelist(duelistAddress)
  const { hasPact, pactDuelId } = usePact(accountAddress, duelistAddress)

  return (
    <Modal
      // size='small'
      // dimmer='inverted'
      onClose={() => _close()}
      open={isOpen}
    >
      <Modal.Header>
        <Grid>
          <Row columns={'equal'}>
            <Col textAlign='left'>
              Duelist
            </Col>
            <Col textAlign='center'>
              {isYou &&
                <div className='Anchor' onClick={() => router.push(`/gate`)} >
                  <span className='Smaller'>Switch Duelist</span>
                  &nbsp;
                  <Icon name='sign out' size={'small'} />
                </div>
              }
            </Col>
            <Col textAlign='right'>
              <AddressShort address={duelistAddress} />
            </Col>
          </Row>
        </Grid>
      </Modal.Header>
      <Modal.Content image>
        <ProfilePic profilePic={profilePic} />
        <Modal.Description className='FillParent'>
          <div className='DuelistModalDescription'>
            <ProfileDescription address={duelistAddress} displayStats displayBalance />
            <div className='Spacer10' />
            <div className='TableInModal'>
              <ChallengeTableByDuelist address={duelistAddress} compact />
            </div>
          </div>
        </Modal.Description>
      </Modal.Content>
      <Modal.Actions className='NoPadding'>
        <Grid className='FillParent Padded' textAlign='center'>
          <Row columns='equal'>
            <Col>
              <ActionButton fill label='Close' onClick={() => _close()} />
            </Col>
            {!isYou &&
              <Col>
                {hasPact && <ActionButton fill important label='Challenge In Progress!' onClick={() => dispatchSelectDuel(pactDuelId)} />}
                {!hasPact && <ActionButton fill disabled={isGuest} label='Challenge for a Duel!' onClick={() => dispatchChallengedDuelist(duelistAddress)} />}
              </Col>
            }
          </Row>
        </Grid>
      </Modal.Actions>
    </Modal>
  )
}
