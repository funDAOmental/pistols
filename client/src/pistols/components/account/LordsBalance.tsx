import { useBalance } from '@starknet-react/core'
import { useDojoConstants } from '@/lib/dojo/ConstantsContext'
import { useERC20Balance } from '@/lib/utils/hooks/useERC20'
import { useLordsBalance, useEtherBalance } from '@/lib/dojo/hooks/useLords'
import { useTable } from '@/pistols/hooks/useTable'
import { useLockedLordsBalance } from '@/pistols/hooks/useWager'
import { Balance } from '@/pistols/components/account/Balance'
import { BigNumberish } from 'starknet'
import { useMemo } from 'react'
import { bigintToHex } from '@/lib/utils/types'

export const EtherBalance = ({
  address,
  pre = null,
  post = null,
  clean = false,
  big = false,
}) => {
  const { balance } = useEtherBalance(address)
  return (
    <Balance ether big={big} wei={balance} pre={pre} post={post} clean={clean} />
  )
}

export const LordsBalance = ({
  address,
  pre = null,
  post = null,
  clean = false,
  big = false,
}) => {
  const { tables } = useDojoConstants()
  const { balance } = useLordsBalance(address)
  return (
    <Balance big={big} tableId={tables.LORDS} wei={balance} pre={pre} post={post} clean={clean} />
  )
}

export const WagerBalance = ({
  tableId,
  address,
  pre = null,
  post = null,
  clean = false,
  big = false,
}) => {
  const { contractAddress } = useTable(tableId)
  const { balance } = useERC20Balance(contractAddress, address)
  return (
    <Balance big={big} tableId={tableId} wei={balance} pre={pre} post={post} clean={clean} />
  )
}

export const LockedWagerBalance = ({
  tableId,
  address,
  pre = null,
  post = null,
  clean = false,
}) => {
  const { total } = useLockedLordsBalance(address)
  if (!total) return <></>
  return (
    <>
      {' + '}
      <Balance big tableId={tableId} wei={total} pre={pre} post={post} clean={clean} />
      {' '}
      (locked)
    </>
  )
}

export function WagerAndOrFees({
  tableId,
  value,
  fee,
  prefixed = false,
  big = false,
}: {
  tableId: string
  value: BigNumberish
  fee: BigNumberish
  prefixed?: boolean
  big?: boolean
}) {
  const hasValue = useMemo(() => (BigInt(value ?? 0) > 0), [value])
  const hasFees = useMemo(() => (BigInt(fee ?? 0) > 0), [fee])
  const pre = useMemo(() => (prefixed ? (hasValue || !hasFees ? 'Cost: ' : 'Fee: ') : null), [prefixed, hasValue, hasFees])
  if (hasValue && hasFees) {
    return (<>
      <span>
        <Balance big={big} tableId={tableId} wei={value} pre={pre} />
      </span>
      &nbsp;&nbsp;
      <span>
        (<Balance clean tableId={tableId} wei={fee} pre='+' /> fee)
      </span>
    </>)
  }
  // value only
  if (hasValue && hasFees) {
    return (
      <span>
        <Balance big={big} tableId={tableId} wei={value} pre={pre} />
      </span>
    )
  }
  // fees only
  return (
    <span>
      <Balance big={big} tableId={tableId} wei={fee} pre={pre} placeholdder={0} />
    </span>
  )
}
