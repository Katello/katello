import React, { useState, useEffect } from 'react';
import { shallowEqual, useSelector } from 'react-redux';
import { Label } from '@patternfly/react-core';
import { TableVariant } from '@patternfly/react-table';
import { STATUS } from 'foremanReact/constants';
import LongDateTime from 'foremanReact/components/common/dates/LongDateTime';
import { translate as __ } from 'foremanReact/common/I18n';
import { Link } from 'react-router-dom';
import PropTypes from 'prop-types';

import TableWrapper from '../../../../components/Table/TableWrapper';
import onSelect from '../../../../components/Table/helpers';
import { getContentViewFilters } from '../ContentViewDetailActions';
import {
  selectCVFilters,
  selectCVFiltersStatus,
  selectCVFiltersError,
} from '../ContentViewDetailSelectors';
import { truncate } from '../../../../utils/helpers';
import ContentType from './ContentType';

const cvFilterUrl = (cvId, filterId) => `/labs/content_views/${cvId}#filters?subContentId=${filterId}`;

const ContentViewFilters = ({ cvId }) => {
  const response = useSelector(state => selectCVFilters(state, cvId), shallowEqual);
  const status = useSelector(state => selectCVFiltersStatus(state, cvId), shallowEqual);
  const error = useSelector(state => selectCVFiltersError(state, cvId), shallowEqual);
  const [rows, setRows] = useState([]);
  const [metadata, setMetadata] = useState({});
  const [searchQuery, updateSearchQuery] = useState('');
  const loading = status === STATUS.PENDING;

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
        id, name, type, description, updated_at: updatedAt, inclusion,
      } = filter;
      if (filter.type === 'erratum' && filter.rules[0].types) errataByDate = true;

      const cells = [
        { title: <Link to={cvFilterUrl(cvId, id)}>{name}</Link> },
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
      onSelect={onSelect(rows, setRows)}
      cells={columnHeaders}
      variant={TableVariant.compact}
      autocompleteEndpoint="/content_view_filters/auto_complete_search"
      fetchItems={params => getContentViewFilters(cvId, params)}
    />);
};


ContentViewFilters.propTypes = {
  cvId: PropTypes.number.isRequired,
};

export default ContentViewFilters;
