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
  selectCVFilterModuleStream,
  selectCVFilterModuleStreamStatus,
  selectCVFilterModuleStreamError,
  selectCVFilters, selectCVFilterDetails, selectCVFiltersStatus,
} from '../ContentViewDetailSelectors';
import getContentViewDetails, {
  addCVFilterRule, removeCVFilterRule, getCVFilterModuleStreams,
  deleteContentViewFilterRules, addContentViewFilterRules,
} from '../ContentViewDetailActions';
import AddedStatusLabel from '../../../../components/AddedStatusLabel';
import AffectedRepositoryTable from './AffectedRepositories/AffectedRepositoryTable';

const CVModuleStreamFilterContent = ({
  cvId, filterId, showAffectedRepos, setShowAffectedRepos,
}) => {
  const dispatch = useDispatch();
  const { results: filterResults } =
    useSelector(state => selectCVFilters(state, cvId), shallowEqual);
  const response = useSelector(state =>
    selectCVFilterModuleStream(state, cvId, filterId), shallowEqual);
  const status = useSelector(state =>
    selectCVFilterModuleStreamStatus(state, cvId, filterId), shallowEqual);
  const filterLoad = useSelector(state =>
    selectCVFiltersStatus(state, cvId), shallowEqual);
  const error = useSelector(state =>
    selectCVFilterModuleStreamError(state, cvId, filterId), shallowEqual);
  const filterDetails = useSelector(state =>
    selectCVFilterDetails(state, cvId, filterId), shallowEqual);
  const { repositories = [] } = filterDetails;
  const [rows, setRows] = useState([]);
  const [metadata, setMetadata] = useState({});
  const [searchQuery, updateSearchQuery] = useState('');
  const [activeTabKey, setActiveTabKey] = useState(0);
  const filterLoaded = filterLoad === 'RESOLVED';
  const loading = status === STATUS.PENDING;
  const [bulkActionOpen, setBulkActionOpen] = useState(false);
  const deselectAll = () => setRows(rows.map(row => ({ ...row, selected: false })));
  const toggleBulkAction = () => setBulkActionOpen(prevState => !prevState);
  const hasAddedSelected = rows.some(({ selected, added }) => selected && added);
  const hasNotAddedSelected = rows.some(({ selected, added }) => selected && !added);
  const columnHeaders = [
    __('Name'),
    __('Stream'),
    __('Version'),
    __('Context'),
    __('Status'),
  ];

  const buildRows = useCallback((results) => {
    const newRows = [];
    const filterRules = filterResults.find(({ id }) => id === Number(filterId))?.rules || [];
    results.forEach((moduleStreams) => {
      const {
        id,
        name,
        stream,
        version,
        context,
        filter_ids: filterIds,
        ...rest
      } = moduleStreams;

      const added = filterIds.includes(parseInt(filterId, 10));

      const cells = [
        { title: name },
        { title: stream },
        { title: version },
        { title: context },
        { title: <AddedStatusLabel added={added} /> },
      ];

      /* eslint-disable camelcase */

      newRows.push({
        cells,
        module_stream_id: id,
        moduleStreamRuleId: filterRules?.find(({ module_stream_id }) => module_stream_id === id)?.id, // eslint-disable-line max-len, no-shadow, no-self-compare
        added,
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
      selected && !added).map(({ module_stream_id }) => ({ module_stream_ids: [module_stream_id] })); // eslint-disable-line max-len
    dispatch(addContentViewFilterRules(filterId, addData, () =>
      dispatch(getContentViewDetails(cvId))));
    deselectAll();
  };

  const bulkRemove = () => {
    setBulkActionOpen(false);
    const moduleStreamRuleIds =
      rows.filter(({ selected, added }) =>
        selected && added).map(({ moduleStreamRuleId }) => moduleStreamRuleId);
    dispatch(deleteContentViewFilterRules(filterId, moduleStreamRuleIds, () =>
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

    if (!loading && results && filterLoaded) {
      const newRows = buildRows(results);
      setRows(newRows);
    }
  }, [response, loading, filterLoaded, buildRows]);

  const actionResolver = ({ added }) => [
    {
      title: __('Add'),
      isDisabled: added,
      onClick: (_event, _rowId, { module_stream_id }) => {
        dispatch(addCVFilterRule(filterId, { module_stream_ids: [module_stream_id] }, () =>
          dispatch(getContentViewDetails(cvId))));
      },
    },
    {
      title: __('Remove'),
      isDisabled: !added,
      onClick: (_event, _rowId, { moduleStreamRuleId }) => {
        dispatch(removeCVFilterRule(filterId, moduleStreamRuleId, () =>
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
      <Tab eventKey={0} title={<TabTitleText>{__('Module Streams')}</TabTitleText>}>
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
            autocompleteEndpoint={`/module_streams/auto_complete_search?filterid=${filterId}`}
            fetchItems={useCallback(params =>
              getCVFilterModuleStreams(cvId, filterId, params), [cvId, filterId])}
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

CVModuleStreamFilterContent.propTypes = {
  cvId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
  filterId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
  showAffectedRepos: PropTypes.bool.isRequired,
  setShowAffectedRepos: PropTypes.func.isRequired,
};

export default CVModuleStreamFilterContent;
