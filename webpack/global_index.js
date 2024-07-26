import React from 'react';
import { addGlobalFill } from 'foremanReact/components/common/Fill/GlobalFill';
import { registerReducer } from 'foremanReact/common/MountingService';
import { translate as __ } from 'foremanReact/common/I18n';
import { registerColumns } from 'foremanReact/components/HostsIndex/Columns/core';
import componentRegistry from 'foremanReact/components/componentRegistry';
import { registerGetActions } from 'foremanReact/components/HostsIndex/TableRowActions/core';

import hostsIndexColumnExtensions from './ForemanColumnExtensions/index';
import hostTableRowActions from './components/extensions/Hosts/TableRowActions';
import SystemStatuses from './components/extensions/about';
import {
  RegistrationCommands,
  RegistrationActivationKeys,
} from './components/extensions/RegistrationCommands';
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
import {
  SystemPropertiesCardSubscription,
  SystemPropertiesCardVirtualization,
  SystemPropertiesCardTracer,
} from './components/extensions/HostDetails/DetailsTabCards/SystemPropertiesCardExtensions';
import HostDetailsActionsBar from './components/extensions/HostDetails/ActionsBar';
import HostsIndexActionsBar from './components/extensions/Hosts/ActionsBar';
import RecentCommunicationCardExtensions from './components/extensions/HostDetails/DetailsTabCards/RecentCommunicationCardExtensions';
import SystemPurposeCard from './components/extensions/HostDetails/Cards/SystemPurposeCard/SystemPurposeCard';
import BulkChangeHostCVModal from './components/extensions/Hosts/BulkActions/BulkChangeHostCVModal/index.js';
import BulkPackagesWizardModal from './components/extensions/Hosts/BulkActions/BulkPackagesWizard/index.js';
import BulkErrataWizardModal from './components/extensions/Hosts/BulkActions/BulkErrataWizard/index.js';
import ActivationKeysSearch from './components/ActivationKeysSearch';

registerReducer('katelloExtends', extendReducer);
registerReducer('katello', rootReducer);

addGlobalFill('aboutFooterSlot', '[katello]AboutSystemStatuses', <SystemStatuses key="katello-system-statuses" />, 100);
addGlobalFill('registrationAdvanced', '[katello]RegistrationCommands', <RegistrationCommands key="katello-reg" />, 100);
addGlobalFill('registrationGeneral', '[katello]RegistrationActivationKeys', <RegistrationActivationKeys key="katello-reg-ak" />, 100);

// Host details page tabs
addGlobalFill('host-details-page-tabs', 'Content', <ContentTab key="content" />, 900, { title: __('Content'), hideTab: hostIsNotRegistered });
addGlobalFill('host-details-page-tabs', 'Traces', <TracesTab key="traces" />, 800, { title: __('Traces'), hideTab: hostIsNotRegistered });

// Overview tab cards & card extensions
addGlobalFill(
  'host-overview-cards',
  'Content view details',
  <ContentViewDetailsCard key="content-view-details" />,
  3800,
);
addGlobalFill(
  'host-overview-cards',
  'Host collections',
  <HostCollectionsCard key="host-collections-details" />,
  2600,
);
addGlobalFill('host-overview-cards', 'Installable errata', <ErrataOverviewCard key="errata-overview" />, 3600);
addGlobalFill('host-overview-cards', 'System purpose', <SystemPurposeCard key="system-purpose" />, 1400);
addGlobalFill('recent-communication-card-item', 'Recent communication', <RecentCommunicationCardExtensions key="recent-communication" />, 3000);

// Details tab cards & card extensions
addGlobalFill('host-tab-details-cards', 'Installed products', <InstalledProductsCard key="installed-products" />, 100);
addGlobalFill('host-tab-details-cards', 'Registration details', <RegistrationCard key="registration-details" />, 200);
addGlobalFill('host-details-tab-properties-1', 'Subscription UUID', <SystemPropertiesCardSubscription key="subscription-uuid" />);
addGlobalFill('host-details-tab-properties-2', 'Tracer', <SystemPropertiesCardTracer key="tracer-status" />);
addGlobalFill('host-details-tab-properties-3', 'Virtualization', <SystemPropertiesCardVirtualization key="virtualization" />);

addGlobalFill(
  'host-details-kebab',
  'katello-host-details-kebab',
  <HostDetailsActionsBar key="katello-host-details-kebab" />,
  100,
);

addGlobalFill(
  'hosts-index-kebab',
  'katello-hosts-index-kebab',
  <HostsIndexActionsBar key="katello-hosts-index-kebab" />,
  100,
);

addGlobalFill('host-tab-details-cards', 'HW properties', <HwPropertiesCard key="hw-properties" />, 200);

// Hosts Index page extensions
addGlobalFill('_all-hosts-modals', 'BulkChangeHostCVModal', <BulkChangeHostCVModal key="bulk-change-host-cv-modal" />, 100);
addGlobalFill('_all-hosts-modals', 'BulkPackagesWizardModal', <BulkPackagesWizardModal key="bulk-packages-wizard-modal" />, 200);
addGlobalFill('_all-hosts-modals', 'BulkErrataWizardModal', <BulkErrataWizardModal key="bulk-errata-wizard-modal" />, 200);

registerColumns(hostsIndexColumnExtensions);
registerGetActions({
  pluginName: 'katello',
  getActionsFunc: hostTableRowActions,
  tableName: 'hosts',
});

componentRegistry.register({
  name: 'ActivationKeysSearch',
  type: ActivationKeysSearch,
});

