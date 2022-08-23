import React, { useState, useEffect, useCallback } from 'react';
import useDeepCompareEffect from 'use-deep-compare-effect';
import PropTypes from 'prop-types';
import { shallowEqual, useSelector, useDispatch } from 'react-redux';
import { TableVariant } from '@patternfly/react-table';
import {
  Tabs, Tab, TabTitleText, Split, SplitItem, Button,
  Select, SelectVariant, SelectOption, Dropdown, DropdownItem, KebabToggle,
} from '@patternfly/react-core';
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
import { ADDED, ALL_STATUSES, NOT_ADDED } from '../../ContentViewsConstants';
import { hasPermission } from '../../helpers';

const CVPackageGroupFilterContent = ({
  cvId, filterId, showAffectedRepos, setShowAffectedRepos, details,
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
  const [searchQuery, updateSearchQuery] = useState('');
  const [activeTabKey, setActiveTabKey] = useState(0);
  const loading = status === STATUS.PENDING;
  const [bulkActionOpen, setBulkActionOpen] = useState(false);
  const [selectOpen, setSelectOpen] = useState(false);
  const [selectedIndex, setSelectedIndex] = useState(0);
  const deselectAll = () => setRows(rows.map(row => ({ ...row, selected: false })));
  const toggleBulkAction = () => setBulkActionOpen(prevState => !prevState);
  const hasAddedSelected = rows.some(({ selected, added }) => selected && added);
  const hasNotAddedSelected = rows.some(({ selected, added }) => selected && !added);
  const { results, ...metadata } = response;
  const { permissions } = details;

  const columnHeaders = [
    __('Name'),
    __('Product'),
    __('Repository'),
    __('Description'),
    __('Status'),
  ];

  const allAddedNotAdded = [
    ALL_STATUSES,
    ADDED,
    NOT_ADDED,
  ];

  const selectedAdded = allAddedNotAdded[selectedIndex];

  const fetchItems = useCallback((params) => {
    const adjustedParams = { ...params };
    switch (selectedIndex) {
    case 0:
      adjustedParams.show_all_for = 'content_view_filter';
      adjustedParams.available_for = undefined;
      break;
    case 1:
      adjustedParams.show_all_for = undefined;
      adjustedParams.available_for = undefined;
      break;
    case 2:
      adjustedParams.show_all_for = undefined;
      adjustedParams.available_for = 'content_view_filter';
      break;
    default:
    }

    return getCVFilterPackageGroups(cvId, filterId, adjustedParams);
  }, [cvId, filterId, selectedIndex]);

  const buildRows = useCallback(() => {
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
  }, [filterResults, filterId, results]);

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
    if (!loading && results) {
      const newRows = buildRows();
      setRows(newRows);
    }
  }, [response, loading, buildRows, results]);

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
  const resetFilters = () => setSelectedIndex(0);

  return (
    <Tabs
      ouiaId="cv-package-group-filter-content"
      className="margin-0-24"
      activeKey={activeTabKey}
      onSelect={(_event, eventKey) => setActiveTabKey(eventKey)}
    >
      <Tab eventKey={0} title={<TabTitleText>{__('Package groups')}</TabTitleText>}>
        <div className="margin-24-0">
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
              resetFilters,
            }}
            ouiaId="content-view-package-group-filter-table"
            additionalListeners={[selectedIndex]}
            activeFilters={[selectedAdded]}
            defaultFilters={[allAddedNotAdded[0]]}
            cells={columnHeaders}
            variant={TableVariant.compact}
            autocompleteEndpoint={`/package_groups/auto_complete_search?filterid=${filterId}`}
            fetchItems={fetchItems}
            actionResolver={hasPermission(permissions, 'edit_content_views') ? actionResolver : null}
            onSelect={hasPermission(permissions, 'edit_content_views') ? onSelect(rows, setRows) : null}
            actionButtons={hasPermission(permissions, 'edit_content_views') &&
              <Split hasGutter>
                <SplitItem data-testid="allAddedNotAdded">
                  <Select
                    variant={SelectVariant.single}
                    onToggle={setSelectOpen}
                    ouiaId="allAddedNotAdded"
                    onSelect={(_event, selection) => {
                      setSelectedIndex(allAddedNotAdded.indexOf(selection));
                      setSelectOpen(false);
                    }}
                    selections={allAddedNotAdded[selectedIndex]}
                    isOpen={selectOpen}
                    isCheckboxSelectionBadgeHidden
                  >
                    {allAddedNotAdded.map(item =>
                      <SelectOption aria-label={item} key={item} value={item} />)}
                  </Select>
                </SplitItem>
                <SplitItem>
                  <Button
                    ouiaId="add-package-group-filter-rule-button"
                    isDisabled={!hasNotAddedSelected}
                    onClick={bulkAdd}
                    variant="primary"
                    aria-label="add_filter_rule"
                  >
                    {__('Add filter rule')}
                  </Button>
                </SplitItem>
                <SplitItem>
                  <Dropdown
                    toggle={<KebabToggle aria-label="bulk_actions" onToggle={toggleBulkAction} />}
                    isOpen={bulkActionOpen}
                    ouiaId="cv-package-group-filter-bulk-actions-dropdown"
                    isPlain
                    dropdownItems={[
                      <DropdownItem ouiaId="bulk_remove" aria-label="bulk_remove" key="bulk_remove" isDisabled={!hasAddedSelected} component="button" onClick={bulkRemove}>
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
        <Tab eventKey={1} title={<TabTitleText>{__('Affected repositories')}</TabTitleText>}>
          <div className="margin-24-0">
            <AffectedRepositoryTable cvId={cvId} filterId={filterId} repoType="yum" setShowAffectedRepos={setShowAffectedRepos} details={details} />
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
  details: PropTypes.shape({
    permissions: PropTypes.shape({}),
  }).isRequired,
};

export default CVPackageGroupFilterContent;
