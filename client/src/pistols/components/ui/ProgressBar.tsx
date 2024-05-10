import React, { ReactNode } from 'react'
import { Grid, Progress } from 'semantic-ui-react'

const Row = Grid.Row
const Col = Grid.Column

export default function ProgressBar({
  label,
  className = null,
  disabled = false,
  warning = false,
  negative = false,
  color = null,
  percent = null,
  includedExtraPercent = null,
  includedInnerPercent = null,
  value = null,
  total = null,
}) {
  const _disabled = (disabled || (!value && !percent))
  const _className = `NoMargin ${className}`
  return (
    <Grid verticalAlign='middle' className={className}>
      <Row style={{ height: '25px' }}>
        <Col width={4} textAlign='right' className='TitleCase'>
          {label}
        </Col>
        <Col width={12} textAlign='left' className='Relative'>
          {_disabled &&
            <Progress
              disabled={true}
              value={null}
              className={_className}
              color='grey'
            />
          }
          {!_disabled &&
            <>
              <Progress
                progress={value !== null ? 'value' : true}
                percent={percent}
                value={value}
                total={total}
                className={_className}
                warning={warning || Boolean(includedExtraPercent)}
                error={negative}
                color={color}
              />
              {Boolean(includedExtraPercent) &&
                <div className='CriticalBar BgImportant' style={{ width: `${percent - includedExtraPercent}%` }} />
              }
              {Boolean(includedInnerPercent) &&
                <div className='CriticalBar' style={{ width: `${includedInnerPercent}%` }} />
              }
            </>
          }
        </Col>
      </Row>
    </Grid>
  )
}
