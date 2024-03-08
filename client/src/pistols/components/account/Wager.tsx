import { useMemo } from 'react'
import { CopyIcon, CustomIcon } from '@/pistols/components/ui/Icons'
import { bigintToHex } from '@/pistols/utils/utils'
import { BigNumberish } from 'starknet'
import { weiToEth } from '@/pistols/utils/starknet'
import { COIN_LORDS } from '@/pistols/hooks/useConfig'

function Wager({
  coin = COIN_LORDS,
  value = null,
  wei = null,
  big = false,
  small = false,
  clean = false,
  pre = null,
  post = null,
}: {
  coin: number
  value?: BigNumberish
  wei?: BigNumberish
    big?: boolean
    small?: boolean
  clean?: boolean
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
  if (!_value) return <></>
  return (
    <span className={small ? 'WagerSmall' : big ? 'WagerBig' : 'Wager'}>
      {/* <CustomIcon name='lords' logo color={'bisque'} centered={false} /> */}
      {pre}{!clean && <>💰</>}{_value}{post}
    </span>
  )
}

function WagerAndOrFees({
  coin = COIN_LORDS,
  value,
  fee,
}: {
  coin: number
  value: BigNumberish
  fee: BigNumberish
  big?: boolean
}) {
  if (BigInt(value ?? 0) > 0n) {
    return (
      <>
        <span>
          <Wager big coin={coin} wei={value} />
        </span>
        &nbsp;&nbsp;
        <span>
          (<Wager clean coin={coin} wei={fee} pre='-' /> fee)
        </span>
      </>
    )
  }
  if (BigInt(fee ?? 0) > 0n) {
    return (
      <span>
        <Wager big coin={coin} wei={fee} pre={'Fee '} />
      </span>
    )
  }
  return <></>
}

export {
  Wager,
  WagerAndOrFees,
}
