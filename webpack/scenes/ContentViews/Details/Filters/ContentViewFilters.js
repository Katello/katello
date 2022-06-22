import React, { useState, useEffect, useCallback } from 'react';
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
import { hasPermission } from '../../helpers';
import InactiveText from '../../components/InactiveText';

const ContentViewFilters = ({ cvId, details }) => {
  const dispatch = useDispatch();
  const response = useSelector(state => selectCVFilters(state, cvId), shallowEqual);
  const { results, ...metadata } = response;
  const status = useSelector(state => selectCVFiltersStatus(state, cvId), shallowEqual);
  const error = useSelector(state => selectCVFiltersError(state, cvId), shallowEqual);
  const [rows, setRows] = useState([]);
  const [searchQuery, updateSearchQuery] = useState('');
  const loading = status === STATUS.PENDING;
  const [addModalOpen, setAddModalOpen] = useState(false);
  const [bulkActionOpen, setBulkActionOpen] = useState(false);
  const [bulkActionEnabled, setBulkActionEnabled] = useState(false);
  const toggleBulkAction = () => setBulkActionOpen(prevState => !prevState);
  const { permissions } = details;

  const openAddModal = () => setAddModalOpen(true);

  const columnHeaders = [
    __('Name'),
    __('Description'),
    __('Updated'),
    __('Content type'),
    __('Inclusion type'),
  ];
  const buildRows = useCallback(() => {
    const newRows = [];
    results.forEach((filter) => {
      let errataByDate = false;
      const {
        id, name, type, description, updated_at: updatedAt, inclusion, rules,
      } = filter;
      if (type === 'erratum' && rules[0]?.types) errataByDate = true;

      const cells = [
        { title: <Link to={`/filters/${id}`}>{name}</Link> },
        {
          title: description ?
            truncate(description) :
            <InactiveText text={__('No description')} />,
        },
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
  }, [results]);

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
    if (!loading && results) {
      const newRows = buildRows();
      setRows(newRows);
    }
  }, [response, loading, results, buildRows]);

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
      }}
      ouiaId="content-view-filters-table"
      actionResolver={hasPermission(permissions, 'edit_content_views') ? actionResolver : null}
      onSelect={hasPermission(permissions, 'edit_content_views') ? onSelect(rows, setRows) : null}
      cells={columnHeaders}
      variant={TableVariant.compact}
      autocompleteEndpoint="/content_view_filters/auto_complete_search"
      fetchItems={useCallback(params => getContentViewFilters(cvId, params), [cvId])}
      actionButtons={hasPermission(permissions, 'edit_content_views') &&
        <>
          <Split hasGutter>
            <SplitItem>
              <Button ouiaId="create-filter-button" onClick={openAddModal} variant="primary" aria-label="create_filter">
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
              onClose={() => setAddModalOpen(false)}
              aria-label="add_filter_modal"
            />}
        </>
      }
    />);
};

ContentViewFilters.propTypes = {
  cvId: PropTypes.number.isRequired,
  details: PropTypes.shape({
    permissions: PropTypes.shape({}),
  }).isRequired,
};

export default ContentViewFilters;
