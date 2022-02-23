import React, { useCallback, useState } from 'react';
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
  Skeleton,
  Split,
  SplitItem,
} from '@patternfly/react-core';
import { TableVariant, Thead, Tbody, Tr, Th, Td } from '@patternfly/react-table';
import { translate as __ } from 'foremanReact/common/I18n';
import { selectAPIResponse } from 'foremanReact/redux/API/APISelectors';

import { urlBuilder } from 'foremanReact/common/urlHelpers';
import SelectableDropdown from '../../../SelectableDropdown';
import TableWrapper from '../../../../components/Table/TableWrapper';
import { useBulkSelect, useTableSort, useUrlParams } from '../../../../components/Table/TableHooks';
import { PackagesStatus, PackagesLatestVersion } from '../../../../components/Packages';
import {
  getInstalledPackagesWithLatest,
  removePackageViaKatelloAgent,
  upgradeAllViaKatelloAgent,
  upgradePackageViaKatelloAgent,
} from '../HostPackages/HostPackagesActions';
import { selectHostPackagesStatus } from '../HostPackages/HostPackagesSelectors';
import {
  HOST_PACKAGES_KEY, PACKAGES_VERSION_STATUSES, VERSION_STATUSES_TO_PARAM,
} from '../HostPackages/HostPackagesConstants';
import { removePackage, updatePackage, removePackages, updatePackages } from './RemoteExecutionActions';
import { katelloPackageUpdateUrl, packagesUpdateUrl } from './customizedRexUrlHelpers';
import './PackagesTab.scss';
import hostIdNotReady from '../HostDetailsActions';
import PackageInstallModal from './PackageInstallModal';
import defaultRemoteActionMethod, { KATELLO_AGENT } from '../hostDetailsHelpers';
import SortableColumnHeaders from '../../../Table/components/SortableColumnHeaders';

export const PackagesTab = () => {
  const hostDetails = useSelector(state => selectAPIResponse(state, 'HOST_DETAILS'));
  const {
    id: hostId,
    name: hostname,
  } = hostDetails;

  const dispatch = useDispatch();
  const PACKAGE_STATUS = __('Status');
  const [packageStatusSelected, setPackageStatusSelected] = useState(PACKAGE_STATUS);
  const activeFilters = [packageStatusSelected];
  const defaultFilters = [PACKAGE_STATUS];
  const [isBulkActionOpen, setIsBulkActionOpen] = useState(false);
  const toggleBulkAction = () => setIsBulkActionOpen(prev => !prev);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const closeModal = () => setIsModalOpen(false);
  const showKatelloAgent = (defaultRemoteActionMethod({ hostDetails }) === KATELLO_AGENT);

  const [isActionOpen, setIsActionOpen] = useState(false);
  const onActionSelect = () => {
    setIsActionOpen(false);
  };
  const onActionToggle = () => {
    setIsActionOpen(prev => !prev);
  };

  const emptyContentTitle = __('This host does not have any packages.');
  const emptyContentBody = __('Packages will appear here when available.');
  const emptySearchTitle = __('No matching packages found');
  const emptySearchBody = __('Try changing your search settings.');
  const errorSearchTitle = __('Problem searching packages');
  const columnHeaders = [
    __('Package'),
    __('Status'),
    __('Installed Version'),
    __('Upgradable To'),
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
    selectedCount,
    isSelectable,
    selectedResults,
    updateSearchQuery,
    selectNone,
    selectAllMode,
    areAllRowsSelected,
    fetchBulkParams,
    ...selectAll
  } = useBulkSelect({
    results,
    metadata,
  });

  if (!hostId) return <Skeleton />;

  const handleInstallPackagesClick = () => {
    setIsBulkActionOpen(false);
    setIsModalOpen(true);
  };

  const removePackageViaRemoteExecution = packageName => dispatch(removePackage({
    hostname,
    packageName,
  }));

  const removeViaKatelloAgent = (packageName) => {
    dispatch(removePackageViaKatelloAgent(hostId, { packages: [packageName] }));
    selectNone();
  };

  const removePackagesViaRemoteExecution = () => {
    const selected = fetchBulkParams();
    setIsBulkActionOpen(false);
    selectNone();
    dispatch(removePackages({ hostname, search: selected }));
  };

  const selectedPackageNames = () => selectedResults.map(({ name }) => name);
  const selectedUpgradableVersions = () => selectedResults.map(({ upgradable_version: v }) => v);

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

  const upgradeViaRemoteExecution = packageName => dispatch(updatePackage({
    hostname,
    packageName,
  }));

  const upgradeBulkViaRemoteExecution = () => {
    const selected = fetchBulkParams();
    setIsBulkActionOpen(false);
    selectNone();
    dispatch(updatePackages({
      hostname,
      search: selected,
    }));
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
    packagesUpdateUrl({ hostname, search: fetchBulkParams() }) :
    '#';

  const disableRemove = () => selectedCount === 0 || selectAllMode;

  const allUpgradable = () => selectedResults.length > 0 &&
    selectedResults.every(item => item.upgradable_version);
  const disableUpgrade = () => selectedCount === 0 ||
    (selectAllMode && packageStatusSelected !== 'Upgradable') ||
    (defaultRemoteAction === KATELLO_AGENT && selectAllMode && !areAllRowsSelected()) ||
    (!selectAllMode && !allUpgradable());

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

  const actionButtons = (
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
                  isDisabled={disableUpgrade()}
                  splitButtonVariant="action"
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
  );

  const toggleGroup = (
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
            toggleGroup,
            selectedCount,
            selectNone,
            areAllRowsSelected,
          }
          }
          additionalListeners={[hostId, packageStatusSelected,
            activeSortDirection, activeSortColumn]}
          fetchItems={fetchItems}
          autocompleteEndpoint={`/hosts/${hostId}/packages/auto_complete_search`}
          foremanApiAutoComplete
          rowsCount={results?.length}
          variant={TableVariant.compact}
          {...selectAll}
          displaySelectAllCheckbox
        >
          <Thead>
            <Tr>
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
                upgradable_version: upgradableVersion,
              } = pkg;

              const rowActions = [
                {
                  title: __('Remove'),
                  onClick: () => handlePackageRemove(packageName),
                },
              ];

              if (upgradableVersion) {
                rowActions.unshift(
                  {
                    title: __('Upgrade via remote execution'),
                    onClick: () => upgradeViaRemoteExecution(upgradableVersion),
                  },
                  {
                    title: __('Upgrade via customized remote execution'),
                    component: 'a',
                    href: katelloPackageUpdateUrl({ hostname, packageName: upgradableVersion }),
                  },
                );
              }

              return (
                <Tr key={`${id}`}>
                  <Td select={{
                      disable: false,
                      isSelected: isSelected(id),
                      onSelect: (event, selected) => selectOne(selected, id, pkg),
                      rowIndex,
                      variant: 'checkbox',
                    }}
                  />
                  <Td>
                    {rpmId
                      ? <a href={urlBuilder(`packages/${rpmId}`, '')}>{packageName}</a>
                      : packageName
                    }
                  </Td>
                  <Td><PackagesStatus {...pkg} /></Td>
                  <Td>{installedVersion.replace(`${packageName}-`, '')}</Td>
                  <Td><PackagesLatestVersion {...pkg} /></Td>
                  <Td
                    key={`rowActions-${id}`}
                    actions={{
                      items: rowActions,
                    }}
                  />
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
        hostName={hostname}
        showKatelloAgent={showKatelloAgent}
      />
      }
    </div>
  );
};

export default PackagesTab;
