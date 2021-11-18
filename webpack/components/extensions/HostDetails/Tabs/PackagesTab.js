import React, { useCallback, useState } from 'react';
import { useSelector } from 'react-redux';
import { Button, Hint, HintBody } from '@patternfly/react-core';
import { TableVariant, Thead, Tbody, Tr, Th, Td } from '@patternfly/react-table';
import { translate as __ } from 'foremanReact/common/I18n';
import { selectAPIResponse } from 'foremanReact/redux/API/APISelectors';

import { urlBuilder } from 'foremanReact/common/urlHelpers';
import TableWrapper from '../../../../components/Table/TableWrapper';
import { PackagesStatus, PackagesLatestVersion } from '../../../../components/Packages';
import { getInstalledPackagesWithLatest } from '../HostPackages/HostPackagesActions';
import { selectHostPackagesStatus } from '../HostPackages/HostPackagesSelectors';
import { HOST_PACKAGES_KEY } from '../HostPackages/HostPackagesConstants';
import './PackagesTab.scss';

export const PackagesTab = () => {
  const hostDetails = useSelector(state => selectAPIResponse(state, 'HOST_DETAILS'));
  const { id: hostId } = hostDetails;
  const actionButtons = <Button isDisabled> {__('Upgrade')} </Button>;

  const [searchQuery, updateSearchQuery] = useState('');

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
    params => (hostId ? getInstalledPackagesWithLatest(hostId, params) : null),
    [hostId],
  );

  const response = useSelector(state => selectAPIResponse(state, HOST_PACKAGES_KEY));
  const { results, ...metadata } = response;
  const status = useSelector(state => selectHostPackagesStatus(state));
  const rowActions = [
    {
      title: __('Upgrade via remote execution'), disabled: true,
    },
    {
      title: __('Upgrade via customized remote execution'), disabled: true,
    },
  ];

  return (
    <div>
      <div id="packages-hint">
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
                actionButtons,
                searchQuery,
                updateSearchQuery,
                }
          }
          additionalListeners={[hostId]}
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
