import React, { useState, useEffect } from 'react';
import { useSelector } from 'react-redux';
import {
  Bullseye,
} from '@patternfly/react-core';
import { Link } from 'react-router-dom';
import { TableVariant, fitContent, TableText } from '@patternfly/react-table';
import { STATUS } from 'foremanReact/constants';
import { translate as __ } from 'foremanReact/common/I18n';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import PropTypes from 'prop-types';

import TableWrapper from '../../../../components/Table/TableWrapper';
import onSelect from '../../../../components/Table/helpers';
import {
  selectCVComponents,
  selectCVComponentsStatus,
  selectCVComponentsError,
} from '../ContentViewDetailSelectors';
import { getContentViewComponents } from '../ContentViewDetailActions';
import AddedStatusLabel from '../../../../components/AddedStatusLabel';
import ComponentVersion from './ComponentVersion';
import ComponentEnvironments from './ComponentEnvironments';
import ContentViewIcon from '../../components/ContentViewIcon';

const ContentViewComponents = ({ cvId }) => {
  const response = useSelector(state => selectCVComponents(state, cvId));
  const status = useSelector(state => selectCVComponentsStatus(state, cvId));
  const error = useSelector(state => selectCVComponentsError(state, cvId));

  const [rows, setRows] = useState([]);
  const [metadata, setMetadata] = useState({});
  const [searchQuery, updateSearchQuery] = useState('');
  const columnHeaders = [
    { title: __('Type'), transforms: [fitContent] },
    __('Name'),
    __('Version'),
    __('Environments'),
    __('Repositories'),
    { title: __('Status') },
    __('Description'),
  ];
  const loading = status === STATUS.PENDING;

  const buildRows = (results) => {
    const newRows = [];
    results.forEach((componentCV) => {
      const { content_view: cv, content_view_version: cvVersion } = componentCV;
      const { environments, repositories } = cvVersion;
      const {
        id,
        name,
        description,
      } = cv;

      const cells = [
        { title: <Bullseye><ContentViewIcon composite={false} /></Bullseye> },
        { title: <Link to={urlBuilder('labs/content_views', '', id)}>{name}</Link> },
        { title: <ComponentVersion {...{ componentCV }} /> },
        { title: <ComponentEnvironments {...{ environments }} /> },
        { title: <Link to={urlBuilder(`labs/content_views/${id}#repositories`, '')}>{ repositories.length }</Link> },
        {
          title: <AddedStatusLabel added />,
        },
        { title: <TableText wrapModifier="truncate">{description}</TableText> },
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

  const emptyContentTitle = __("You currently don't have any content views to add to this content view.");
  const emptyContentBody = __('Please add some content views.'); // needs link
  const emptySearchTitle = __('No matching content views found');
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
      autocompleteEndpoint="/content_views/auto_complete_search"
      fetchItems={params => getContentViewComponents(cvId, params)}
    />
  );
};

ContentViewComponents.propTypes = {
  cvId: PropTypes.number.isRequired,
};

export default ContentViewComponents;
