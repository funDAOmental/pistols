import React from 'react'
import { usePistolsContext } from '@/pistols/hooks/PistolsContext'
import { TavernAudios } from '@/pistols/components/GameContainer'
import { TavernMenu } from '@/pistols/components/TavernMenu'
import PlayerSwitcher from '@/pistols/components/PlayerSwitcher'
import ConnectionDetector from './account/ConnectionDetector'
import TableModal from '@/pistols/components/TableModal'
import DuelistModal from '@/pistols/components/DuelistModal'
import ChallengeModal from '@/pistols/components/ChallengeModal'

export default function Tavern() {
  const { tableOpener } = usePistolsContext()

  return (
    <>
      <div className='UIContainerTavern'>
        <TavernMenu />
      </div>

      <PlayerSwitcher />

      <TableModal opener={tableOpener} />
      <DuelistModal />
      <ChallengeModal />
      <TavernAudios />

      <ConnectionDetector />
    </>
  )
}
