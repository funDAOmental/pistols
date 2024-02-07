import React, { useEffect, useMemo, useState } from 'react'
import { Grid, Segment, Icon, Step } from 'semantic-ui-react'
import { useDojoAccount, useDojoSystemCalls } from '@/dojo/DojoContext'
import { usePistolsContext } from '@/pistols/hooks/PistolsContext'
import { useThreeJsContext } from '../hooks/ThreeJsContext'
import { useGameplayContext } from '@/pistols/hooks/GameplayContext'
import { useChallenge, useChallengeDescription } from '@/pistols/hooks/useChallenge'
import { useDuelist } from '@/pistols/hooks/useDuelist'
import { DuelStage, useAnimatedDuel, useDuel } from '@/pistols/hooks/useDuel'
import { useCommitMove } from '@/pistols/hooks/useCommitReveal'
import { useEffectOnce } from '@/pistols/hooks/useEffectOnce'
import { ProfileDescription } from '@/pistols/components/account/ProfileDescription'
import { ProfilePic } from '@/pistols/components/account/ProfilePic'
import { BladesNames, FULL_HEALTH, HALF_HEALTH } from '@/pistols/utils/pistols'
import { MenuDuel } from '@/pistols/components/Menus'
import { AnimationState } from '@/pistols/three/game'
import { EmojiIcon } from '@/pistols/components/ui/Icons'
import CommitModal from '@/pistols/components/CommitModal'
import { EMOJI } from '@/pistols/data/messages'

const Row = Grid.Row
const Col = Grid.Column

export default function Duel({
  duelId
}) {
  const { account } = useDojoAccount()
  const { gameImpl } = useThreeJsContext()
  const { animated } = useGameplayContext()
  const { dispatchSelectDuel } = usePistolsContext()

  const { isLive, isFinished, message, duelistA, duelistB } = useChallenge(duelId)
  const { challengeDescription } = useChallengeDescription(duelId)

  const { duelStage, completedStagesA, completedStagesB } = useAnimatedDuel(duelId)
  // console.log(`Round 1:`, round1)
  // console.log(`Round 2:`, round2)

  useEffectOnce(() => {
    gameImpl?.resetDuelScene()
  }, [])

  useEffect(() => dispatchSelectDuel(duelId), [duelId])

  return (
    <>
      <div className='TavernTitle' style={{ maxWidth: '250px' }}>
        <h1 className='Quote'>{`“${message}”`}</h1>
        {(isFinished && animated == AnimationState.Finished) &&
          <Segment>
            <h3 className='Important'>{challengeDescription}</h3>
          </Segment>
        }
      </div>

      <div className='DuelSideA'>
        <div className='DuelProfileA' >
          <DuelProfile floated='left' address={duelistA} />
        </div>
        <DuelProgress floated='left'
          isA
          duelId={duelId}
          duelStage={duelStage}
          account={account}
          duelistAccount={duelistA}
          completedStages={completedStagesA}
        />
      </div>
      <div className='DuelSideB'>
        <div className='DuelProfileB' >
          <DuelProfile floated='right' address={duelistB} />
        </div>
        <DuelProgress floated='right'
          isB
          duelId={duelId}
          duelStage={duelStage}
          account={account}
          duelistAccount={duelistB}
          completedStages={completedStagesB}
        />
      </div>

      <MenuDuel duelStage={duelStage} />

      {/* {process.env.NEXT_PUBLIC_DEBUG &&
        <MenuDebugAnimations />
      } */}
    </>
  )
}

function DuelProfile({
  address,
  floated,
}) {
  const { name, profilePic } = useDuelist(address)

  return (
    <>
      {floated == 'left' &&
        <ProfilePic duel profilePic={profilePic} />
      }
      <Segment compact floated={floated} className='ProfileDescription'>
        <ProfileDescription address={address} />
      </Segment>
      {floated == 'right' &&
        <ProfilePic duel profilePic={profilePic} />
      }
    </>
  )
}


