import React, { useCallback, useState, useRef } from 'react';
import { useSelector, useDispatch } from 'react-redux';
import {
  ActionList,
  ActionListItem,
  Dropdown,
  DropdownItem,
  DropdownSeparator,
  DropdownToggle,
  DropdownToggleAction,
  KebabToggle,
  Select,
  SelectOption,
  SelectVariant,
  Skeleton,
  Split,
  SplitItem,
} from '@patternfly/react-core';
import { TableVariant, Thead, Tbody, Tr, Th, Td, TableText } from '@patternfly/react-table';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { selectAPIResponse } from 'foremanReact/redux/API/APISelectors';

import { urlBuilder } from 'foremanReact/common/urlHelpers';
import SelectableDropdown from '../../../../SelectableDropdown';
import TableWrapper from '../../../../../components/Table/TableWrapper';
import { useBulkSelect, useTableSort, useUrlParams, useSet } from '../../../../../components/Table/TableHooks';
import PackagesStatus from '../../../../../components/Packages';
import {
  getInstalledPackagesWithLatest,
  removePackageViaKatelloAgent,
  upgradeAllViaKatelloAgent,
  upgradePackageViaKatelloAgent,
} from './HostPackagesActions';
import { selectHostPackagesStatus } from './HostPackagesSelectors';
import {
  HOST_PACKAGES_KEY, PACKAGES_VERSION_STATUSES, VERSION_STATUSES_TO_PARAM,
} from './HostPackagesConstants';
import { removePackage, updatePackage, removePackages, updatePackages, installPackageBySearch } from '../RemoteExecutionActions';
import { katelloPackageUpdateUrl, packagesUpdateUrl } from '../customizedRexUrlHelpers';
import './PackagesTab.scss';
import hostIdNotReady, { getHostDetails } from '../../HostDetailsActions';
import PackageInstallModal from './PackageInstallModal';
import { defaultRemoteActionMethod,
  hasRequiredPermissions as can,
  missingRequiredPermissions as cannot,
  KATELLO_AGENT,
  userPermissionsFromHostDetails } from '../../hostDetailsHelpers';
import SortableColumnHeaders from '../../../../Table/components/SortableColumnHeaders';
import { useRexJobPolling } from '../RemoteExecutionHooks';

const invokeRexJobs = ['create_job_invocations'];
const doKatelloAgentActions = ['edit_hosts'];
const createBookmarks = ['create_bookmarks'];

const UpdateVersionsSelect = ({
  packageName,
  rowIndex,
  selections,
  upgradableVersions,
  toggleUpgradableVersionSelect,
  onUpgradableVersionSelect,
  upgradableVersionSelectOpen,
}) => {
  if (upgradableVersions === null) {
    return <TableText wrapModifier="nowrap">—</TableText>;
  } else if (upgradableVersions.length === 1) {
    return <TableText wrapModifier="nowrap">{upgradableVersions[0]}</TableText>;
  }

  return (
    <div>
      <span id="style-select-id">
        <Select
          variant={SelectVariant.single}
          aria-label="upgradable-version-select"
          ouiaId="upgradable-version-select"
          onToggle={isOpen => toggleUpgradableVersionSelect(isOpen, rowIndex)}
          onSelect={(event, selected) => {
            onUpgradableVersionSelect(event, selected, rowIndex, packageName);
          }}
          selections={selections}
          isOpen={upgradableVersionSelectOpen.has(rowIndex)}
          isPlain
        >
          {upgradableVersions.map(version => (
            <SelectOption
              key={version}
              value={version}
              label={`${version}-version-select-option`}
            />
          ))}
        </Select>
      </span>
    </div>
  );
};

UpdateVersionsSelect.propTypes = {
  packageName: PropTypes.string.isRequired,
  rowIndex: PropTypes.number.isRequired,
  selections: PropTypes.string,
  upgradableVersions: PropTypes.arrayOf(PropTypes.string),
  toggleUpgradableVersionSelect: PropTypes.func,
  onUpgradableVersionSelect: PropTypes.func,
  upgradableVersionSelectOpen: PropTypes.shape({
    has: PropTypes.func,
    rowIndex: PropTypes.number,
  }),
};

UpdateVersionsSelect.defaultProps = {
  selections: null,
  upgradableVersions: null,
  toggleUpgradableVersionSelect: undefined,
  onUpgradableVersionSelect: undefined,
  upgradableVersionSelectOpen: null,
};

