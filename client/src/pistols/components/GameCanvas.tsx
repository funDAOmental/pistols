import React, { useEffect } from 'react'
import { useThreeJsContext } from '@/pistols/hooks/ThreeJsContext'
import { useGameplayContext } from '@/pistols/hooks/GameplayContext'
import { useGameEvent } from '@/pistols/hooks/useGameEvent'
import { usePistolsContext } from '@/pistols/hooks/PistolsContext'
import ThreeJsCanvas from '@/pistols/three/ThreeJsCanvas'

const GameCanvas = () => {
  const { gameImpl } = useThreeJsContext()
  const { dispatchAnimated } = useGameplayContext()
  const { sceneName } = usePistolsContext()

  const animated = useGameEvent('animated', -1)
  useEffect(() => {
    dispatchAnimated(animated)
  }, [animated])

  useEffect(() => {
    gameImpl?.switchScene(sceneName)
  }, [gameImpl, sceneName])

  return (
    <div className='Relative GameCanvas'>
      <ThreeJsCanvas guiEnabled={null} />
    </div>
  )
}

export default GameCanvas
