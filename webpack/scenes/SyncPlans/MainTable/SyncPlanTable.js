import React, { useState, useCallback } from 'react';
import { useSelector } from 'react-redux';
import { TableVariant, TableText, Thead, Tbody, Tr, Th, Td } from '@patternfly/react-table';
import { TimesIcon, CheckIcon } from '@patternfly/react-icons';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import { translate as __ } from 'foremanReact/common/I18n';
import LongDateTime from 'foremanReact/components/common/dates/LongDateTime';
import { Link } from 'react-router-dom';
import TableWrapper from "../../../components/Table/TableWrapper";
import getSyncPlans from '../SyncPlansActions';
import {
  selectSyncPlans,
  selectPlansStatus,
  selectSyncPlansError
} from '../SyncPlansSelectors';

const SyncPlanTable = () => {
  const response = useSelector(state => selectSyncPlans(state));
  const status = useSelector(state => selectPlansStatus(state));
  const error = useSelector(state => selectSyncPlansError(state));

  const [searchQuery, updateSearchQuery] = useState('');

  const columnHeaders = [
    __('Name'),
    __('Description'),
    __('Original Sync Date'),
    __('Sync Enabled'),
    __('Interval'),
    __('Next Sync'),
  ];

  const emptyContentTitle = __("You currently don't have any sync plans");
  const emptyContentBody = __('Sync plans will appear here when you create a new sync plan');
  const emptySearchTitle = __('No matching sync plans found');
  const emptySearchBody = __('Try changing your search settings.');
  const { results, ...metadata } = response;
  /* eslint-disable react/no-array-index-key */
  return (
    <TableWrapper
      {...{
        metadata,
        emptyContentTitle,
        emptyContentBody,
        emptySearchTitle,
        emptySearchBody,
        searchQuery,
        updateSearchQuery,
        error,
        status,
      }}
      ouiaId="sync-plans-table"
      bookmarkController="katello_sync_plans"
      variant={TableVariant.compact}
      autocompleteEndpoint={`/sync_plans/auto_complete_search`}
      fetchItems={useCallback(params => getSyncPlans(params))}
    >
      <Thead>
        <Tr ouiaId="column-headers">
          {columnHeaders.map(col =>
            <Th key={col}>{col}</Th>)}
        </Tr>
      </Thead>
      <Tbody>
        {results?.map((syncPlan, index) => {
          const {
            name,
            id,
            description,
            interval,
            enabled,
            next_sync: nextSync,
            sync_date: syncDate,
          } = syncPlan;
          console.log(syncPlan);
          return (
            <Tr key={index} ouiaId={`sync-plan-row-${index}`}>
              <Td><Link to={`${urlBuilder('sync_plans', '')}${id}`}>{name}</Link></Td>
              <Td><TableText wrapModifier="truncate">{description}</TableText></Td>
              <Td><LongDateTime date={syncDate} showRelativeTimeTooltip /></Td>
              <Td>{enabled ? <CheckIcon/> : <TimesIcon/> }</Td>
              <Td>{interval}</Td>
              <Td><LongDateTime date={nextSync} showRelativeTimeTooltip /></Td>
            </Tr>
          );
        })
        }
      </Tbody>
    </TableWrapper>
  );
  /* eslint-enable react/no-array-index-key */
};

export default SyncPlanTable;
