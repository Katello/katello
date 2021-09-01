import React, { useState, useEffect, useCallback } from 'react';
import useDeepCompareEffect from 'use-deep-compare-effect';
import PropTypes from 'prop-types';
import { shallowEqual, useSelector, useDispatch } from 'react-redux';
import { TableVariant } from '@patternfly/react-table';
import { Tabs, Tab, TabTitleText, Split, SplitItem, Button, Dropdown, DropdownItem, KebabToggle } from '@patternfly/react-core';
import { STATUS } from 'foremanReact/constants';
import { translate as __ } from 'foremanReact/common/I18n';

import onSelect from '../../../../components/Table/helpers';
import TableWrapper from '../../../../components/Table/TableWrapper';
import {
  selectCVFilterPackageGroups,
  selectCVFilterPackageGroupStatus,
  selectCVFilterPackageGroupError,
  selectCVFilters, selectCVFilterDetails,
} from '../ContentViewDetailSelectors';
import AddedStatusLabel from '../../../../components/AddedStatusLabel';
import getContentViewDetails, {
  addCVFilterRule, removeCVFilterRule, getCVFilterPackageGroups,
  deleteContentViewFilterRules, addContentViewFilterRules,
} from '../ContentViewDetailActions';
import AffectedRepositoryTable from './AffectedRepositories/AffectedRepositoryTable';

