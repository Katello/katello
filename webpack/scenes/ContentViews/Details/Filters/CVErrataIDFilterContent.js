import React, { useState, useEffect, useCallback } from 'react';
import useDeepCompareEffect from 'use-deep-compare-effect';
import PropTypes from 'prop-types';
import { shallowEqual, useSelector, useDispatch } from 'react-redux';
import { capitalize, omit, isEqual } from 'lodash';
import { TableVariant } from '@patternfly/react-table';
import {
  Tabs, Tab, TabTitleText, Split, SplitItem, Select, SelectVariant,
  SelectOption, Button, Dropdown, DropdownItem, KebabToggle, Flex, FlexItem,
  Bullseye, DatePicker, ChipGroup, Chip, Text,
} from '@patternfly/react-core';
import { STATUS } from 'foremanReact/constants';
import { translate as __ } from 'foremanReact/common/I18n';

import onSelect from '../../../../components/Table/helpers';
import TableWrapper from '../../../../components/Table/TableWrapper';
import {
  selectCVFilterErratumID,
  selectCVFilterErratumIDStatus,
  selectCVFilterErratumIDError,
  selectCVFilters, selectCVFilterDetails, selectCVFiltersStatus,
} from '../ContentViewDetailSelectors';
import getContentViewDetails, {
  addCVFilterRule, removeCVFilterRule, getCVFilterErrata,
  deleteContentViewFilterRules, addContentViewFilterRules,
} from '../ContentViewDetailActions';
import AddedStatusLabel from '../../../../components/AddedStatusLabel';
import ErratumTypeLabel from '../../../../components/ErratumTypeLabel';
import AffectedRepositoryTable from './AffectedRepositories/AffectedRepositoryTable';
import { ADDED, ALL_STATUSES, NOT_ADDED, ERRATA_TYPES } from '../../ContentViewsConstants';
import SelectableDropdown from '../../../../components/SelectableDropdown/SelectableDropdown';
import { dateFormat, dateParse } from './CVErrataDateFilterContent';
import { hasPermission } from '../../helpers';

