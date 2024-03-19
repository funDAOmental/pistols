import { useMemo } from 'react'
import { CustomIcon } from '@/lib/ui/Icons'
import { COIN_LORDS } from '@/pistols/hooks/useConfig'
import { weiToEth } from '@/lib/utils/starknet'
import { BigNumberish } from 'starknet'

export function LordsBagIcon({
  size = null,
}) {
  return <CustomIcon logo png name='lords_bag' size={size} />
}

function Wager({
  coin = COIN_LORDS,
  value = null,
  wei = null,
  big = false,
  small = false,
  clean = false,
  crossed = false,
  pre = null,
  post = null,
}: {
  coin: number
  value?: BigNumberish
  wei?: BigNumberish
  big?: boolean
  small?: boolean
  clean?: boolean
  crossed?: boolean
  pre?: string
  post?: string
}) {
  const _value = useMemo(() => {
    let result = wei != null ? weiToEth(wei).toString()
      : value != null ? BigInt(value).toString()
        : null
    if (result) result = Number(result).toLocaleString('en-US', { maximumFractionDigits: 8 })
    return result
  }, [value, wei])

  let classNames = useMemo(() => {
    let result = []
    if (small) result.push('WagerSmall')
    else if (big) result.push('WagerBig')
    else result.push('Wager')
    if (crossed) result.push('Crossed')
    return result
  }, [small, big, crossed])

  if (!_value) return <></>

  return (
    <span className={classNames.join(' ')}>
      {pre}
      {/* {!clean && <>💰</>} */}
      {/* {!clean && <EmojiIcon emoji='💰' />} */}
      {!clean && <LordsBagIcon size={null} />}
      {_value}
      {post}
    </span>
  )
}

function WagerAndOrFees({
  coin = COIN_LORDS,
  value,
  fee,
  pre = null,
}: {
  coin: number
  value: BigNumberish
  fee: BigNumberish
    pre?: string
    big?: boolean
}) {
  if (BigInt(value ?? 0) > 0n) {
    return (
      <>
        <span>
          <Wager big coin={coin} wei={value} pre={pre} />
        </span>
        &nbsp;&nbsp;
        <span>
          (<Wager clean coin={coin} wei={fee} pre='+' /> fee)
        </span>
      </>
    )
  }
  if (BigInt(fee ?? 0) > 0n) {
    return (
      <span>
        <Wager big coin={coin} wei={fee} pre={pre} />
      </span>
    )
  }
  return <></>
}

export {
  Wager,
  WagerAndOrFees,
}