const CVPackageGroupFilterContent = ({
  cvId, filterId, showAffectedRepos, setShowAffectedRepos,
}) => {
  const dispatch = useDispatch();
  const { results: filterResults } =
    useSelector(state => selectCVFilters(state, cvId), shallowEqual);
  const response = useSelector(state =>
    selectCVFilterPackageGroups(state, cvId, filterId), shallowEqual);
  const status = useSelector(state =>
    selectCVFilterPackageGroupStatus(state, cvId, filterId), shallowEqual);
  const error = useSelector(state =>
    selectCVFilterPackageGroupError(state, cvId, filterId), shallowEqual);
  const filterDetails = useSelector(state =>
    selectCVFilterDetails(state, cvId, filterId), shallowEqual);
  const { repositories = [] } = filterDetails;
  const [rows, setRows] = useState([]);
  const [metadata, setMetadata] = useState({});
  const [searchQuery, updateSearchQuery] = useState('');
  const [activeTabKey, setActiveTabKey] = useState(0);
  const loading = status === STATUS.PENDING;
  const [bulkActionOpen, setBulkActionOpen] = useState(false);
  const deselectAll = () => setRows(rows.map(row => ({ ...row, selected: false })));
  const toggleBulkAction = () => setBulkActionOpen(prevState => !prevState);
  const hasAddedSelected = rows.some(({ selected, added }) => selected && added);
  const hasNotAddedSelected = rows.some(({ selected, added }) => selected && !added);

  const columnHeaders = [
    __('Name'),
    __('Product'),
    __('Repository'),
    __('Description'),
    __('Status'),
  ];


  const buildRows = useCallback((results) => {
    const newRows = [];
    const filterRules = filterResults.find(({ id }) => id === Number(filterId))?.rules || [];
    results.forEach((packageGroups) => {
      const {
        name,
        description,
        repository: {
          name: repositoryName,
          product: { name: productName },
        },
        filter_ids: filterIds,
        ...rest
      } = packageGroups;

      const cells = [
        { title: name },
        { title: productName },
        { title: repositoryName },
        { title: description },
        { title: <AddedStatusLabel added={filterIds.includes(parseInt(filterId, 10))} /> },
      ];

      newRows.push({
        cells,
        packagefilterId: filterRules?.find(({ uuid }) => uuid === rest.uuid)?.id,
        added: filterIds.includes(parseInt(filterId, 10)),
        ...rest,
        name,
      });
    });

    return newRows.sort(({ added: addedA }, { added: addedB }) => {
      if (addedA === addedB) return 0;
      return addedA ? -1 : 1;
    });
  }, [filterResults, filterId]);

  const bulkAdd = () => {
    setBulkActionOpen(false);
    const addData = rows.filter(({ selected, added }) =>
      selected && !added).map(({ uuid }) => ({ uuid }));
    dispatch(addContentViewFilterRules(filterId, addData, () =>
      dispatch(getContentViewDetails(cvId))));
    deselectAll();
  };

  const bulkRemove = () => {
    setBulkActionOpen(false);
    const packageFilterIds =
      rows.filter(({ selected, added }) =>
        selected && added).map(({ packagefilterId }) => packagefilterId);
    dispatch(deleteContentViewFilterRules(filterId, packageFilterIds, () =>
      dispatch(getContentViewDetails(cvId))));
    deselectAll();
  };

  useEffect(() => {
    if (!repositories.length && showAffectedRepos) {
      setActiveTabKey(1);
    } else {
      setActiveTabKey(0);
    }
  }, [showAffectedRepos, repositories.length]);

  useDeepCompareEffect(() => {
    const { results, ...meta } = response;
    setMetadata(meta);

    if (!loading && results) {
      const newRows = buildRows(results);
      setRows(newRows);
    }
  }, [response, loading, buildRows]);

  const actionResolver = ({ added }) => [
    {
      title: __('Add'),
      isDisabled: added,
      onClick: (_event, _rowId, { uuid }) => {
        dispatch(addCVFilterRule(filterId, { uuid }, () =>
          dispatch(getContentViewDetails(cvId))));
      },
    },
    {
      title: __('Remove'),
      isDisabled: !added,
      onClick: (_event, _rowId, { packagefilterId }) => {
        dispatch(removeCVFilterRule(filterId, packagefilterId, () =>
          dispatch(getContentViewDetails(cvId))));
      },
    },
  ];

  const emptyContentTitle = __('No rules have been added to this filter.');
  const emptyContentBody = __("Add to this filter using the 'Add filter rule' button.");
  const emptySearchTitle = __('No matching filter rules found.');
  const emptySearchBody = __('Try changing your search settings.');


  return (
    <Tabs activeKey={activeTabKey} onSelect={(_event, eventKey) => setActiveTabKey(eventKey)}>
      <Tab eventKey={0} title={<TabTitleText>{__('Package groups')}</TabTitleText>}>
        <div className="tab-body-with-spacing">
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
              actionResolver,
            }}
            status={status}
            onSelect={onSelect(rows, setRows)}
            cells={columnHeaders}
            variant={TableVariant.compact}
            autocompleteEndpoint={`/package_groups/auto_complete_search?filterid=${filterId}`}
            fetchItems={useCallback(params =>
              getCVFilterPackageGroups(cvId, filterId, params), [cvId, filterId])}
            actionButtons={
              <Split hasGutter>
                <SplitItem>
                  <Button isDisabled={!hasNotAddedSelected} onClick={bulkAdd} variant="secondary" aria-label="add_filter_rule">
                    {__('Add filter rule')}
                  </Button>
                </SplitItem>
                <SplitItem>
                  <Dropdown
                    toggle={<KebabToggle aria-label="bulk_actions" onToggle={toggleBulkAction} />}
                    isOpen={bulkActionOpen}
                    isPlain
                    dropdownItems={[
                      <DropdownItem aria-label="bulk_add" key="bulk_add" isDisabled={!hasNotAddedSelected} component="button" onClick={bulkAdd}>
                        {__('Add')}
                      </DropdownItem>,
                      <DropdownItem aria-label="bulk_remove" key="bulk_remove" isDisabled={!hasAddedSelected} component="button" onClick={bulkRemove}>
                        {__('Remove')}
                      </DropdownItem>]
                  }
                  />
                </SplitItem>
              </Split>
            }
          />
        </div>
      </Tab>
      {(repositories.length || showAffectedRepos) &&
      <Tab eventKey={1} title={<TabTitleText>{__('Affected Repositories')}</TabTitleText>}>
        <div className="tab-body-with-spacing">
          <AffectedRepositoryTable cvId={cvId} filterId={filterId} repoType="yum" setShowAffectedRepos={setShowAffectedRepos} />
        </div>
      </Tab>
      }
    </Tabs>
  );
};

CVPackageGroupFilterContent.propTypes = {
  cvId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
  filterId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
  showAffectedRepos: PropTypes.bool.isRequired,
  setShowAffectedRepos: PropTypes.func.isRequired,
};

export default CVPackageGroupFilterContent;
