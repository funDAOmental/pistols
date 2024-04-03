import React, { useMemo } from 'react'
import { Grid, Image } from 'semantic-ui-react'
import { useAccount, useDisconnect, useStarkProfile } from '@starknet-react/core'
import { useDojoAccount } from '@/lib/dojo/DojoContext'
import { useDojoWallet } from '@/lib/dojo/hooks/useDojoWallet'
import { LordsBalance } from '@/pistols/components/account/LordsBalance'
import { LordsFaucet } from '@/pistols/components/account/LordsFaucet'
import { ActionButton } from '@/pistols/components/ui/Buttons'
import { AddressShort } from '@/lib/ui/AddressShort'

const Row = Grid.Row
const Col = Grid.Column

export default function WalletHeader({
}) {
  const { disconnect } = useDisconnect()
  const { account, address, connector, isConnected, chainId } = useAccount()
  const { connectedChainName } = useDojoWallet()

  // BUG: https://github.com/apibara/starknet-react/issues/419
  // const { data, error, isLoading } = useStarkProfile({ address, enabled: false })
  // console.log(data)
  const data = { name: null, profilePicture: null }

  const name = useMemo(() => (data?.name ?? `Connected to ${connectedChainName}`), [data])
  const imageUrl = useMemo(() => (data?.profilePicture ?? connector?.icon?.dark ?? '/profiles/00_sq.jpg'), [data, connector])

  return (
    <Grid>
      <Row>
        <Col width={2} verticalAlign='middle'>
          <Image src={imageUrl} className='ProfilePicSquare' />
        </Col>
        <Col width={9} textAlign='left' className='TitleCase Padded'>
          <h4>{name}</h4>
          <AddressShort address={address ?? 0n} />
          {isConnected && <>
            <h5>LORDS balance: <LordsBalance address={address} big={false} /></h5>
          </>}
        </Col>
        <Col width={5} verticalAlign='middle'>
          <LordsFaucet fill large account={account} />
          <ActionButton fill large onClick={() => disconnect()} label='Disconnect' />
        </Col>
      </Row>
    </Grid>
  );
}

