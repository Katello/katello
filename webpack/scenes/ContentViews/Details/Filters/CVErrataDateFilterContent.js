import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';
import { isEqual, sortBy, capitalize } from 'lodash';
import { shallowEqual, useSelector, useDispatch } from 'react-redux';
import { Link, useHistory } from 'react-router-dom';
import {
  Tooltip, Form, ActionGroup, Flex, FlexItem, Select,
  SelectOption, SelectVariant, ChipGroup, Chip,
  Tabs, Tab, TabTitleText, Button, DatePicker, Bullseye,
  Divider, Text,
} from '@patternfly/react-core';
import { OutlinedQuestionCircleIcon } from '@patternfly/react-icons';
import { translate as __ } from 'foremanReact/common/I18n';
import { selectCVFilterDetails } from '../ContentViewDetailSelectors';
import AffectedRepositoryTable from './AffectedRepositories/AffectedRepositoryTable';
import { editCVFilterRule } from '../ContentViewDetailActions';
import { hasPermission } from '../../helpers';

export const dateFormat = date => `${(date.getMonth() + 1).toString().padStart(2, '0')}/${date.getDate().toString().padStart(2, '0')}/${date.getFullYear()}`;

export const convertAPIDateToUIFormat = (dateString) => {
  if (!dateString || dateString === '') return '';
  return dateFormat(new Date(dateString));
};

export const dateParse = (date) => {
  if (!date || date === '') return new Date();
  const split = date.split('/');
  if (split.length !== 3) {
    return undefined;
  }
  const [month, day, year] = split;
  return new Date(`${year}-${month.padStart(2, '0')}-${day.padStart(2, '0')}T12:00:00Z`);
};

export const isValidDate = date => date instanceof Date && !Number.isNaN(date.getTime());

