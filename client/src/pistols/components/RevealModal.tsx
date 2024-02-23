import React, { useEffect, useMemo, useState } from 'react'
import { Grid } from 'semantic-ui-react'
import { useDojoAccount, useDojoSystemCalls } from '@/dojo/DojoContext'
import { useReadValidPackedActions } from '@/pistols/hooks/useReadOnly'
import { Blades } from '@/pistols/utils/pistols'
import { signAndRestoreActionFromHash } from '../utils/salt'

const Row = Grid.Row
const Col = Grid.Column

export default function RevealModal({
  isOpen,
  setIsOpen,
  duelId,
  roundNumber,
  hash,
}: {
  isOpen: boolean
  setIsOpen: Function
  duelId: bigint
  roundNumber: number
  hash: bigint
}) {
  const { reveal_action } = useDojoSystemCalls()
  const { account } = useDojoAccount()
  const [isSubmitting, setIsSubmitting] = useState(false)
  const { validPackedActions } = useReadValidPackedActions(roundNumber)

  const _reveal = async () => {
    setIsSubmitting(true)
    // console.log(`reveal....`, account, duelId, roundNumber, hash, validPackedActions)
    const { salt, packed, slot1, slot2 } = await signAndRestoreActionFromHash(account, duelId, roundNumber, hash, validPackedActions)
    if (packed != null && slot1 != null && slot2 != null) {
      await reveal_action(account, duelId, roundNumber, salt, slot1, slot2)
      setIsOpen(false)
    }
    setIsSubmitting(false)
  }

  const canReveal = useMemo(() => (isOpen && duelId && roundNumber && hash && !isSubmitting), [isOpen, duelId,roundNumber, hash, isSubmitting])

  //
  // auto-reveal (no modal)
  //
  useEffect(() => {
    if (canReveal) {
      _reveal()
    }
  }, [canReveal])

  return <></>
}
