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
import RegistrationCard from './components/extensions/HostDetails/DetailsTabCards/RegistrationCard';
import HwPropertiesCard from './components/extensions/HostDetails/DetailsTabCards/HwPropertiesCard';

import TracesTab from './components/extensions/HostDetails/Tabs/TracesTab/TracesTab.js';
import extendReducer from './components/extensions/reducers';
import rootReducer from './redux/reducers';
import HostCollectionsCard from './components/extensions/HostDetails/Cards/HostCollectionsCard/HostCollectionsCard';
import { hostIsNotRegistered } from './components/extensions/HostDetails/hostDetailsHelpers';
import SystemPropertiesCardExtensions from './components/extensions/HostDetails/DetailsTabCards/SystemPropertiesCardExtensions';
import HostActionsBar from './components/extensions/HostDetails/ActionsBar';
import RecentCommunicationCardExtensions from './components/extensions/HostDetails/DetailsTabCards/RecentCommunicationCardExtensions';

registerReducer('katelloExtends', extendReducer);
registerReducer('katello', rootReducer);

addGlobalFill('aboutFooterSlot', '[katello]AboutSystemStatuses', <SystemStatuses key="katello-system-statuses" />, 100);
addGlobalFill('registrationAdvanced', '[katello]RegistrationCommands', <RegistrationCommands key="katello-reg" />, 100);

// Host details page tabs
addGlobalFill('host-details-page-tabs', 'Content', <ContentTab key="content" />, 900, { title: __('Content'), hideTab: hostIsNotRegistered });
addGlobalFill('host-details-page-tabs', 'Traces', <TracesTab key="traces" />, 800, { title: __('Traces'), hideTab: hostIsNotRegistered });

// Overview tab cards
addGlobalFill(
  'host-overview-cards',
  'Content view details',
  <ContentViewDetailsCard key="content-view-details" />,
  2000,
);
addGlobalFill(
  'host-overview-cards',
  'Host collections',
  <HostCollectionsCard key="host-collections-details" />,
  700,
);
addGlobalFill('host-overview-cards', 'Installable errata', <ErrataOverviewCard key="errata-overview" />, 1900);
addGlobalFill('recent-communication-card-item', 'Recent communication', <RecentCommunicationCardExtensions key="recent-communication" />, 3000);

// Details tab cards & card extensions
addGlobalFill('host-tab-details-cards', 'Installed products', <InstalledProductsCard key="installed-products" />, 100);
addGlobalFill('host-tab-details-cards', 'Registration details', <RegistrationCard key="registration-details" />, 200);
addGlobalFill('host-details-tab-properties-1', 'Subscription UUID', <SystemPropertiesCardExtensions key="subscription-uuid" />);

addGlobalFill(
  'host-details-kebab',
  'katello-host-details-kebab',
  <HostActionsBar key="katello-host-details-kebab" />,
  100,
);
addGlobalFill('host-tab-details-cards', 'HW properties', <HwPropertiesCard key="hw-properties" />, 200);
