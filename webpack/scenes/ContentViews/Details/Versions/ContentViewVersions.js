import React, { useState, useCallback } from 'react';
import useDeepCompareEffect from 'use-deep-compare-effect';
import { useSelector } from 'react-redux';
import { TableVariant, TableText } from '@patternfly/react-table';
import { translate as __ } from 'foremanReact/common/I18n';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import { STATUS } from 'foremanReact/constants';
import PropTypes from 'prop-types';

import TableWrapper from '../../../../components/Table/TableWrapper';
import InactiveText from '../../components/InactiveText';
import ContentViewVersionEnvironments from './ContentViewVersionEnvironments';
import ContentViewVersionErrata from './ContentViewVersionErrata';
import ContentViewVersionContent from './ContentViewVersionContent';
import { getContentViewVersions } from '../ContentViewDetailActions';
import {
  selectCVVersions,
  selectCVVersionsStatus,
  selectCVVersionsError,
} from '../ContentViewDetailSelectors';

const ContentViewVersions = ({ cvId }) => {
  const response = useSelector(state => selectCVVersions(state, cvId));
  const status = useSelector(state => selectCVVersionsStatus(state, cvId));
  const error = useSelector(state => selectCVVersionsError(state, cvId));
  const loading = status === STATUS.PENDING;

  const [rows, setRows] = useState([]);
  const [metadata, setMetadata] = useState({});
  const [searchQuery, updateSearchQuery] = useState('');

  const columnHeaders = [
    __('Version'),
    __('Environments'),
    __('Packages'),
    __('Errata'),
    __('Additional content'),
    __('Description'),
  ];


  useDeepCompareEffect(() => {
    const buildRows = (results) => {
      const newRows = [];
      results.forEach((cvVersion) => {
        const {
          version,
          description,
          id: versionId,
          environments,
          rpm_count: packageCount,
          errata_counts: errataCounts,
        } = cvVersion;

        const cells = [
          { title: <a href={urlBuilder(`content_views/${cvId}/versions/${versionId}`, '')}>{`Version ${version}`}</a> },
          { title: <ContentViewVersionEnvironments {...{ environments }} /> },
          { title: <a href={urlBuilder(`content_views/${cvId}/versions/${versionId}/packages`, '')}>{`${packageCount}`}</a> },
          { title: <ContentViewVersionErrata {...{ cvId, versionId, errataCounts }} /> },
          { title: <ContentViewVersionContent {...{ cvId, versionId, cvVersion }} /> },
          { title: description ? <TableText wrapModifier="truncate">{description}</TableText> : <InactiveText text={__('No description')} /> },
        ];

        newRows.push({ cells });
      });
      return newRows;
    };

    const { results, ...meta } = response;
    setMetadata(meta);
    if (!loading && results) {
      const newRows = buildRows(results);
      setRows(newRows);
    }
  }, [response, setMetadata, loading, setRows, cvId]);

  const emptyContentTitle = __("You currently don't have any versions for this content view.");
  const emptyContentBody = __('Versions will appear here when the content view is published.'); // needs link
  const emptySearchTitle = __('No matching version found');
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
      cells={columnHeaders}
      variant={TableVariant.compact}
      autocompleteEndpoint={`/content_view_versions/auto_complete_search?content_view_id=${cvId}`}
      fetchItems={useCallback(params => getContentViewVersions(cvId, params), [cvId])}
    />);
};

ContentViewVersions.propTypes = {
  cvId: PropTypes.number.isRequired,
};
export default ContentViewVersions;
