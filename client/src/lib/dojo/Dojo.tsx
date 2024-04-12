import React, { ReactNode } from 'react'
import { StarknetProvider, useStarknetContext } from '@/lib/dojo/StarknetProvider'
import { DojoProvider } from '@/lib/dojo/DojoContext'
import { DojoStatus } from '@/lib/dojo/DojoStatus'
import { useSetup } from '@/lib/dojo/setup/useSetup'
import { CHAIN_ID } from '@/lib/dojo/setup/chains'
import { useAccount } from '@starknet-react/core'
import { Account } from 'starknet'
import { useReconnectChain } from './hooks/useChain'

export interface DojoAppConfig {
  supportedChainIds: CHAIN_ID[],
  defaultChainId: CHAIN_ID,
  manifests: { [chain_id: string]: any | undefined },
}

export default function Dojo({
  dojoAppConfig,
  children,
}: {
  dojoAppConfig: DojoAppConfig,
  children: ReactNode
}) {

  return (
    <StarknetProvider dojoAppConfig={dojoAppConfig}>
      <SetupDojoProvider dojoAppConfig={dojoAppConfig}>
        {children}
      </SetupDojoProvider>
    </StarknetProvider>
  )
}

function SetupDojoProvider({
  dojoAppConfig,
  children,
}: {
  dojoAppConfig: DojoAppConfig,
  children: ReactNode
}) {
  // Connected wallet or Dojo Predeployed (master)
  const { account } = useAccount()
  const { selectedChainId, selectedChainConfig } = useStarknetContext()
  
  useReconnectChain()
  
  const setupResult = useSetup(selectedChainConfig, dojoAppConfig.manifests[selectedChainId], account as Account)

  if (!setupResult) {
    return <DojoStatus message={'Loading Pistols...'} />
  }

  return (
    <DojoProvider value={setupResult}>
      {children}
    </DojoProvider>
  )
}
