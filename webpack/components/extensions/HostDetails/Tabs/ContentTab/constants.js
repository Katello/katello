import { translate as __ } from 'foremanReact/common/I18n';
import { hideRepoSetsTab } from '../RepositorySetsTab/RepositorySetsTab';
import { hideModuleStreamsTab } from '../ModuleStreamsTab/ModuleStreamsTab';
import { hideDebsTab } from '../DebsTab/DebsTab';
import { hidePackagesTab } from '../PackagesTab/PackagesTab';

const SECONDARY_TABS = [
  { key: 'debs', hideTab: hideDebsTab, title: __('Packages') },
  { key: 'packages', hideTab: hidePackagesTab, title: __('Packages') },
  { key: 'errata', title: __('Errata') },
  { key: 'module-streams', hideTab: hideModuleStreamsTab, title: __('Module streams') },
  { key: 'Repository sets', hideTab: hideRepoSetsTab, title: __('Repository sets') },
];

export default SECONDARY_TABS;
