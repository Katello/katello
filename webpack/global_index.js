import React from 'react';
import { addGlobalFill } from 'foremanReact/components/common/Fill/GlobalFill';
import { registerReducer } from 'foremanReact/common/MountingService';
import { translate as __ } from 'foremanReact/common/I18n';

import SystemStatuses from './components/extensions/about';
import RegistrationCommands from './components/extensions/RegistrationCommands';
import ContentTab from './components/extensions/HostDetails/Tabs/ContentTab';
import ContentViewDetailsCard from './components/extensions/HostDetails/Cards/ContentViewDetailsCard/ContentViewDetailsCard';
import ErrataOverviewCard from './components/extensions/HostDetails/Cards/ErrataOverviewCard';
import InstalledProductsCard from './components/extensions/HostDetails/DetailsTabCards/InstalledProductsCard';

// import SubscriptionTab from './components/extensions/HostDetails/Tabs/SubscriptionTab';
import RepositorySetsTab from './components/extensions/HostDetails/Tabs/RepositorySetsTab/RepositorySetsTab';
import TracesTab from './components/extensions/HostDetails/Tabs/TracesTab/TracesTab.js';
import extendReducer from './components/extensions/reducers';
import rootReducer from './redux/reducers';
import HostCollectionsCard from './components/extensions/HostDetails/Cards/HostCollectionsCard/HostCollectionsCard';
import { hostIsNotRegistered } from './components/extensions/HostDetails/hostDetailsHelpers';

registerReducer('katelloExtends', extendReducer);
registerReducer('katello', rootReducer);

addGlobalFill('aboutFooterSlot', '[katello]AboutSystemStatuses', <SystemStatuses key="katello-system-statuses" />, 100);
addGlobalFill('registrationAdvanced', '[katello]RegistrationCommands', <RegistrationCommands key="katello-reg" />, 100);
addGlobalFill('host-details-page-tabs', 'Content', <ContentTab key="content" />, 900, { title: __('Content'), hideTab: hostIsNotRegistered });
/* eslint-disable max-len */
// addGlobalFill('host-details-page-tabs', 'Subscription', <SubscriptionTab key="subscription" />, 100, { title: __('Subscription') });
addGlobalFill('host-details-page-tabs', 'Traces', <TracesTab key="traces" />, 800, { title: __('Traces'), hideTab: hostIsNotRegistered });
addGlobalFill('host-details-page-tabs', 'Repository sets', <RepositorySetsTab key="repository-sets" />, 700, { title: __('Repository sets'), hideTab: hostIsNotRegistered });

addGlobalFill(
  'details-cards',
  'Content view details',
  <ContentViewDetailsCard key="content-view-details" />,
  2000,
);
addGlobalFill(
  'details-cards',
  'Host collections',
  <HostCollectionsCard key="host-collections-details" />,
  700,
);
addGlobalFill('details-cards', 'Installable errata', <ErrataOverviewCard key="errata-overview" />, 1900);
addGlobalFill('host-tab-details-cards', 'Installed products', <InstalledProductsCard key="installed-products" />, 100);
