import React, { useEffect, useState } from 'react'
import { Divider, Grid, Modal, Pagination } from 'semantic-ui-react'
import { useDojoAccount, useDojoSystemCalls } from '@/dojo/DojoContext'
import { ActionButton } from '@/pistols/components/ui/Buttons'
import { signAndGenerateMoveHash } from '@/pistols/utils/salt'
import ProgressBar from '@/pistols/components/ui/ProgressBar'

const Row = Grid.Row
const Col = Grid.Column

export default function CommitStepsModal({
  isOpen,
  setIsOpen,
  duelId,
  roundNumber = 1,
}: {
  isOpen: boolean
  setIsOpen: Function
  duelId: bigint
  roundNumber?: number
}) {
  const { commit_move, get_pistols_bonus, get_pistols_hit_chance, get_pistols_kill_chance } = useDojoSystemCalls()
  const { account } = useDojoAccount()

  const [steps, setSteps] = useState(0)
  const [bonus, setBonus] = useState(null)
  const [chanceToHit, setChanceToHit] = useState(0)
  const [chanceToKill, setChanceToKill] = useState(0)
  const [isSubmitting, setIsSubmitting] = useState(false)

  useEffect(() => {
    setSteps(0)
  }, [isOpen])

  useEffect(() => {
    let _mounted = true
    const _getBonus = async () => {
      const value = await get_pistols_bonus(BigInt(account.address))
      console.log(`BNUS:`, value)
      if (_mounted) setBonus(value)
    }
    const _getHit = async () => {
      const value = await get_pistols_hit_chance(BigInt(account.address), steps)
      if (_mounted) setChanceToHit(value)
    }
    const _getKill = async () => {
      const value = await get_pistols_kill_chance(BigInt(account.address), steps)
      if (_mounted) setChanceToKill(value)
    }
    if (steps) {
      _getBonus()
      _getHit()
      _getKill()
    } else {
      setBonus(null)
      setChanceToHit(0)
      setChanceToKill(0)
    }
    return () => {
      _mounted = false
    }

  }, [steps])

  const _submit = async () => {
    if (steps) {
      setIsSubmitting(true)
      const hash = await signAndGenerateMoveHash(account, duelId, roundNumber, steps)
      if (hash) {
        await commit_move(account, duelId, roundNumber, hash)
        setIsOpen(false)
      }
      setIsSubmitting(false)
    }
  }

  return (
    <Modal
      size='small'
      // dimmer='inverted'
      onClose={() => setIsOpen(false)}
      open={isOpen}
    >
      <Modal.Header className='AlignCenter'><h4>How many steps will you take?</h4></Modal.Header>
      <Modal.Content>
        <Modal.Description className='AlignCenter'>
          <div className='ModalText'>
            <p>
              An honourable Lord will take all the <b>10 steps</b> before shooting.
              <br />
              Choose wisely. 👑
            </p>
            <Pagination
              size='huge'
              boundaryRange={10}
              defaultActivePage={null}
              ellipsisItem={null}
              firstItem={null}
              lastItem={null}
              prevItem={null}
              nextItem={null}
              siblingRange={1}
              totalPages={10}
              onPageChange={(e, { activePage }) => setSteps(typeof activePage == 'number' ? activePage : parseInt(activePage))}
            />
          </div>

          <Divider hidden />
          
          <ProgressBar disabled={!steps} label='Chances to Hit:' percent={chanceToHit} className='ChancesBar'/>
          <ProgressBar disabled={!steps} label='Chances to Kill:' percent={chanceToKill} className='ChancesBar' />
          <ProgressBar disabled={!steps} label='Honour:' value={steps ?? 0} total={10} className='ChancesBar' />

          <p className='ModalText'>&nbsp;
            {bonus > 0 && <>(Includes <b>{bonus}%</b> Honour bonus)</>}
            {bonus === 0 && <>Keep your Honour <b>{'>'} 9.0</b> for a bonus</>}
          </p>

        </Modal.Description>
      </Modal.Content>
      <Modal.Actions>
        <Grid className='FillParent Padded' textAlign='center'>
          <Row columns='equal'>
            <Col>
              <ActionButton fill label='Close' onClick={() => setIsOpen(false)} />
            </Col>
            <Col>
              <ActionButton fill attention label='Commit...' disabled={!steps || isSubmitting} onClick={() => _submit()} />
            </Col>
          </Row>
        </Grid>
      </Modal.Actions>
    </Modal>
  )
}