const CVErrataDateFilterContent = ({
  cvId, filterId, inclusion, showAffectedRepos, setShowAffectedRepos, details,
}) => {
  const { push } = useHistory();
  const filterDetails = useSelector(state =>
    selectCVFilterDetails(state, cvId, filterId), shallowEqual);
  const { repositories = [], rules } = filterDetails;
  const [{
    id, types, start_date: ruleStartDate, end_date: ruleEndDate, date_type: ruleDateType,
  } = {}] = rules;
  const { permissions } = details;
  const [startDate, setStartDate] = useState(convertAPIDateToUIFormat(ruleStartDate));
  const [endDate, setEndDate] = useState(convertAPIDateToUIFormat(ruleEndDate));
  const [dateType, setDateType] = useState(ruleDateType);
  const [dateTypeSelectOpen, setDateTypeSelectOpen] = useState(false);
  const [typeSelectOpen, setTypeSelectOpen] = useState(false);
  const [selectedTypes, setSelectedTypes] = useState(types);
  const dispatch = useDispatch();
  const [activeTabKey, setActiveTabKey] = useState(0);
  const [startEntry, setStartEntry] = useState(false);
  const [endEntry, setEndEntry] = useState(false);

  const onSave = () => {
    dispatch(editCVFilterRule(
      filterId,
      {
        id,
        content_view_filter_id: filterId,
        start_date: startDate && startDate !== '' ? dateParse(startDate) : null,
        end_date: endDate && endDate !== '' ? dateParse(endDate) : null,
        types: selectedTypes,
        date_type: dateType,
      },
      () => push('/filters'),
    ));
  };

  const resetFilters = () => {
    setStartDate(convertAPIDateToUIFormat(ruleStartDate));
    setEndDate(convertAPIDateToUIFormat(ruleEndDate));
    setSelectedTypes(types);
    setDateType(ruleDateType);
  };

  const onTypeSelect = (selection) => {
    if (selectedTypes.includes(selection)) {
      if (selectedTypes.length === 1) return;
      setSelectedTypes(selectedTypes.filter(e => e !== selection));
    } else setSelectedTypes([...selectedTypes, selection]);
  };

  const singleSelection = selection => (selectedTypes.length === 1
    && selectedTypes.includes(selection));

  const saveDisabled = !isValidDate(dateParse(startDate)) || !isValidDate(dateParse(endDate)) ||
    (
      isEqual(convertAPIDateToUIFormat(ruleStartDate), startDate) &&
      isEqual(convertAPIDateToUIFormat(ruleEndDate), endDate) &&
      isEqual(sortBy(types), sortBy(selectedTypes)) &&
      isEqual(ruleDateType, dateType)
    );

  useEffect(() => {
    if (!repositories.length && showAffectedRepos) {
      setActiveTabKey(1);
    } else {
      setActiveTabKey(0);
    }
  }, [showAffectedRepos, repositories.length]);

  const tabTitle = inclusion ? __('Included errata') : __('Excluded errata');
  const invalidDateFormat = __('Enter a valid date: MM/DD/YYYY');

  return (
    <Tabs
      className="margin-0-24"
      ouiaId="errata-date-filter-tabs"
      activeKey={activeTabKey}
      onSelect={(_event, eventKey) => setActiveTabKey(eventKey)}
    >
      <Tab eventKey={0} title={<TabTitleText>{tabTitle}</TabTitleText>}>
        <div className="margin-24">
          <Form onSubmit={(e) => {
            e.preventDefault();
            onSave();
          }}
          >
            <Flex flex={{ default: 'inlineFlex' }}>
              <FlexItem span={2}>
                <Select
                  variant={SelectVariant.checkbox}
                  onToggle={setTypeSelectOpen}
                  onSelect={(_event, selection) => onTypeSelect(selection)}
                  selections={selectedTypes}
                  isOpen={typeSelectOpen}
                  ouiaId="errata-type-selector"
                  placeholderText={__('Errata type')}
                  isCheckboxSelectionBadgeHidden
                >
                  <SelectOption
                    isDisabled={singleSelection('security') || !hasPermission(permissions, 'edit_content_views')}
                    key="security"
                    value="security"
                  >
                    <p style={{ marginTop: '4px' }}>
                      {__('Security')}
                    </p>
                  </SelectOption>
                  <SelectOption
                    isDisabled={singleSelection('enhancement') || !hasPermission(permissions, 'edit_content_views')}
                    key="enhancement"
                    value="enhancement"
                  >
                    <p style={{ marginTop: '4px' }}>
                      {__('Enhancement')}
                    </p>
                  </SelectOption>
                  <SelectOption
                    isDisabled={singleSelection('bugfix') || !hasPermission(permissions, 'edit_content_views')}
                    key="bugfix"
                    value="bugfix"
                  >
                    <p style={{ marginTop: '4px' }}>
                      {__('Bugfix')}
                    </p>
                  </SelectOption>
                </Select>
              </FlexItem>
              <FlexItem span={1} spacer={{ default: 'spacerNone' }}>
                {(selectedTypes.length === 1) &&
                  <Tooltip
                    position="top"
                    content={
                      __('Atleast one errata type needs to be selected.')
                    }
                  >
                    <OutlinedQuestionCircleIcon />
                  </Tooltip>
                }
              </FlexItem>
              <Divider isVertical />
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
                  ouiaId="date_type_selector"
                  name="date_type_selector"
                  aria-label="date_type_selector"
                  isDisabled={!hasPermission(permissions, 'edit_content_views')}
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
                    value={startDate}
                    invalidFormatText={invalidDateFormat}
                    dateFormat={dateFormat}
                    onChange={setStartDate}
                    dateParse={dateParse}
                    placeholder={startEntry ? 'MM/DD/YYYY' : __('Start date')}
                    isDisabled={!hasPermission(permissions, 'edit_content_views')}
                  />
                </Bullseye>
              </FlexItem>
              <FlexItem spacer={{ default: 'spacerNone' }}>
                <Bullseye style={{ padding: '0 5px' }}>
                  <Text ouiaId="to-text">{__('to')}</Text>
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
                    onChange={setEndDate}
                    dateParse={dateParse}
                    placeholder={endEntry ? 'MM/DD/YYYY' : __('End date')}
                    isDisabled={!hasPermission(permissions, 'edit_content_views')}
                  />
                </Bullseye>
              </FlexItem>
            </Flex>
            <Flex>
              <FlexItem>
                <ChipGroup ouiaId="chipgroup-type" categoryName={__('Type')}>
                  {selectedTypes.map(type => (
                    <Chip
                      ouiaId={type}
                      key={type}
                      onClick={() => onTypeSelect(type)}
                      isReadOnly={singleSelection(type) || !hasPermission(permissions, 'edit_content_views')}
                    >
                      {capitalize(type)}
                    </Chip>
                  ))}
                </ChipGroup>
              </FlexItem>
              <FlexItem>
                <ChipGroup
                  ouiaId="chip-issued"
                  categoryName={dateType === 'issued' ? __('Issued from') : __('Updated from')}
                >
                  <Chip
                    ouiaId="startDate"
                    key="startDate"
                    onClick={() => setStartDate('')}
                    isReadOnly={!startDate || !hasPermission(permissions, 'edit_content_views')}
                  >
                    {startDate || __('ANY')}
                  </Chip>
                  {__('to')}
                  <Chip ouiaId="startDate" key="endDate" onClick={() => setEndDate('')} isReadOnly={!endDate || !hasPermission(permissions, 'edit_content_views')}>
                    {endDate || __('ANY')}
                  </Chip>
                </ChipGroup>
              </FlexItem>
              {hasPermission(permissions, 'edit_content_views') &&
                <FlexItem>
                  <Button
                    ouiaId="errata-date-reset-filters-button"
                    isDisabled={saveDisabled}
                    variant="link"
                    onClick={resetFilters}
                    isInline
                  >
                    {__('Reset filters')}
                  </Button>
                </FlexItem>
              }
            </Flex>
            {hasPermission(permissions, 'edit_content_views') &&
              <ActionGroup>
                <Button
                  ouiaId="save-filter-rule-button"
                  aria-label="save_filter_rule"
                  variant="primary"
                  isDisabled={saveDisabled}
                  type="submit"
                >
                  {__('Edit rule')}
                </Button>
                <Link to={`/content_views/${cvId}#/filters`}>
                  <Button ouiaId="cancel-save-filter-rule-button" variant="link">
                    {__('Cancel')}
                  </Button>
                </Link>
              </ActionGroup>
            }
          </Form>
        </div>
      </Tab>
      {(repositories.length || showAffectedRepos) &&
        <Tab eventKey={1} title={<TabTitleText>{__('Affected repositories')}</TabTitleText>}>
          <div className="margin-24-0">
            <AffectedRepositoryTable cvId={cvId} filterId={filterId} repoType="yum" setShowAffectedRepos={setShowAffectedRepos} details={details} />
          </div>
        </Tab>}
    </Tabs>
  );
};

CVErrataDateFilterContent.propTypes = {
  cvId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
  filterId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
  inclusion: PropTypes.bool,
  showAffectedRepos: PropTypes.bool.isRequired,
  setShowAffectedRepos: PropTypes.func.isRequired,
  details: PropTypes.shape({
    permissions: PropTypes.shape({}),
  }).isRequired,
};

CVErrataDateFilterContent.defaultProps = {
  cvId: '',
  filterId: '',
  inclusion: false,
};
export default CVErrataDateFilterContent;
