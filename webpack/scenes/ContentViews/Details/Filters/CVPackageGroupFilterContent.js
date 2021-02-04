import React, { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';
import { shallowEqual, useSelector } from 'react-redux';
import { TableVariant } from '@patternfly/react-table';
import { Tabs, Tab, TabTitleText, Grid, GridItem } from '@patternfly/react-core';
import { STATUS } from 'foremanReact/constants';
import { translate as __ } from 'foremanReact/common/I18n';

import onSelect from '../../../../components/Table/helpers';
import TableWrapper from '../../../../components/Table/TableWrapper';
import {
  selectCVFilterPackageGroups,
  selectCVFilterPackageGroupStatus,
  selectCVFilterPackageGroupError,
} from '../ContentViewDetailSelectors';
import AddedStatusLabel from '../../../../components/AddedStatusLabel';
import { getCVFilterPackageGroups } from '../ContentViewDetailActions';


const CVPackageGroupFilterContent = ({ cvId, filterId }) => {
  const response = useSelector(state => selectCVFilterPackageGroups(state, cvId, filterId), shallowEqual);
  const status = useSelector(state => selectCVFilterPackageGroupStatus(state, cvId, filterId), shallowEqual);
  const error = useSelector(state => selectCVFilterPackageGroupError(state, cvId, filterId), shallowEqual);
  const [rows, setRows] = useState([]);
  const [metadata, setMetadata] = useState({});
  const [searchQuery, updateSearchQuery] = useState('');
  const [activeTabKey, setActiveTabKey] = useState(0);
  const loading = status === STATUS.PENDING;

  const columnHeaders = [
    __('Name'),
    __('Product'),
    __('Repository'),
    __('Description'),
    __('Status'),
  ];

  const buildRows = (results) => {
    const newRows = [];
    results.forEach((packageGroups) => {
      const {
        name,
        description,
        repository: {
          name: repositoryName,
          product: { name: productName }
        },
        filter_ids: filterIds,
      } = packageGroups;
      const cells = [
        { title: name },
        { title: productName },
        { title: repositoryName },
        { title: description},
        { title: <AddedStatusLabel added={filterIds.includes(parseInt(filterId))} /> },
      ];

      newRows.push({ cells });
    });

    return newRows;
  };

  useEffect(() => {
    const { results, ...meta } = response;
    setMetadata(meta);

    if (!loading && results) {
      const newRows = buildRows(results);
      setRows(newRows);
    }
  }, [JSON.stringify(response)]);

  const emptyContentTitle = __("You currently don't have any package groups associated with this filter.");
  const emptyContentBody = __("Add to this filter using the 'Add package group' button above.");
  const emptySearchTitle = __('No matching package groups found');
  const emptySearchBody = __('Try changing your search settings.');

  return (
    <Tabs activeKey={activeTabKey} onSelect={(_event, eventKey) => setActiveTabKey(eventKey)}>
      <Tab eventKey={0} title={<TabTitleText>{__("Package groups")}</TabTitleText>}>
        <div className={"tab-body-with-spacing"}>
          <TableWrapper
            {...{
              rows,
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
            status={status}
            onSelect={onSelect(rows, setRows)}
            cells={columnHeaders}
            variant={TableVariant.compact}
            autocompleteEndpoint={`/package_groups/auto_complete_search?filterid=${filterId}`}
            fetchItems={params => getCVFilterPackageGroups(cvId, filterId, params)}
          />
        </div>
      </Tab>
    </Tabs>
  );
}

export default CVPackageGroupFilterContent;
