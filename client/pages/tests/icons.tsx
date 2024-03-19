import React, { useState } from 'react'
import { Container, Grid, Icon } from 'semantic-ui-react'
import { CustomIcon, EmojiIcon } from '@/lib/ui/Icons'
import { BladesIcon, PacesIcon } from '@/pistols/components/ui/ActionIcon'
import { LordsBagIcon } from '@/pistols/components/account/Wager'
import { Action } from '@/pistols/utils/pistols'
import App from '@/lib/ui/App'

const Row = Grid.Row
const Col = Grid.Column

export default function IndexPage() {
  const [state, setState] = useState(false)
  return (
    <App>
      <Container text>

        <h5>Icons</h5>
        <Grid celled columns={8}>
          <Row>
            <Col><PacesIcon paces={10} /><br />PacesIcon</Col>
            <Col><BladesIcon blade={Action.Strong} /><br />BladesIcon</Col>
            <Col><BladesIcon blade={Action.Fast} /><br />BladesIcon</Col>
            <Col><BladesIcon blade={Action.Block} /><br />BladesIcon</Col>
            <Col><EmojiIcon emoji={'😛'} /><br />EmojiIcon</Col>
          </Row>

          <Row>
            <Col><CustomIcon name='home' /><br />Custom fallback</Col>
            <Col><CustomIcon name='twitter' logo /><br />Logo default</Col>
            <Col><CustomIcon name='twitter' logo color='green' /><br />Logo color</Col>
            <Col><CustomIcon name='twitter' logo onClick={() => alert('click')} /><br />Logo onClick</Col>
            <Col><CustomIcon name={`volume-${state ? 'on' : 'off'}`} icon onClick={() => setState(!state)} /><br />Logo state</Col>
          </Row>

          <Row columns={'equal'}>
            <Col>
              <Icon name='home' size='mini' />
              <Icon name='home' size='tiny' />
              <Icon name='home' size='small' />
              <Icon name='home' />
              <Icon name='home' size='large' />
              <Icon name='home' size='big' />
              <Icon name='home' size='huge' />
              <Icon name='home' size='massive' />
            </Col>
          </Row>

          <Row columns={'equal'}>
            <Col>
              <EmojiIcon emoji={'😛'} size='mini' />
              <EmojiIcon emoji={'😛'} size='tiny' />
              <EmojiIcon emoji={'😛'} size='small' />
              <EmojiIcon emoji={'😛'} />
              <EmojiIcon emoji={'😛'} size='large' />
              <EmojiIcon emoji={'😛'} size='big' />
              <EmojiIcon emoji={'😛'} size='huge' />
              <EmojiIcon emoji={'😛'} size='massive' />
            </Col>
          </Row>

          <Row columns={'equal'}>
            <Col>
              <CustomIcon name='lords' logo size='mini' />
              <CustomIcon name='lords' logo size='tiny' />
              <CustomIcon name='lords' logo size='small' />
              <CustomIcon name='lords' logo />
              <CustomIcon name='lords' logo size='large' />
              <CustomIcon name='lords' logo size='big' />
              <CustomIcon name='lords' logo size='huge' />
              <CustomIcon name='lords' logo size='massive' color='yellow' />
            </Col>
          </Row>

          <Row columns={'equal'}>
            <Col>
              <CustomIcon name='lords_bag' logo png size='mini' />
              <CustomIcon name='lords_bag' logo png size='tiny' />
              <CustomIcon name='lords_bag' logo png size='small' />
              <CustomIcon name='lords_bag' logo png />
              <CustomIcon name='lords_bag' logo png size='large' />
              <CustomIcon name='lords_bag' logo png size='big' />
              <CustomIcon name='lords_bag' logo png size='huge' />
              <CustomIcon name='lords_bag' logo png size='massive' />
            </Col>
          </Row>

          <Row columns={'equal'}>
            <Col>
              <LordsBagIcon size='mini' />
              <LordsBagIcon size='tiny' />
              <LordsBagIcon size='small' />
              <LordsBagIcon size='small' />
              <LordsBagIcon />
              <LordsBagIcon size='large' />
              <LordsBagIcon size='big' />
              <LordsBagIcon size='huge' />
              <LordsBagIcon size='massive' />
            </Col>
          </Row>


        </Grid>
      </Container>
    </App>
  );
}
