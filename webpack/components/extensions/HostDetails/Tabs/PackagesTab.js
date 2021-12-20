import React, { useCallback, useState } from 'react';
import { useSelector } from 'react-redux';
import { Button, Hint, HintBody, DropdownItem, DropdownSeparator, Dropdown, Split, SplitItem, ActionList, ActionListItem, KebabToggle } from '@patternfly/react-core';
import { TableVariant, Thead, Tbody, Tr, Th, Td } from '@patternfly/react-table';
import { translate as __ } from 'foremanReact/common/I18n';
import { selectAPIResponse } from 'foremanReact/redux/API/APISelectors';

import { urlBuilder } from 'foremanReact/common/urlHelpers';
import SelectableDropdown from '../../../SelectableDropdown';
import TableWrapper from '../../../../components/Table/TableWrapper';
import { useUrlParams } from '../../../../components/Table/TableHooks';
import { PackagesStatus, PackagesLatestVersion } from '../../../../components/Packages';
import { getInstalledPackagesWithLatest } from '../HostPackages/HostPackagesActions';
import { selectHostPackagesStatus } from '../HostPackages/HostPackagesSelectors';
import { HOST_PACKAGES_KEY, PACKAGES_VERSION_STATUSES, VERSION_STATUSES_TO_PARAM } from '../HostPackages/HostPackagesConstants';
import './PackagesTab.scss';
import hostIdNotReady from '../HostDetailsActions';

export const PackagesTab = () => {
  const hostDetails = useSelector(state => selectAPIResponse(state, 'HOST_DETAILS'));
  const { id: hostId } = hostDetails;

  const { searchParam } = useUrlParams();
  const [searchQuery, updateSearchQuery] = useState(searchParam || '');
  const PACKAGE_STATUS = __('Status');
  const [packageStatusSelected, setPackageStatusSelected] = useState(PACKAGE_STATUS);
  const activeFilters = [packageStatusSelected];
  const defaultFilters = [PACKAGE_STATUS];
  const [isBulkActionOpen, setIsBulkActionOpen] = useState(false);
  const toggleBulkAction = () => setIsBulkActionOpen(prev => !prev);

  const emptyContentTitle = __('This host does not have any packages.');
  const emptyContentBody = __('Packages will appear here when available.');
  const emptySearchTitle = __('No matching packages found');
  const emptySearchBody = __('Try changing your search settings.');
  const columnHeaders = [
    __('Package'),
    __('Status'),
    __('Installed Version'),
    __('Upgradable To'),
  ];

  const fetchItems = useCallback(
    (params) => {
      if (!hostId) return hostIdNotReady;
      const modifiedParams = { ...params };
      if (packageStatusSelected !== PACKAGE_STATUS) {
        modifiedParams.status = VERSION_STATUSES_TO_PARAM[packageStatusSelected];
      }
      return getInstalledPackagesWithLatest(hostId, modifiedParams);
    },
    [hostId, PACKAGE_STATUS, packageStatusSelected],
  );

  const response = useSelector(state => selectAPIResponse(state, HOST_PACKAGES_KEY));
  const { results, ...metadata } = response;
  const status = useSelector(state => selectHostPackagesStatus(state));

  if (!hostId) return null;

  const rowActions = [
    {
      title: __('Upgrade via remote execution'), disabled: true,
    },
    {
      title: __('Upgrade via customized remote execution'), disabled: true,
    },
  ];

  const handlePackageStatusSelected = newStatus => setPackageStatusSelected((prevStatus) => {
    if (prevStatus === newStatus) {
      return PACKAGE_STATUS;
    }
    return newStatus;
  });

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

  const dropdownItems = [
    <DropdownItem
      aria-label="remove_pkg_from_host"
      key="remove_pkg_from_host"
      component="button"
      isDisabled
    >
      {__('Remove')}
    </DropdownItem>,
    <DropdownSeparator />,
    <DropdownItem
      aria-label="install_pkg_on_host"
      key="install_pkg_on_host"
      component="button"
      onClick={toggleBulkAction}
    >
      {__('Install packages')}
    </DropdownItem>,
  ];

  const actionButtons = (
    <>
      <Split hasGutter>
        <SplitItem>
          <ActionList isIconList>
            <ActionListItem>
              <Button isDisabled> {__('Upgrade')} </Button>
            </ActionListItem>
            <ActionListItem>
              <Dropdown
                toggle={<KebabToggle aria-label="Packages bulk actions" onToggle={toggleBulkAction} />}
                isOpen={isBulkActionOpen}
                isPlain
                dropdownItems={dropdownItems}
              />
            </ActionListItem>
          </ActionList>
        </SplitItem>
      </Split>
    </>
  );

  return (
    <div>
      <div id="packages-hint" className="margin-0-24 margin-top-16">
        <Hint>
          <HintBody>
            {__('Packages management functionality on this page is incomplete')}.
            <br />
            <Button component="a" variant="link" isInline href={urlBuilder(`content_hosts/${hostId}/packages/installed`, '')}>
              {__('Visit the previous Packages page')}.
            </Button>
          </HintBody>
        </Hint>
      </div>
      <div id="packages-tab">
        <TableWrapper
          {...{
            metadata,
            emptyContentTitle,
            emptyContentBody,
            emptySearchTitle,
            emptySearchBody,
            status,
            activeFilters,
            defaultFilters,
            actionButtons,
            searchQuery,
            updateSearchQuery,
            toggleGroup,
          }
          }
          additionalListeners={[hostId, packageStatusSelected]}
          fetchItems={fetchItems}
          autocompleteEndpoint={`/hosts/${hostId}/packages/auto_complete_search`}
          foremanApiAutoComplete
          variant={TableVariant.compact}
        >
          <Thead>
            <Tr>
              {columnHeaders.map(col =>
                <Th key={col}>{col}</Th>)}
              <Th />
            </Tr>
          </Thead>
          <Tbody>
            {results?.map((packages) => {
              const {
                id,
                name: packageName,
                nvra: installedVersion,
                rpm_id: rpmId,
              } = packages;
              return (
                <Tr key={`${id}`}>
                  <Td>
                    {rpmId
                      ? <a href={urlBuilder(`packages/${rpmId}`, '')}>{packageName}</a>
                      : packageName
                    }
                  </Td>
                  <Td><PackagesStatus {...packages} /></Td>
                  <Td>{installedVersion.replace(`${packageName}-`, '')}</Td>
                  <Td><PackagesLatestVersion {...packages} /></Td>
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
    </div>
  );
};

export default PackagesTab;
