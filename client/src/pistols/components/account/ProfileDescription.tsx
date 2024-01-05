import React from 'react'
import { AccountShort } from '@/pistols/components/ui/Account'
import { useDuelist } from '@/pistols/hooks/useDuelist'

export function ProfileDescription({
  address,
  preName = null,
  postName = null,
}) {
  const { name, honourDisplay } = useDuelist(address)
  return (
    <div>
      <h1>{preName} {name} {postName}</h1>
      <AccountShort address={address} />
      <h3 className='Important'>Honour: {honourDisplay}</h3>
    </div>
  )
}
