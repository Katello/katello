import { translate as __ } from 'foremanReact/common/I18n';
import { hideRepoSetsTab } from '../RepositorySetsTab/RepositorySetsTab';
import { hideModuleStreamsTab } from '../ModuleStreamsTab/ModuleStreamsTab';

const SECONDARY_TABS = [
  { key: 'packages', title: __('Packages') },
  { key: 'errata', title: __('Errata') },
  { key: 'module-streams', hideTab: hideModuleStreamsTab, title: __('Module streams') },
  { key: 'Repository sets', hideTab: hideRepoSetsTab, title: __('Repository sets') },
];

export default SECONDARY_TABS;