export const PackagesTab = () => {
  const hostDetails = useSelector(state => selectAPIResponse(state, 'HOST_DETAILS'));
  const {
    id: hostId,
    name: hostname,
  } = hostDetails;

  const { searchParam, status: statusParam } = useUrlParams();
  const dispatch = useDispatch();
  const PACKAGE_STATUS = __('Status');
  const [packageStatusSelected, setPackageStatusSelected] = useState(statusParam ?? PACKAGE_STATUS);
  const activeFilters = [packageStatusSelected];
  const defaultFilters = [PACKAGE_STATUS];
  const [isBulkActionOpen, setIsBulkActionOpen] = useState(false);
  const toggleBulkAction = () => setIsBulkActionOpen(prev => !prev);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const closeModal = () => setIsModalOpen(false);
  const showKatelloAgent = (defaultRemoteActionMethod({ hostDetails }) === KATELLO_AGENT);
  const showActions = showKatelloAgent ?
    can(doKatelloAgentActions, userPermissionsFromHostDetails({ hostDetails })) :
    can(invokeRexJobs, userPermissionsFromHostDetails({ hostDetails }));

  const [isActionOpen, setIsActionOpen] = useState(false);
  const onActionSelect = () => {
    setIsActionOpen(false);
  };
  const onActionToggle = () => {
    setIsActionOpen(prev => !prev);
  };

  const upgradableVersionSelectOpen = useSet([]);
  const toggleUpgradableVersionSelect = (isOpenState, rowIndex) => {
    if (isOpenState) {
      upgradableVersionSelectOpen.add(rowIndex);
    } else {
      upgradableVersionSelectOpen.delete(rowIndex);
    }
  };

  const selectedNewVersions = useRef({});
  const onUpgradableVersionSelect = (_event, selected, rowIndex, packageName) => {
    toggleUpgradableVersionSelect(false, rowIndex);
    selectedNewVersions.current[packageName] = selected;
  };
  const selectedPackageUpgradeVersion = ({ packageName, upgradableVersions }) => (
    selectedNewVersions.current[packageName] || upgradableVersions[0]
  );
  const selectedNVRAVersions = Object.keys(selectedNewVersions.current).map(k =>
    selectedNewVersions.current[k]);

  const emptyContentTitle = __('This host does not have any packages.');
  const emptyContentBody = __('Packages will appear here when available.');
  const emptySearchTitle = __('No matching packages found');
  const emptySearchBody = __('Try changing your search settings.');
  const errorSearchTitle = __('Problem searching packages');
  const columnHeaders = [
    __('Package'),
    __('Status'),
    __('Installed version'),
    __('Upgradable to'),
  ];

  const COLUMNS_TO_SORT_PARAMS = {
    [columnHeaders[0]]: 'nvra',
    [columnHeaders[2]]: 'version',
  };

  const {
    pfSortParams, apiSortParams,
    activeSortColumn, activeSortDirection,
  } = useTableSort({
    allColumns: columnHeaders,
    columnsToSortParams: COLUMNS_TO_SORT_PARAMS,
    initialSortColumnName: 'Package',
  });

  const fetchItems = useCallback(
    (params) => {
      if (!hostId) return hostIdNotReady;
      const modifiedParams = { ...params };
      if (packageStatusSelected !== PACKAGE_STATUS) {
        modifiedParams.status = VERSION_STATUSES_TO_PARAM[packageStatusSelected];
      }
      return getInstalledPackagesWithLatest(hostId, { ...apiSortParams, ...modifiedParams });
    },
    [hostId, PACKAGE_STATUS, packageStatusSelected, apiSortParams],
  );

  const response = useSelector(state => selectAPIResponse(state, HOST_PACKAGES_KEY));
  const { results, ...metadata } = response;
  const { error: errorSearchBody } = metadata;
  const status = useSelector(state => selectHostPackagesStatus(state));
  const {
    selectOne,
    isSelected,
    searchQuery,
    updateSearchQuery,
    selectedCount,
    isSelectable,
    selectedResults,
    selectNone,
    selectAllMode,
    areAllRowsSelected,
    fetchBulkParams,
    ...selectAll
  } = useBulkSelect({
    results,
    metadata,
    initialSearchQuery: searchParam || '',
  });

  const packageRemoveAction = packageName => removePackage({
    hostname,
    packageName,
  });

  const {
    triggerJobStart: triggerPackageRemove, lastCompletedJob: lastCompletedPackageRemove,
    isPolling: isRemoveInProgress,
  } = useRexJobPolling(packageRemoveAction);

  const packageBulkRemoveAction = bulkParams => removePackages({
    hostname,
    search: bulkParams,
  });

  const {
    triggerJobStart: triggerBulkPackageRemove,
    lastCompletedJob: lastCompletedBulkPackageRemove,
    isPolling: isBulkRemoveInProgress,
  } = useRexJobPolling(packageBulkRemoveAction);

  const packageUpgradeAction = ({ packageName, upgradableVersions }) => updatePackage({
    hostname,
    packageName: selectedPackageUpgradeVersion({ packageName, upgradableVersions }),
  });

  const {
    triggerJobStart: triggerPackageUpgrade,
    lastCompletedJob: lastCompletedPackageUpgrade,
    isPolling: isUpgradeInProgress,
  } = useRexJobPolling(packageUpgradeAction, getHostDetails({ hostname }));

  const packageBulkUpgradeAction = bulkParams => updatePackages({
    hostname,
    search: bulkParams,
    versions: JSON.stringify(selectedNVRAVersions || []),
  });

  const {
    triggerJobStart: triggerBulkPackageUpgrade,
    lastCompletedJob: lastCompletedBulkPackageUpgrade,
    isPolling: isBulkUpgradeInProgress,
  } = useRexJobPolling(packageBulkUpgradeAction, getHostDetails({ hostname }));

  const packageInstallAction
    = bulkParams => installPackageBySearch({ hostname, search: bulkParams });

  const {
    triggerJobStart: triggerPackageInstall,
    lastCompletedJob: lastCompletedPackageInstall,
    isPolling: isInstallInProgress,
  } = useRexJobPolling(packageInstallAction, getHostDetails({ hostname }));

  const actionInProgress = (isRemoveInProgress || isUpgradeInProgress
    || isBulkRemoveInProgress || isBulkUpgradeInProgress || isInstallInProgress);
  const disabledReason = __('A remote execution job is in progress.');

  if (!hostId) return <Skeleton />;

  const handleInstallPackagesClick = () => {
    setIsBulkActionOpen(false);
    setIsModalOpen(true);
  };

  const removePackageViaRemoteExecution = packageName => triggerPackageRemove(packageName);

  const removeViaKatelloAgent = (packageName) => {
    dispatch(removePackageViaKatelloAgent(hostId, { packages: [packageName] }));
    selectNone();
  };

  const removePackagesViaRemoteExecution = () => {
    const selected = fetchBulkParams();
    setIsBulkActionOpen(false);
    selectNone();
    triggerBulkPackageRemove(selected);
  };

  const selectedPackageNames = () => selectedResults.map(({ name }) => name);
  const selectedUpgradableVersions = () => selectedResults.map(({ name, upgradable_versions: v }) =>
    selectedNewVersions.current[name] || v[0]);

  const removePackagesViaKatelloAgent = () => {
    dispatch(removePackageViaKatelloAgent(hostId, { packages: selectedPackageNames() }));
    selectNone();
  };

  const defaultRemoteAction = defaultRemoteActionMethod({ hostDetails });

  const removeBulk = () => {
    if (defaultRemoteAction === KATELLO_AGENT) {
      removePackagesViaKatelloAgent();
    } else {
      removePackagesViaRemoteExecution();
    }
  };

  const handlePackageRemove = (packageName) => {
    if (defaultRemoteAction === KATELLO_AGENT) {
      removeViaKatelloAgent(packageName);
    } else {
      removePackageViaRemoteExecution(packageName);
    }
  };

  const upgradeViaRemoteExecution = ({ packageName, upgradableVersions }) => (
    triggerPackageUpgrade({ packageName, upgradableVersions })
  );

  const upgradeBulkViaRemoteExecution = () => {
    const selected = fetchBulkParams();
    setIsBulkActionOpen(false);
    selectNone();
    triggerBulkPackageUpgrade(selected);
  };

  const upgradeBulkViaKatelloAgent = () => {
    if (areAllRowsSelected()) {
      dispatch(upgradeAllViaKatelloAgent(hostId));
    } else {
      dispatch(upgradePackageViaKatelloAgent(hostId, { packages: selectedUpgradableVersions() }));
    }
    selectNone();
  };

  const upgradeBulk = () => {
    if (defaultRemoteAction === KATELLO_AGENT) {
      upgradeBulkViaKatelloAgent();
    } else {
      upgradeBulkViaRemoteExecution();
    }
  };

  const upgradeViaCustomizedRemoteExecution = selectedCount ?
    packagesUpdateUrl({
      hostname,
      search: fetchBulkParams(),
      versions: JSON.stringify(selectedNVRAVersions),
    }) : '#';

  const disableRemove = () => selectedCount === 0 || selectAllMode;

  const allUpgradable = () => selectedResults.length > 0 &&
    selectedResults.every(item => item.upgradable_versions?.length > 0);
  const disableUpgrade = () => selectedCount === 0 ||
    (selectAllMode && packageStatusSelected !== 'Upgradable') ||
    (defaultRemoteAction === KATELLO_AGENT && selectAllMode && !areAllRowsSelected()) ||
    (!selectAllMode && !allUpgradable());

  const readOnlyBookmarks =
  cannot(createBookmarks, userPermissionsFromHostDetails({ hostDetails }));

  const dropdownUpgradeItems = [
    <DropdownItem
      aria-label="bulk_upgrade_rex"
      key="bulk_upgrade_rex"
      component="button"
      onClick={upgradeBulkViaRemoteExecution}
    >
      {__('Upgrade via remote execution')}
    </DropdownItem>,
    <DropdownItem
      aria-label="bulk_upgrade_customized_rex"
      key="bulk_upgrade_customized_rex"
      component="a"
      href={upgradeViaCustomizedRemoteExecution}
    >
      {__('Upgrade via customized remote execution')}
    </DropdownItem>,
  ];

  const dropdownRemoveItems = [
    <DropdownItem
      aria-label="bulk_remove"
      key="bulk_remove"
      component="button"
      onClick={removeBulk}
      isDisabled={disableRemove()}
    >
      {__('Remove')}
    </DropdownItem>,
    <DropdownSeparator key="separator" />,
    <DropdownItem
      aria-label="install_pkg_on_host"
      key="install_pkg_on_host"
      component="button"
      onClick={handleInstallPackagesClick}
    >
      {__('Install packages')}
    </DropdownItem>,
  ];

  const handlePackageStatusSelected = newStatus => setPackageStatusSelected((prevStatus) => {
    if (prevStatus === newStatus) {
      return PACKAGE_STATUS;
    }
    return newStatus;
  });

  const actionButtons = showActions ? (
    <Split hasGutter>
      <SplitItem>
        <ActionList isIconList>
          <ActionListItem>
            <Dropdown
              onSelect={onActionSelect}
              toggle={
                <DropdownToggle
                  splitButtonItems={[
                    <DropdownToggleAction key="action" aria-label="upgrade_actions" onClick={upgradeBulk}>
                      {__('Upgrade')}
                    </DropdownToggleAction>,
                  ]}
                  isDisabled={actionInProgress || disableUpgrade()}
                  splitButtonVariant="action"
                  toggleVariant="primary"
                  onToggle={onActionToggle}
                />
              }
              isOpen={isActionOpen}
              dropdownItems={dropdownUpgradeItems}
            />
          </ActionListItem>
          <ActionListItem>
            <Dropdown
              toggle={<KebabToggle aria-label="bulk_actions" onToggle={toggleBulkAction} />}
              isOpen={isBulkActionOpen}
              isPlain
              dropdownItems={dropdownRemoveItems}
            />
          </ActionListItem>
        </ActionList>
      </SplitItem>
    </Split>
  ) : null;

  const statusFilters = (
    <Split hasGutter>
      <SplitItem>
        <SelectableDropdown
          id="package-status-dropdown"
          title={PACKAGE_STATUS}
          showTitle={false}
          items={Object.values(PACKAGES_VERSION_STATUSES)}
          selected={packageStatusSelected}
          setSelected={handlePackageStatusSelected}
        />
      </SplitItem>
    </Split>
  );

  const resetFilters = () => setPackageStatusSelected(PACKAGE_STATUS);

  return (
    <div>
      <div id="packages-tab">
        <TableWrapper
          {...{
            metadata,
            emptyContentTitle,
            emptyContentBody,
            emptySearchTitle,
            emptySearchBody,
            errorSearchTitle,
            errorSearchBody,
            status,
            activeFilters,
            defaultFilters,
            actionButtons,
            searchQuery,
            updateSearchQuery,
            toggleGroup: statusFilters,
            selectedCount,
            selectNone,
            areAllRowsSelected,
            resetFilters,
          }
          }
          ouiaId="host-packages-table"
          additionalListeners={[hostId, packageStatusSelected,
            activeSortDirection, activeSortColumn, lastCompletedPackageUpgrade,
            lastCompletedPackageRemove, lastCompletedBulkPackageRemove,
            lastCompletedBulkPackageUpgrade, lastCompletedPackageInstall]}
          fetchItems={fetchItems}
          bookmarkController="katello_host_installed_packages"
          readOnlyBookmarks={readOnlyBookmarks}
          autocompleteEndpoint={`/hosts/${hostId}/packages/auto_complete_search`}
          foremanApiAutoComplete
          rowsCount={results?.length}
          variant={TableVariant.compact}
          {...selectAll}
          displaySelectAllCheckbox={showActions}
          requestKey={HOST_PACKAGES_KEY}
          alwaysShowActionButtons={false}
        >
          <Thead>
            <Tr>
              <Th key="select-all" />
              <SortableColumnHeaders
                columnHeaders={columnHeaders}
                pfSortParams={pfSortParams}
                columnsToSortParams={COLUMNS_TO_SORT_PARAMS}
              />
              <Th />
            </Tr>
          </Thead>
          <Tbody>
            {results?.map((pkg, rowIndex) => {
              const {
                id,
                name: packageName,
                nvra: installedVersion,
                rpm_id: rpmId,
                upgradable_versions: upgradableVersions,
              } = pkg;

              const rowActions = [
                {
                  title: __('Remove'),
                  isDisabled: actionInProgress,
                  onClick: () => handlePackageRemove(packageName),
                },
              ];

              if (upgradableVersions) {
                rowActions.unshift(
                  {
                    title: __('Upgrade via remote execution'),
                    onClick: () => upgradeViaRemoteExecution({ packageName, upgradableVersions }),
                    isDisabled: actionInProgress,
                  },
                  {
                    title: __('Upgrade via customized remote execution'),
                    component: 'a',
                    href: katelloPackageUpdateUrl({
                      hostname,
                      packageName: selectedPackageUpgradeVersion({
                        packageName,
                        upgradableVersions,
                      }),
                    }),
                  },
                );
              }

              return (
                <Tr key={`${id}`}>
                  {showActions ? (
                    <Td
                      select={{
                        disable: actionInProgress,
                        isSelected: isSelected(id),
                        onSelect: (event, selected) => selectOne(selected, id, pkg),
                        rowIndex,
                        variant: 'checkbox',
                      }}
                      title={actionInProgress ? disabledReason : undefined}
                    />
                  ) : <Td>&nbsp;</Td>}
                  <Td>
                    {rpmId
                      ? <a href={urlBuilder(`packages/${rpmId}`, '')}>{packageName}</a>
                      : packageName
                    }
                  </Td>
                  <Td><PackagesStatus {...pkg} /></Td>
                  <Td>{installedVersion.replace(`${packageName}-`, '')}</Td>
                  <Td>
                    <UpdateVersionsSelect
                      packageName={packageName}
                      rowIndex={rowIndex}
                      selections={selectedNewVersions.current[packageName]}
                      upgradableVersions={upgradableVersions}
                      toggleUpgradableVersionSelect={toggleUpgradableVersionSelect}
                      onUpgradableVersionSelect={onUpgradableVersionSelect}
                      upgradableVersionSelectOpen={upgradableVersionSelectOpen}
                    />
                  </Td>
                  {showActions ? (
                    <Td
                      key={`rowActions-${id}`}
                      actions={{
                        items: rowActions,
                      }}
                    />
                  ) : null}
                </Tr>
              );
            })
            }
          </Tbody>
        </TableWrapper>
      </div>
      {hostId &&
        <PackageInstallModal
          isOpen={isModalOpen}
          closeModal={closeModal}
          hostId={hostId}
          key={hostId}
          hostName={hostname}
          showKatelloAgent={showKatelloAgent}
          triggerPackageInstall={triggerPackageInstall}
        />
      }
    </div>
  );
};

export default PackagesTab;