const CVErrataIDFilterContent = ({
  cvId, filterId, showAffectedRepos, setShowAffectedRepos, details,
}) => {
  const dispatch = useDispatch();
  const { results: filterResults } =
    useSelector(state => selectCVFilters(state, cvId), shallowEqual);
  const response = useSelector(state =>
    selectCVFilterErratumID(state, cvId, filterId), shallowEqual);
  const status = useSelector(state =>
    selectCVFilterErratumIDStatus(state, cvId, filterId), shallowEqual);
  const filterLoad = useSelector(state =>
    selectCVFiltersStatus(state, cvId), shallowEqual);
  const error = useSelector(state =>
    selectCVFilterErratumIDError(state, cvId, filterId), shallowEqual);
  const filterDetails = useSelector(state =>
    selectCVFilterDetails(state, cvId, filterId), shallowEqual);
  const { repositories = [] } = filterDetails;
  const [rows, setRows] = useState([]);
  const [searchQuery, updateSearchQuery] = useState('');
  const [activeTabKey, setActiveTabKey] = useState(0);
  const filterLoaded = filterLoad === 'RESOLVED';
  const loading = status === STATUS.PENDING;
  const [bulkActionOpen, setBulkActionOpen] = useState(false);
  const deselectAll = () => setRows(rows.map(row => ({ ...row, selected: false })));
  const toggleBulkAction = () => setBulkActionOpen(prevState => !prevState);
  const hasAddedSelected = rows.some(({ selected, added }) => selected && added);
  const hasNotAddedSelected = rows.some(({ selected, added }) => selected && !added);
  const [statusSelected, setStatusSelected] = useState(ALL_STATUSES);
  const [typeSelectOpen, setTypeSelectOpen] = useState(false);
  const [selectedTypes, setSelectedTypes] = useState(ERRATA_TYPES);
  const [startDate, setStartDate] = useState('');
  const [endDate, setEndDate] = useState('');
  const activeFilters = [statusSelected, selectedTypes, startDate, endDate];
  const defaultFilters = [ALL_STATUSES, ERRATA_TYPES, '', ''];
  const [apiStartDate, setApiStartDate] = useState('');
  const [apiEndDate, setApiEndDate] = useState('');
  const [dateType, setDateType] = useState('issued');
  const [dateTypeSelectOpen, setDateTypeSelectOpen] = useState(false);
  const [startEntry, setStartEntry] = useState(false);
  const [endEntry, setEndEntry] = useState(false);

  const metadata = omit(response, ['results']);
  const { permissions } = details;
  const columnHeaders = [
    __('Errata ID'),
    __('Type'),
    __('Issued'),
    __('Updated'),
    __('Severity'),
    __('Synopsis'),
    __('Status'),
  ];

  const buildRows = useCallback((results) => {
    const newRows = [];
    const filterRules = filterResults.find(({ id }) => id === Number(filterId))?.rules || [];
    results.forEach((errata) => {
      const {
        id,
        errata_id: errataId,
        type,
        issued,
        updated,
        severity,
        title,
        filter_ids: filterIds,
        ...rest
      } = errata;

      const added = filterIds.includes(parseInt(filterId, 10));

      const cells = [
        { title: errataId },
        { title: <ErratumTypeLabel type={type} /> },
        { title: issued },
        { title: updated },
        { title: severity || 'N/A' },
        { title },
        { title: <AddedStatusLabel added={added} /> },
      ];


      newRows.push({
        cells,
        erratumId: errataId,
        erratumRuleId: filterRules?.find(({ errata_id: filterErrataId }) =>
          filterErrataId === errataId)?.id,
        added,
        ...rest,
        errataId,
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
      selected && !added).map(({ erratumId }) => ({ errata_ids: [erratumId] })); // eslint-disable-line max-len
    dispatch(addContentViewFilterRules(filterId, addData, () =>
      dispatch(getContentViewDetails(cvId))));
    deselectAll();
  };

  const bulkRemove = () => {
    setBulkActionOpen(false);
    const erratumRuleIds =
      rows.filter(({ selected, added }) =>
        selected && added).map(({ erratumRuleId }) => erratumRuleId);
    dispatch(deleteContentViewFilterRules(filterId, erratumRuleIds, () =>
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
    const { results } = response;

    if (!loading && results && filterLoaded) {
      const newRows = buildRows(results);
      setRows(newRows);
    }
  }, [response, loading, filterLoaded, buildRows]);

  const actionResolver = ({ added }) => [
    {
      title: __('Add'),
      isDisabled: added,
      onClick: (_event, _rowId, { erratumId }) => {
        dispatch(addCVFilterRule(filterId, { errata_ids: [erratumId] }, () =>
          dispatch(getContentViewDetails(cvId))));
      },
    },
    {
      title: __('Remove'),
      isDisabled: !added,
      onClick: (_event, _rowId, { erratumRuleId }) => {
        dispatch(removeCVFilterRule(filterId, erratumRuleId, () =>
          dispatch(getContentViewDetails(cvId))));
      },
    },
  ];

  const validAPIDate = (date) => {
    if (!date || date === '') return true;
    const split = date.split('/');
    if (split.length !== 3) {
      return false;
    }
    const [month, day, year] = split;
    return month && month.length === 2 && day && day.length === 2 && year && year.length === 4;
  };

  const singleSelection = selection => (selectedTypes.length === 1
    && selectedTypes.includes(selection));

  const onTypeSelect = (selection) => {
    if (selectedTypes.includes(selection)) {
      if (selectedTypes.length === 1) return;
      setSelectedTypes(selectedTypes.filter(e => e !== selection));
    } else setSelectedTypes([...selectedTypes, selection]);
  };

  const setValidStartDate = (value) => {
    setStartDate(value);
    if (validAPIDate(value)) setApiStartDate(value);
  };

  const setValidEndDate = (value) => {
    setEndDate(value);
    if (validAPIDate(value)) setApiEndDate(value);
  };

  const getCVFilterErrataWithOptions = useCallback((params = {}) => {
    let apiParams = { ...params, types: selectedTypes };
    if (dateType) apiParams = { ...apiParams, date_type: dateType };
    if (apiStartDate) apiParams = { ...apiParams, start_date: apiStartDate };
    if (apiEndDate) apiParams = { ...apiParams, end_date: apiEndDate };
    return getCVFilterErrata(cvId, filterId, apiParams, statusSelected);
  }, [cvId, filterId, statusSelected, selectedTypes, dateType, apiStartDate, apiEndDate]);

  const resetFilters = () => {
    setValidStartDate('');
    setValidEndDate('');
    setSelectedTypes(ERRATA_TYPES);
    setDateType('issued');
    setStatusSelected(ALL_STATUSES);
  };

  const resetFiltersDisabled =
    startDate === '' &&
    endDate === '' &&
    isEqual(selectedTypes, ERRATA_TYPES) &&
    dateType === 'issued' &&
    statusSelected === ALL_STATUSES;

  const emptyContentTitle = __('No errata available to add to this filter.');
  const emptyContentBody = __('No errata available for this content view.');
  const emptySearchTitle = __('No matching filter rules found.');
  const emptySearchBody = __('Try changing your search settings.');

  const invalidDateFormat = __('Enter a valid date: MM/DD/YYYY');

  return (
    <Tabs className="margin-0-24" activeKey={activeTabKey} onSelect={(_event, eventKey) => setActiveTabKey(eventKey)}>
      <Tab eventKey={0} title={<TabTitleText>{__('Errata')}</TabTitleText>}>
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
              activeFilters,
              defaultFilters,
              resetFilters,
            }}
            ouiaId="content-view-errata-by-id-filter-table"
            actionResolver={hasPermission(permissions, 'edit_content_views') ? actionResolver : null}
            onSelect={hasPermission(permissions, 'edit_content_views') ? onSelect(rows, setRows) : null}
            cells={columnHeaders}
            variant={TableVariant.compact}
            autocompleteEndpoint={`/errata/auto_complete_search?filterid=${filterId}`}
            additionalListeners={[statusSelected, selectedTypes.length,
              dateType, apiStartDate, apiEndDate]}
            fetchItems={useCallback(params =>
              getCVFilterErrataWithOptions(params), [getCVFilterErrataWithOptions])}
            actionButtons={
              <Split hasGutter>
                <SplitItem data-testid="allAddedNotAdded">
                  <SelectableDropdown
                    items={[ALL_STATUSES, ADDED, NOT_ADDED]}
                    title=""
                    selected={statusSelected}
                    setSelected={setStatusSelected}
                    placeholderText={__('Status')}
                    aria-label="status_selector"
                  />
                </SplitItem>
                <SplitItem>
                  <Select
                    aria-label="errata_type_selector"
                    variant={SelectVariant.checkbox}
                    onToggle={setTypeSelectOpen}
                    onSelect={(_event, selection) => onTypeSelect(selection)}
                    selections={selectedTypes}
                    isOpen={typeSelectOpen}
                    placeholderText={__('Errata type')}
                    isCheckboxSelectionBadgeHidden
                  >
                    <SelectOption aria-label="security_selection" isDisabled={singleSelection('security')} key="security" value="security">
                      <p style={{ marginTop: '4px' }}>
                        {__('Security')}
                      </p>
                    </SelectOption>
                    <SelectOption isDisabled={singleSelection('enhancement')} key="enhancement" value="enhancement">
                      <p style={{ marginTop: '4px' }}>
                        {__('Enhancement')}
                      </p>
                    </SelectOption>
                    <SelectOption isDisabled={singleSelection('bugfix')} key="bugfix" value="bugfix">
                      <p style={{ marginTop: '4px' }}>
                        {__('Bugfix')}
                      </p>
                    </SelectOption>
                  </Select>
                </SplitItem>
                {hasPermission(permissions, 'edit_content_views') &&
                  <SplitItem>
                    <Button ouiaId="add-errata-id-button" isDisabled={!hasNotAddedSelected} onClick={bulkAdd} variant="primary" aria-label="add_filter_rule">
                      {__('Add errata')}
                    </Button>
                  </SplitItem>
                }
                {hasPermission(permissions, 'edit_content_views') &&
                  <SplitItem>
                    <Dropdown
                      toggle={<KebabToggle aria-label="bulk_actions" onToggle={toggleBulkAction} />}
                      isOpen={bulkActionOpen}
                      isPlain
                      dropdownItems={[
                        <DropdownItem aria-label="bulk_remove" key="bulk_remove" isDisabled={!hasAddedSelected} component="button" onClick={bulkRemove}>
                          {__('Remove')}
                        </DropdownItem>]
                      }
                    />
                  </SplitItem>
                }
              </Split>
            }
            nodesBelowSearch={
              <>
                <Flex>
                  <FlexItem span={2} spacer={{ default: 'spacerNone' }}>
                    <Select
                      selections={dateType}
                      onSelect={(_event, selection) => {
                        setDateType(selection);
                        setDateTypeSelectOpen(false);
                      }}
                      isOpen={dateTypeSelectOpen}
                      onToggle={setDateTypeSelectOpen}
                      id="date_type_selector"
                      name="date_type_selector"
                      aria-label="date_type_selector"
                    >
                      <SelectOption key="issued" value="issued">{__('Issued from')}</SelectOption>
                      <SelectOption key="updated" value="updated">{__('Updated from')}</SelectOption>
                    </Select>
                  </FlexItem>
                  <FlexItem span={2} spacer={{ default: 'spacerNone' }}>
                    <Bullseye
                      onFocus={() => setStartEntry(true)}
                      onBlur={() => setStartEntry(false)}
                    >
                      <DatePicker
                        aria-label="start_date_input"
                        invalidFormatText={invalidDateFormat}
                        value={startDate}
                        dateFormat={dateFormat}
                        onChange={setValidStartDate}
                        dateParse={dateParse}
                        placeholder={startEntry ? 'MM/DD/YYYY' : __('Start date')}
                      />
                    </Bullseye>
                  </FlexItem>
                  <FlexItem spacer={{ default: 'spacerNone' }}>
                    <Bullseye style={{ padding: '0 5px' }}>
                      <Text>{__('to')}</Text>
                    </Bullseye>
                  </FlexItem>
                  <FlexItem span={2}>
                    <Bullseye
                      onFocus={() => setEndEntry(true)}
                      onBlur={() => setEndEntry(false)}
                    >
                      <DatePicker
                        aria-label="end_date_input"
                        value={endDate}
                        invalidFormatText={invalidDateFormat}
                        dateFormat={dateFormat}
                        onChange={setValidEndDate}
                        dateParse={dateParse}
                        placeholder={endEntry ? 'MM/DD/YYYY' : __('End date')}
                      />
                    </Bullseye>
                  </FlexItem>
                </Flex>
                <Flex>
                  <FlexItem>
                    <ChipGroup categoryName={__('Status')}>
                      <Chip key="status" onClick={() => setStatusSelected(ALL_STATUSES)} isReadOnly={statusSelected === ALL_STATUSES}>
                        {statusSelected}
                      </Chip>
                    </ChipGroup>
                  </FlexItem>
                  <FlexItem>
                    <ChipGroup categoryName={dateType === 'issued' ? __('Issued from') : __('Updated from')}>
                      <Chip key="startDate" onClick={() => setValidStartDate('')} isReadOnly={startDate === ''}>
                        {startDate || __('ANY')}
                      </Chip>
                      {__('to')}
                      <Chip key="endDate" onClick={() => setValidEndDate('')} isReadOnly={endDate === ''}>
                        {endDate || __('ANY')}
                      </Chip>
                    </ChipGroup>
                  </FlexItem>
                  <FlexItem>
                    <ChipGroup categoryName={__('Type')}>
                      {selectedTypes.map(type => (
                        <Chip
                          key={type}
                          onClick={() => onTypeSelect(type)}
                          isReadOnly={singleSelection(type)}
                        >
                          {capitalize(type)}
                        </Chip>
                      ))}
                    </ChipGroup>
                  </FlexItem>
                  <FlexItem>
                    <Button ouiaId="errata-reset-filters-button" isDisabled={resetFiltersDisabled} variant="link" onClick={resetFilters} isInline>
                      {__('Reset filters')}
                    </Button>
                  </FlexItem>
                </Flex>
              </>
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

CVErrataIDFilterContent.propTypes = {
  cvId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
  filterId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
  showAffectedRepos: PropTypes.bool.isRequired,
  setShowAffectedRepos: PropTypes.func.isRequired,
  details: PropTypes.shape({
    permissions: PropTypes.shape({}),
  }).isRequired,
};

export default CVErrataIDFilterContent;
