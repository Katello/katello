import React, { useCallback } from 'react';
import { useSelector } from 'react-redux';
import { translate as __ } from 'foremanReact/common/I18n';
import { Skeleton, Label, Hint, HintBody, Button } from '@patternfly/react-core';
import PropTypes from 'prop-types';
import { upperFirst } from 'lodash';
import { TableText, TableVariant, Thead, Tbody, Tr, Td } from '@patternfly/react-table';
import {
  LongArrowAltUpIcon,
  CheckIcon,
} from '@patternfly/react-icons';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import { selectModuleStreamStatus, selectModuleStream } from './ModuleStreamsSelectors';
import { useBulkSelect, useTableSort, useUrlParams } from '../../../../Table/TableHooks';
import { getHostModuleStreams } from './ModuleStreamsActions';
import InactiveText from '../../../../../scenes/ContentViews/components/InactiveText';
import TableWrapper from '../../../../../components/Table/TableWrapper';
import hostIdNotReady from '../../HostDetailsActions';
import { selectHostDetails } from '../../HostDetailsSelectors';
import SortableColumnHeaders from '../../../../Table/components/SortableColumnHeaders';

const EnabledIcon = ({ streamText, streamInstallStatus, upgradable }) => {
  const INSTALLED_STATE = {
    INSTALLED: __('Installed'),
    UPGRADEABLE: __('Upgradable'),
    UPTODATE: __('Up-to-date'),
    NOTINSTALLED: __('Not installed'),
  };

  switch (true) {
  case (streamInstallStatus?.length > 0 && streamText === 'disabled'):
    return <TableText wrapModifier="nowrap">{INSTALLED_STATE.INSTALLED}</TableText>;
  case (streamInstallStatus?.length > 0 && streamText === 'enabled' && upgradable !== true):
    return <><CheckIcon color="green" /> {INSTALLED_STATE.UPTODATE}</>;
  case (streamInstallStatus?.length > 0 && streamText === 'enabled' && upgradable):
    return <><LongArrowAltUpIcon color="blue" /> {INSTALLED_STATE.UPGRADEABLE}</>;
  default:
    return <InactiveText text={INSTALLED_STATE.NOTINSTALLED} />;
  }
};

EnabledIcon.propTypes = {
  streamText: PropTypes.string.isRequired,
  streamInstallStatus: PropTypes.arrayOf(PropTypes.string).isRequired,
  upgradable: PropTypes.bool.isRequired,
};

const StreamState = ({ moduleStreamStatus }) => {
  let streamText = moduleStreamStatus?.charAt(0)?.toUpperCase() + moduleStreamStatus?.slice(1);
  streamText = streamText?.replace('Unknown', 'Default');
  switch (true) {
  case (streamText === 'Default'):
    return <Label color="gray" variant="outline">{streamText}</Label>;
  case (streamText === 'Disabled'):
    return <Label color="gray" variant="filled">{streamText}</Label>;
  case (streamText === 'Enabled'):
    return <Label color="green" variant="filled">{streamText}</Label>;
  default:
    return null;
  }
};

StreamState.propTypes = {
  moduleStreamStatus: PropTypes.string.isRequired,
};

const HostInstalledProfiles = ({ moduleStreamStatus, installedProfiles }) => {
  let installedProfile;
  if (installedProfiles?.length > 0) {
    installedProfile = installedProfiles?.map(profile => upperFirst(profile)).join(', ');
  } else {
    installedProfile = 'No profile installed';
  }
  const disabledText = moduleStreamStatus === 'disabled' || moduleStreamStatus === 'unknown';
  return disabledText ? <InactiveText text={installedProfile} /> : installedProfile;
};

HostInstalledProfiles.propTypes = {
  moduleStreamStatus: PropTypes.string.isRequired,
  installedProfiles: PropTypes.arrayOf(PropTypes.string).isRequired,
};

