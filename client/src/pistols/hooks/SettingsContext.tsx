import React, { ReactNode, createContext, useReducer, useContext, useState, useCallback } from 'react'
import { useCookies } from 'react-cookie'
import { useEffectOnce } from '@/lib/utils/hooks/useEffectOnce'

//--------------------------------
// Constants
//
export const initialState = {
  debugMode: false,
  debugScene: false,
  framerate: 60,
  musicEnabled: true,
  sfxEnabled: true,
  tableId: '',
  // internal
  initialized: false,
}

const SettingsActions = {
  DEBUG_MODE: 'settings.DEBUG_MODE',
  DEBUG_SCENE: 'settings.DEBUG_SCENE',
  FRAMERATE: 'settings.FRAMERATE',
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
  | { type: 'DEBUG_SCENE', payload: boolean }
  | { type: 'FRAMERATE', payload: number }
  | { type: 'MUSIC_ENABLED', payload: boolean }
  | { type: 'SFX_ENABLED', payload: boolean }
  | { type: 'TABLE_ID', payload: string }
  // internal
  | { type: 'INITIALIZED', payload: boolean }



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

  const cookieSetter = useCallback((cookieName: string, state: SettingsStateType) => {
    const _options = { path: '/' }
    const _setters = {
      [SettingsActions.DEBUG_MODE]: () => setCookie(cookieName, state.debugMode, _options),
      [SettingsActions.DEBUG_SCENE]: () => setCookie(cookieName, state.debugScene, _options),
      [SettingsActions.FRAMERATE]: () => setCookie(cookieName, state.framerate, _options),
      [SettingsActions.MUSIC_ENABLED]: () => setCookie(cookieName, state.musicEnabled, _options),
      [SettingsActions.SFX_ENABLED]: () => setCookie(cookieName, state.sfxEnabled, _options),
      [SettingsActions.TABLE_ID]: () => setCookie(cookieName, state.tableId, _options),
    }
    _setters[cookieName]?.()
  }, [setCookie])

  const [state, dispatch] = useReducer((state: SettingsStateType, action: ActionType) => {
    let newState = { ...state }
    switch (action.type) {
      case 'INITIALIZED': {
        newState.initialized = action.payload as boolean
        break
      }
      case SettingsActions.DEBUG_MODE: {
        newState.debugMode = action.payload as boolean
        cookieSetter(SettingsActions.DEBUG_MODE, newState)
        break
      }
      case SettingsActions.DEBUG_SCENE: {
        newState.debugScene = action.payload as boolean
        cookieSetter(SettingsActions.DEBUG_SCENE, newState)
        break
      }
      case SettingsActions.FRAMERATE: {
        newState.framerate = action.payload as number
        cookieSetter(SettingsActions.FRAMERATE, newState)
        break
      }
      case SettingsActions.MUSIC_ENABLED: {
        newState.musicEnabled = action.payload as boolean
        cookieSetter(SettingsActions.MUSIC_ENABLED, newState)
        break
      }
      case SettingsActions.SFX_ENABLED: {
        newState.sfxEnabled = action.payload as boolean
        cookieSetter(SettingsActions.SFX_ENABLED, newState)
        break
      }
      case SettingsActions.TABLE_ID: {
        newState.tableId = action.payload as string
        cookieSetter(SettingsActions.TABLE_ID, newState)
        break
      }
      default:
        console.warn(`SettingsProvider: Unknown action [${action.type}]`)
        return state
    }
    return newState
  }, initialState)

  // initialize from cookies
  useEffectOnce(() => {
    if (dispatch && cookies) {
      Object.keys(SettingsActions).forEach((key) => {
        const name = SettingsActions[key]
        const cookieValue = cookies[name]
        if (cookieValue != null) {
          // read from cookie
          dispatch({ type: name, payload: cookieValue })
        } else {
          // initialize cookie
          cookieSetter(name, state)
        }
      })
      dispatch({ type: 'INITIALIZED', payload: true })
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

