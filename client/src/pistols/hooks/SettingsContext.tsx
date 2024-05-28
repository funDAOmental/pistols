import React, { ReactNode, createContext, useReducer, useContext, useState } from 'react'
import { useCookies } from 'react-cookie'
import { useEffectOnce } from '@/lib/utils/hooks/useEffectOnce'
import { tables } from '@/pistols/utils/constants'

//--------------------------------
// Constants
//
export const initialState = {
  debugMode: false,
  musicEnabled: true,
  sfxEnabled: true,
  tableId: tables.LORDS,
}

const SettingsActions = {
  DEBUG_MODE: 'settings.DEBUG_MODE',
  MUSIC_ENABLED: 'settings.MUSIC_ENABLED',
  SFX_ENABLED: 'settings.SFX_ENABLED',
  TABLE_ID: 'settings.TABLE_ID',
}

//--------------------------------
// Types
//
type SettingsStateType = typeof initialState

type ActionType =
  | { type: 'DEBUG_MODE', payload: boolean }
  | { type: 'MUSIC_ENABLED', payload: boolean }
  | { type: 'SFX_ENABLED', payload: boolean }
  | { type: 'TABLE_ID', payload: string }



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

  const [state, dispatch] = useReducer((state: SettingsStateType, action: ActionType) => {
    let newState = { ...state }
    switch (action.type) {
      case SettingsActions.DEBUG_MODE: {
        newState.debugMode = action.payload as boolean
        setCookie(SettingsActions.DEBUG_MODE, newState.debugMode)
        break
      }
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
      case SettingsActions.TABLE_ID: {
        newState.tableId = action.payload as string
        setCookie(SettingsActions.TABLE_ID, newState.tableId)
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
    <SettingsContext.Provider value={{ state, dispatch }}>
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

