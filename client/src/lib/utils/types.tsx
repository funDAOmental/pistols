import { getEntityIdFromKeys } from '@dojoengine/utils'
import { Entity } from '@dojoengine/recs'
import { BigNumberish } from 'starknet'

//
// Numbers
//

export const isNumber = (v: string) => (/^\d+$/.test(v))


//
// BigNumberish
//

export const bigintEquals = (a: BigNumberish | null, b: BigNumberish | null): boolean => (a && b && BigInt(a) == BigInt(b))
export const bigintToHex = (v: BigNumberish): string => (!v ? '0x0' : `0x${BigInt(v).toString(16)}`)
export const bigintToEntity = (v: BigNumberish): Entity => (getEntityIdFromKeys([BigInt(v)]) as Entity)
export const keysToEntity = (keys: any[]): Entity => (getEntityIdFromKeys(keys) as Entity)

export const shortAddress = (address: string | null) => (
  !address ? '?'
    : !address.startsWith('0x') ? `(${address})`  // not hex
      : address.length < 12 ? address             // size is good
        : `${address.slice(0, 6)}..${address.slice(-4)}`
)

//
// dictionaries
//

export const cleanDict = (dict: any): any => Object.keys(dict).reduce((a, k) => {
  if (dict[k] !== undefined) a[k] = dict[k]
  return a
}, {})