export const ModuleStreamsTab = () => {
  const { id: hostId, name: hostName } = useSelector(selectHostDetails);

  const emptyContentTitle = __('This host does not have any Module streams.');
  const emptyContentBody = __('Module streams will appear here when available.');
  const emptySearchTitle = __('Your search returned no matching Module streams.');
  const emptySearchBody = __('Try changing your search criteria.');
  const errorSearchTitle = __('Problem searching module streams');
  const { searchParam } = useUrlParams();
  const columnHeaders = [
    __('Name'),
    __('State'),
    __('Stream'),
    __('Installation status'),
    __('Installed profile'),
  ];
  const COLUMNS_TO_SORT_PARAMS = {
    [columnHeaders[0]]: 'name',
    [columnHeaders[1]]: 'status',
    [columnHeaders[3]]: 'installed_profiles',
  };

  const {
    pfSortParams, apiSortParams,
    activeSortColumn, activeSortDirection,
  } = useTableSort({
    allColumns: columnHeaders,
    columnsToSortParams: COLUMNS_TO_SORT_PARAMS,
    initialSortColumnName: 'Name',
  });

  const fetchItems = useCallback(
    (params) => {
      if (!hostId) return hostIdNotReady;
      return getHostModuleStreams(
        hostId,
        { ...apiSortParams, ...params },
      );
    },
    [hostId, apiSortParams],
  );

  const response = useSelector(selectModuleStream);
  const { results, ...metadata } = response;
  const { error: errorSearchBody } = metadata;
  const status = useSelector(state => selectModuleStreamStatus(state));
  /* eslint-disable no-unused-vars */
  const {
    selectOne, isSelected, searchQuery, selectedCount, isSelectable,
    updateSearchQuery, selectNone, fetchBulkParams, ...selectAll
  } = useBulkSelect({
    results,
    metadata,
    isSelectable: _result => false,
    initialSearchQuery: searchParam || '',
  });
  /* eslint-enable no-unused-vars */

  if (!hostId) return <Skeleton />;

  const rowActions = [
    {
      title: __('Install'), disabled: true,
    },
    {
      title: __('Update'), disabled: true,
    },
    {
      title: __('Enable'), disabled: true,
    },
    {
      title: __('Disable'), disabled: true,
    },
    {
      title: __('Reset'), disabled: true,
    },
    {
      title: __('Remove'), disabled: true,
    },
  ];

  return (
    <div>
      <div id="modules-hint" className="margin-0-24 margin-top-16">
        <Hint>
          <HintBody>
            {__('Module stream management functionality on this page is incomplete')}.
            <br />
            <Button component="a" variant="link" isInline href={urlBuilder(`content_hosts/${hostId}/module-streams`, '')}>
              {__('Visit the previous Module stream page')}.
            </Button>
          </HintBody>
        </Hint>
      </div>
      <div id="modulestreams-tab">
        <TableWrapper
          {...{
            metadata,
            emptyContentTitle,
            emptyContentBody,
            emptySearchTitle,
            emptySearchBody,
            errorSearchTitle,
            errorSearchBody,
            searchQuery,
            updateSearchQuery,
            fetchItems,
            status,
          }}
          ouiaId="host-module-stream-table"
          additionalListeners={[hostId, activeSortColumn, activeSortDirection]}
          fetchItems={fetchItems}
          autocompleteEndpoint={`/hosts/${hostId}/module_streams/auto_complete_search`}
          foremanApiAutoComplete
          rowsCount={results?.length}
          variant={TableVariant.compact}
        >
          <Thead>
            <Tr>
              <SortableColumnHeaders
                columnHeaders={columnHeaders}
                pfSortParams={pfSortParams}
                columnsToSortParams={COLUMNS_TO_SORT_PARAMS}
              />
            </Tr>
          </Thead>
          <Tbody>
            {results?.map(({
              id,
              status: moduleStreamStatus,
              name,
              stream,
              installed_profiles: installedProfiles,
              upgradable,
              module_spec: moduleSpec,
            }, index) => (
              /* eslint-disable react/no-array-index-key */
              <Tr key={`${id} ${index}`}>
                <Td>
                  <a
                    href={`/module_streams?search=module_spec%3D${moduleSpec}+and+host%3D${hostName}`}
                  >
                    {name}
                  </a>
                </Td>
                <Td>
                  <StreamState moduleStreamStatus={moduleStreamStatus} />
                </Td>
                <Td>{stream}</Td>
                <Td>
                  <EnabledIcon
                    streamText={moduleStreamStatus}
                    streamInstallStatus={installedProfiles}
                    upgradable={upgradable}
                  />
                </Td>
                <Td>
                  <HostInstalledProfiles
                    moduleStreamStatus={moduleStreamStatus}
                    installedProfiles={installedProfiles}
                  />
                </Td>
                <Td
                  key={`rowActions-${id}`}
                  actions={{
                    items: rowActions,
                  }}
                />
              </Tr>
            ))
            }
          </Tbody>
        </TableWrapper>
      </div>
    </div>
  );
};

export default ModuleStreamsTab;