function DuelProgress({
  isA = false,
  isB = false,
  duelId,
  duelStage,
  account,
  duelistAccount,
  completedStages,
  floated,
}) {
  const { round1, round2, roundNumber, turnA, turnB, } = useDuel(duelId)

  //-------------------------
  // Duel progression
  //

  const _healthResult = (round: any) => {
    const health = isA ? round.duelist_a.health : round.duelist_b.health
    return (health == 0 ? 'is DEAD!' : health < FULL_HEALTH ? 'is INJURED!' : 'is ALIVE!')
  }

  const pistolsResult = useMemo(() => {
    if (duelStage > DuelStage.PistolsShootout) {
      const steps = isA ? round1.duelist_a.move : round1.duelist_b.move
      const health = _healthResult(round1)
      return <span>Walks <span className='Important'>{steps} steps</span><br />and {health}</span>
    }
    return null
  }, [round1, duelStage])

  const bladesResult = useMemo(() => {
    if (round2 && duelStage > DuelStage.BladesClash) {
      const blade = isA ? round2.duelist_a.move : round2.duelist_b.move
      const health = _healthResult(round2)
      return <span>Clashes with <span className='Important'>{BladesNames[blade]}</span><br />and {health}</span>
    }
    return null
  }, [round2, duelStage])

  const _resultBackground = (round) => {
    const health = isA ? round.duelist_a.health : round.duelist_b.health
    return health == FULL_HEALTH ? 'Positive' : health == HALF_HEALTH ? 'Warning' : 'Negative'
  }
  const _resultEmoji = (round) => {
    const health = isA ? round.duelist_a.health : round.duelist_b.health
    return health == FULL_HEALTH ? EMOJI.ALIVE : health == HALF_HEALTH ? EMOJI.INJURED : EMOJI.DEAD
  }


  //------------------------------
  // Duelist interaction
  //
  const isYou = useMemo(() => (BigInt(account?.address) == duelistAccount), [account, duelistAccount])
  const isTurn = useMemo(() => ((isA && turnA) || (isB && turnB)), [isA, isB, turnA, turnB])

  // Commit modal control
  const [commitStepsIsOpen, setCommitStepsIsOpen] = useState(false)
  const [commitBladesIsOpen, setCommitBladesIsOpen] = useState(false)
  const _commit = () => {
    if (roundNumber == 1) setCommitStepsIsOpen(true)
    if (roundNumber == 2) setCommitBladesIsOpen(true)
  }

  // Reveal
  const { reveal_move } = useDojoSystemCalls()
  const { hash, salt, move } = useCommitMove(duelId, roundNumber)
  const _reveal = () => {
    // console.log(`REVEAL`, duelId, roundNumber, hash, salt, move, pedersen(salt, move).toString(16))
    reveal_move(account, duelId, roundNumber, salt, move)
  }

  // onClick
  const onClick = useMemo(() => {
    if (isYou && !completedStages[duelStage]) {
      if (duelStage == DuelStage.StepsCommit || duelStage == DuelStage.BladesCommit) {
        return _commit
      }
      if (duelStage == DuelStage.StepsReveal || duelStage == DuelStage.BladesReveal) {
        return _reveal
      }
    }
    return null
  }, [isYou, duelStage, completedStages])


  //------------------------------
  return (
    <>
      <CommitModal duelId={duelId} roundNumber={1} isOpen={commitStepsIsOpen} setIsOpen={setCommitStepsIsOpen} />
      <CommitModal duelId={duelId} roundNumber={2} isOpen={commitBladesIsOpen} setIsOpen={setCommitBladesIsOpen} />
      <Step.Group vertical size='small'>
        <ProgressItem
          stage={DuelStage.StepsCommit}
          duelStage={duelStage}
          completedStages={completedStages}
          title='Choose Steps'
          description=''
          icon='street view'
          // emoji=EMOJI.STEP
          floated={floated}
          onClick={onClick}
        />
        <ProgressItem
          stage={DuelStage.StepsReveal}
          duelStage={duelStage}
          completedStages={completedStages}
          title='Reveal Steps'
          description=''
          icon='eye'
          floated={floated}
          onClick={onClick}
        />
        <ProgressItem
          stage={DuelStage.PistolsShootout}
          duelStage={duelStage}
          completedStages={completedStages}
          title={pistolsResult ?? 'Pistols shootout!'}
          description=''
          icon={pistolsResult ? null : 'target'}
          emoji={pistolsResult ? _resultEmoji(round1) : null}
          floated={floated}
          onClick={onClick}
          className={pistolsResult ? _resultBackground(round1) : null}
        />

        {(round2 && duelStage >= DuelStage.BladesCommit) &&
          <>
            <ProgressItem
              stage={DuelStage.BladesCommit}
              duelStage={duelStage}
              completedStages={completedStages}
              title='Choose Blades'
              description=''
              icon='shield'
              emoji={EMOJI.BLADES}
              // emojiFlipped='horizontally'
              // emojiRotated='clockwise'
              floated={floated}
              onClick={onClick}
            />
            <ProgressItem
              stage={DuelStage.BladesReveal}
              duelStage={duelStage}
              completedStages={completedStages}
              title='Reveal Blades'
              description=''
              icon='eye'
              floated={floated}
              onClick={onClick}
            />
            <ProgressItem
              stage={DuelStage.BladesClash}
              duelStage={duelStage}
              completedStages={completedStages}
              title={bladesResult ?? 'Blades clash!'}
              description=''
              icon={bladesResult ? null : 'target'}
              emoji={bladesResult ? _resultEmoji(round2) : null}
              floated={floated}
              onClick={onClick}
              className={bladesResult ? _resultBackground(round2) : null}
            />
          </>
        }
      </Step.Group>
    </>
  )
}

function ProgressItem({
  stage,
  duelStage,
  completedStages = {},
  title,
  description,
  icon = null,
  emoji = null,
  emojiFlipped = null,
  emojiRotated = null,
  floated,
  onClick = null,
  className = null,
}) {
  const _currentStage = (duelStage == stage)
  const _completed =
    stage != DuelStage.PistolsShootout && stage != DuelStage.BladesClash // animations do not complete
    && (
      (stage < duelStage) // past stage
      || (_currentStage && completedStages[stage] === true
      ))
  const _onClick = (_currentStage && !_completed ? onClick : null)
  const _disabled = (duelStage < stage)
  const _left = (floated == 'left')
  const _right = (floated == 'right')
  let classNames = className ? [className] : []

  let _icon = useMemo(() => {
    const style = _right ? { margin: '0 0 0 1rem' } : {}
    if (icon) return <Icon name={icon} style={style} />
    if (emoji) return <EmojiIcon emoji={emoji} style={style} flipped={emojiFlipped} rotated={emojiRotated} />
    return <></>
  }, [icon, emoji, _completed, _right])

  // if (_right) classNames.push('AlignRight')
  classNames.push('AlignCenter')
  if (!_onClick) classNames.push('NoMouse')
  return (
    <Step
      className={classNames.join(' ')}
      completed={_completed}
      active={_currentStage}
      disabled={_disabled}
      link={_onClick != null}
      onClick={_onClick}
    >
      {_left && _icon}
      <Step.Content className='AutoMargin'>
        <Step.Title>{title}</Step.Title>
        <Step.Description>{description}</Step.Description>
      </Step.Content>
      {_right && _icon}
    </Step>
  )
}
