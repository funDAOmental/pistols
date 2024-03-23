import React, { ReactNode, createContext, useReducer, useContext, useState } from 'react'
import { useCookies } from 'react-cookie'
import { useEffectOnce } from '@/lib/hooks/useEffectOnce'
import { Opener, useOpener } from '@/lib/ui/useOpener'

//--------------------------------
// Constants
//
export const initialState = {
  musicEnabled: true,
  sfxEnabled: true,
  connectOpener: null,
}

const SettingsActions = {
  MUSIC_ENABLED: 'settings.MUSIC_ENABLED',
  SFX_ENABLED: 'settings.SFX_ENABLED',
}

//--------------------------------
// Types
//
type SettingsStateType = {
  musicEnabled: boolean,
  sfxEnabled: boolean,
  connectOpener: Opener,
}

type ActionType =
  | { type: 'MUSIC_ENABLED', payload: boolean }
  | { type: 'SFX_ENABLED', payload: boolean }



//--------------------------------
// Context
//
const SettingsContext = createContext<{
  state: SettingsStateType
  dispatch: React.Dispatch<any>
}>({
  state: initialState,
  dispatch: () => null,
})

//--------------------------------
// Provider
//
interface SettingsProviderProps {
  children: string | JSX.Element | JSX.Element[] | ReactNode
}
const SettingsProvider = ({
  children,
}: SettingsProviderProps) => {
  const [cookies, setCookie] = useCookies(Object.values(SettingsActions));
  const connectOpener = useOpener()

  const [state, dispatch] = useReducer((state: SettingsStateType, action: ActionType) => {
    let newState = { ...state }
    switch (action.type) {
      case SettingsActions.MUSIC_ENABLED: {
        newState.musicEnabled = action.payload as boolean
        setCookie(SettingsActions.MUSIC_ENABLED, newState.musicEnabled)
        break
      }
      case SettingsActions.SFX_ENABLED: {
        newState.sfxEnabled = action.payload as boolean
        setCookie(SettingsActions.SFX_ENABLED, newState.sfxEnabled)
        break
      }
      default:
        console.warn(`SettingsProvider: Unknown action [${action.type}]`)
        return state
    }
    return newState
  }, initialState)

  // initialize from cookies
  const [initialized, setInitialized] = useState(false)
  useEffectOnce(() => {
    if (!initialized && dispatch && cookies) {
      Object.keys(SettingsActions).forEach((key) => {
        const name = SettingsActions[key]
        const cookieValue = cookies[name]
        if (cookieValue != null) {
          dispatch({ type: name, payload: cookieValue })
        }
      })
      setInitialized(true)
    }
  }, [dispatch, cookies])

  return (
    <SettingsContext.Provider value={{ dispatch, state: {
      ...state,
      connectOpener,
    } }}>
      {children}
    </SettingsContext.Provider>
  )
}

export { SettingsProvider, SettingsContext, SettingsActions }


//--------------------------------
// Hooks
//

export const useSettingsContext = () => {
  const { state, dispatch } = useContext(SettingsContext)

  const dispatchSetting = (key: string, value: any) => {
    dispatch({
      type: key,
      payload: value,
    })
  }

  return {
    ...state,   // expose individual settings values
    settings: { ...state },  // expose settings as object {}
    SettingsActions,
    dispatchSetting,
  }
}

