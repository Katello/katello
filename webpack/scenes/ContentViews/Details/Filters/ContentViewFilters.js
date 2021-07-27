import React, { useState, useEffect } from 'react';
import useDeepCompareEffect from 'use-deep-compare-effect';
import { shallowEqual, useSelector, useDispatch } from 'react-redux';
import { Label, Split, SplitItem, Button, Dropdown, DropdownItem, KebabToggle } from '@patternfly/react-core';
import { TableVariant } from '@patternfly/react-table';
import { STATUS } from 'foremanReact/constants';
import LongDateTime from 'foremanReact/components/common/dates/LongDateTime';
import { translate as __ } from 'foremanReact/common/I18n';
import { Link } from 'react-router-dom';
import PropTypes from 'prop-types';

import TableWrapper from '../../../../components/Table/TableWrapper';
import onSelect from '../../../../components/Table/helpers';
import { deleteContentViewFilter, deleteContentViewFilters, getContentViewFilters } from '../ContentViewDetailActions';
import {
  selectCVFilters,
  selectCVFiltersStatus,
  selectCVFiltersError,
} from '../ContentViewDetailSelectors';
import { truncate } from '../../../../utils/helpers';
import ContentType from './ContentType';
import CVFilterAddModal from './Add/CVFilterAddModal';

const cvFilterUrl = (cvId, filterId) => `/labs/content_views/${cvId}#filters?subContentId=${filterId}`;

const ContentViewFilters = ({ cvId }) => {
  const dispatch = useDispatch();
  const response = useSelector(state => selectCVFilters(state, cvId), shallowEqual);
  const status = useSelector(state => selectCVFiltersStatus(state, cvId), shallowEqual);
  const error = useSelector(state => selectCVFiltersError(state, cvId), shallowEqual);
  const [rows, setRows] = useState([]);
  const [metadata, setMetadata] = useState({});
  const [searchQuery, updateSearchQuery] = useState('');
  const loading = status === STATUS.PENDING;
  const [addModalOpen, setAddModalOpen] = useState(false);
  const [bulkActionOpen, setBulkActionOpen] = useState(false);
  const [bulkActionEnabled, setBulkActionEnabled] = useState(false);
  const toggleBulkAction = () => setBulkActionOpen(prevState => !prevState);

  const openAddModal = () => setAddModalOpen(true);

  const columnHeaders = [
    __('Name'),
    __('Description'),
    __('Updated'),
    __('Content type'),
    __('Inclusion type'),
  ];

  const buildRows = (results) => {
    const newRows = [];
    results.forEach((filter) => {
      let errataByDate = false;
      const {
        id, name, type, description, updated_at: updatedAt, inclusion, rules,
      } = filter;
      if (type === 'erratum' && rules[0]?.types) errataByDate = true;

      const cells = [
        { title: (type === 'package_group' || type === 'rpm') ? <Link to={cvFilterUrl(cvId, id)}>{name}</Link> : name },
        truncate(description || ''),
        { title: <LongDateTime date={updatedAt} showRelativeTimeTooltip /> },
        { title: <ContentType type={type} errataByDate={errataByDate} /> },
        {
          title: (
            <Label color={inclusion && 'blue'}>
              {inclusion ? 'Include' : 'Exclude'}
            </Label>),
        },
      ];

      newRows.push({ cells, id });
    });
    return newRows;
  };

  const bulkRemove = () => {
    setBulkActionOpen(false);
    const filterIds = rows.filter(({ selected }) => selected).map(({ id }) => id);
    dispatch(deleteContentViewFilters(cvId, filterIds, () =>
      dispatch(getContentViewFilters(cvId, {}))));
  };

  useEffect(() => {
    const rowsAreSelected = rows.some(row => row.selected);
    setBulkActionEnabled(rowsAreSelected);
  }, [rows]);

  useDeepCompareEffect(() => {
    const { results, ...meta } = response;
    setMetadata(meta);

    if (!loading && results) {
      const newRows = buildRows(results);
      setRows(newRows);
    }
  }, [response]);

  const actionResolver = () => [
    {
      title: __('Remove'),
      onClick: (_event, _rowId, { id }) => {
        dispatch(deleteContentViewFilter(id, () =>
          dispatch(getContentViewFilters(cvId, {}))));
      },
    },
  ];

  const emptyContentTitle = __("You currently don't have any filters for this content view.");
  const emptyContentBody = __("Add filters using the 'Add filter' button above."); // needs link
  const emptySearchTitle = __('No matching filters found');
  const emptySearchBody = __('Try changing your search settings.');

  return (
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
      onSelect={onSelect(rows, setRows)}
      cells={columnHeaders}
      variant={TableVariant.compact}
      autocompleteEndpoint="/content_view_filters/auto_complete_search"
      fetchItems={params => getContentViewFilters(cvId, params)}
    >
      <Split hasGutter>
        <SplitItem>
          <Button onClick={openAddModal} variant="secondary" aria-label="create_filter">
            {__('Create filter')}
          </Button>
        </SplitItem>
        <SplitItem>
          <Dropdown
            toggle={<KebabToggle aria-label="bulk_actions" onToggle={toggleBulkAction} />}
            isOpen={bulkActionOpen}
            isPlain
            dropdownItems={[
              <DropdownItem aria-label="bulk_remove" key="bulk_remove" isDisabled={!bulkActionEnabled} component="button" onClick={bulkRemove}>
                {__('Remove')}
              </DropdownItem>]
            }
          />
        </SplitItem>
      </Split>
      {addModalOpen &&
        <CVFilterAddModal
          cvId={cvId}
          show={addModalOpen}
          setIsOpen={setAddModalOpen}
          aria-label="add_filter_modal"
        />
      }
    </TableWrapper>);
};


ContentViewFilters.propTypes = {
  cvId: PropTypes.number.isRequired,
};

export default ContentViewFilters;
