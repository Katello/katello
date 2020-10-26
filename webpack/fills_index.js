import React from 'react';
import { addGlobalFill } from 'foremanReact/components/common/Fill/GlobalFill';
import { registerReducer } from 'foremanReact/common/MountingService';
import CardItem from 'foremanReact/components/common/CardTemplate/CardItem';
import SystemStatuses from './components/extensions/about';
import extendReducer from './components/extensions/reducers';

registerReducer('katelloExtends', extendReducer);
addGlobalFill(
  'aboutFooterSlot',
  '[katello]AboutSystemStatuses',
  <SystemStatuses key="katello-system-statuses" />,
  100
);

addGlobalFill(
  'details-cards',
  'dada',
  <CardItem
    content={[
      {
        id: 1,
        name: 'item 1',
        key: 'key 1',
        value: 'value 1',
      },
      {
        id: 2,
        name: 'item 2',
        key: 'key 2',
        value: 'value 2',
      },
    ]}
    header="Katello Card 1"
  />,
  300
);
addGlobalFill(
  'details-cards',
  'dada2',
  <CardItem
    content={[
      {
        id: 1,
        name: 'item 1',
        key: 'key 1',
        value: 'value 1',
      },
      {
        id: 2,
        name: 'item 2',
        key: 'key 2',
        value: 'value 2',
      },
    ]}
    header="Katello Card 2"
  />,
  1000
);
