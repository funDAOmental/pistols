import React, { useMemo } from 'react'
import Link from 'next/link'
import { Icon, IconGroup, Popup, PopupContent, PopupHeader, SemanticICONS } from 'semantic-ui-react'
import { IconSizeProp } from 'semantic-ui-react/dist/commonjs/elements/Icon/Icon'

// Semantic UI Icons
// https://react.semantic-ui.com/elements/icon/
// https://react.semantic-ui.com/elements/icon/#variations-size

// re-export semantic ui Icon for convenience
export { Icon }

export const _downSize = (size) => {
  return (
    size == 'small' ? 'tiny'
      : size == null ? 'small'
        : size == 'large' ? null
          : size == 'big' ? 'large'
            : size == 'huge' ? 'big'
              : null
  )
}

export const _upSize = (size) => {
  return (
    size == 'tiny' ? 'small'
      : size == 'small' ? null
        : size == null ? 'large'
          : size == 'large' ? 'big'
            : size == 'big' ? 'huge'
              : null
  )
}

//---------------------------------
// Popup Tooltip
// wrap content in <span> so it will apeear on disabled buttons
//
interface TooltipProps {
  content: string | typeof PopupContent
  header: typeof PopupHeader
  disabledTooltip?: boolean
  cursor?: string
  children: any
}
export function Tooltip({
  header = null,
  content = 'gabba bagga hey',
  disabledTooltip = false,
  cursor = null,
  children = null,
}: TooltipProps) {
  const _trigger = disabledTooltip ?
    <span>{children}</span>
    : children
  const _content = Array.isArray(content)
    ? content.map((v, i) => <span key={`e${i}`}>{v}<br /></span>)
    : content
  const _style = cursor ? { cursor: cursor } : {}
  return (
    <span className='Tooltip' style={_style}>
      <Popup
        size='small'
        header={header}
        content={_content}
        trigger={_trigger}
      />
    </span>
  )
}


//---------------------------------
// Info icon + Tooltip
//
interface InfoIconProps {
  size?: IconSizeProp
  content: string | typeof PopupContent
  header: typeof PopupHeader
}
export function InfoIcon({
  size = null, // normal size
  header = null,
  content = 'gabba bagga hey',
}: InfoIconProps) {
  return (
    <Tooltip header={header} content={content}>
      <Icon name='info circle' size={size} className='InfoIcon' />
    </Tooltip>
  )
}



//---------------------------------
// Copy to clipboard icon
//
interface CopyIconProps {
  size?: IconSizeProp
  content: string
}
export function CopyIcon({
  size = null, // normal size
  content = null, // content to copy
}: CopyIconProps) {
  function _copy() {
    navigator?.clipboard?.writeText(content)
  }
  return (
    <Icon className='Anchor InfoIcon IconClick' name='copy' size={size} onClick={() => _copy()} />
  )
}


//---------------------------------
// Loading/Sync spinner
//
interface LoadingIconProps {
  size?: IconSizeProp
  style?: any
  className?: string
}
export function LoadingIcon({
  size = 'small',
  style = {},
  className = '',
}: LoadingIconProps) {
  return (
    <Icon
      className={`ViewCentered NoPadding ${className}`}
      loading
      name='circle notch'
      size={size}
      style={style}
    />)
}



//---------------------------------
// Ticked Icons
//
interface CompletedIconProps {
  completed: boolean
  size?: IconSizeProp
  children: any
}
export function CompletedIcon({
  completed,
  size = null,
  children,
}: CompletedIconProps) {
  return (
    <IconGroup size={(size)}>
      {children}
      {completed && <Icon size={_upSize(size)} name='checkmark' color='green' style={{ margin: '-4px 0 0 0' }} />}
    </IconGroup>
  )
}


//---------------------------------
// Emoji Icon
//
interface EmojiIconProps {
  emoji: string
  size?: IconSizeProp
  style?: any
  className?: string
  disabled?: boolean
  flipped?: 'horizontally' | 'vertically'
  rotated?: 'clockwise' | 'counterclockwise'
}
export function EmojiIcon({
  emoji,
  size = null,
  style = {},
  className = null,
  disabled = false,
  flipped = null,
  rotated = null,
}: EmojiIconProps) {
  let classNames = [className, 'icon', size, 'NoMargin']
  if (rotated) classNames.push('dirotatedabled')
  if (disabled) classNames.push('disabled')
  if (flipped) classNames.push('flipped')
  return (
    <i className={classNames.join(' ')} style={style}>
      {emoji}
    </i>
  )
}


//---------------------------------
// Custom SVG icons
//
interface CustomIconProps {
  name: SemanticICONS | string,   // name of icon, logo, or Icon
  icon?: boolean,			  // if the svg is on /icons/
  logo?: boolean,			  // if the svg is on /logos/
  png?: boolean,        // png extension
  // <Icon> fallback
  // optionals
  className?: string,
  size?: IconSizeProp,
  color?: string,       // css color
  tooltip?: string,
  onClick?: Function,
  // <Icon> fallback
  disabled?: boolean,   // if <Icon>
  flipped?: boolean,    // if <Icon>
}
export function CustomIcon({
  icon = false,
  logo = false,
  png = false,
  name = 'avante',
  className = null,
  size = null,
  disabled = false,
  flipped = false,
  color = '#c8b6a8', // $color-text
  tooltip = null,
  onClick = null,
}: CustomIconProps) {
  const component = useMemo(() => {
    const _extension = png ? 'png' : 'svg'
    const _url = (logo ? `/logos/logo_${name}.${_extension}` : icon ? `/icons/icon_${name}.${_extension}` : null)
    
    // not svg, logo, icon or png
    if (!_url) {
      return <Icon name={name as SemanticICONS} className={className} size={size} disabled={disabled} />
    }

    // png
    if (png) {
      let _style = {
        backgroundImage: `url(${_url})`,
      }
      return (
        <i className={`${className} icon ${size} NoMargin Relative`}>
          {' '}
          <div className='CustomIconPng' style={_style} />
        </i>
      )
    }

    // svg logo or icon
    let _style = {
      WebkitMaskImage: `url(${_url})`,
      MaskImage: `url(${_url})`,
      backgroundColor: null,
    }
    let classNames = ['CustomIcon', 'icon', size]
    if (disabled) classNames.push('disabled')
    if (flipped) classNames.push('flipped')
    if (onClick) {
      classNames.push('IconLink')
    } else {
      _style.backgroundColor = color
    }

    return (
      <i className={classNames.join(' ')}
        style={_style}
        onClick={() => (onClick?.() ?? {})}
      >
        {' '}
      </i>
    )

    // result = _linkfy(result, props.linkUrl)

    // TODO: breaks something, need to debug!
    // if(props.tooltip) {
    // 	content = <Tooltip content={props.tooltip}>{content}</Tooltip>	
    // }
  }, [icon, logo, png, name, className, size, color, tooltip, onClick])
  return component
}
