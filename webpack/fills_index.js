import React from 'react';
import { addGlobalFill } from 'foremanReact/components/common/Fill/GlobalFill';
import { registerReducer } from 'foremanReact/common/MountingService';

import SystemStatuses from './components/extensions/about';
import ContentTab from './components/extensions/HostDetails/Tabs/ContentTab';
import SubscriptionTab from './components/extensions/HostDetails/Tabs/SubscriptionTab';
import extendReducer from './components/extensions/reducers';

registerReducer('katelloExtends', extendReducer);

addGlobalFill('aboutFooterSlot', '[katello]AboutSystemStatuses', <SystemStatuses key="katello-system-statuses" />, 100);
addGlobalFill('host-details-page-tabs', 'Content', <ContentTab key="content-tab" />, 100);
addGlobalFill('host-details-page-tabs', 'Subscription', <SubscriptionTab key="subscription-tab" />, 2000);
