import React, { useState, useEffect } from 'react';
import { useSelector } from 'react-redux';
import { TableVariant, TableText } from '@patternfly/react-table';
import { Label } from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import LongDateTime from 'foremanReact/components/common/dates/LongDateTime';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import { STATUS } from 'foremanReact/constants';
import PropTypes from 'prop-types';

import TableWrapper from '../../../../components/Table/TableWrapper';
import { getContentViewHistories } from '../ContentViewDetailActions';
import {
  selectCVHistories,
  selectCVHistoriesStatus,
  selectCVHistoriesError,
} from '../ContentViewDetailSelectors';

const ContentViewHistories = ({ cvId }) => {
  const response = useSelector(state => selectCVHistories(state, cvId));
  const status = useSelector(state => selectCVHistoriesStatus(state, cvId));
  const error = useSelector(state => selectCVHistoriesError(state, cvId));
  const loading = status === STATUS.PENDING;

  const [rows, setRows] = useState([]);
  const [metadata, setMetadata] = useState({});
  const [searchQuery, updateSearchQuery] = useState('');

  const taskTypes = {
    publish: 'Actions::Katello::ContentView::Publish',
    promotion: 'Actions::Katello::ContentView::Promote',
    removal: 'Actions::Katello::ContentView::Remove',
    incrementalUpdate: 'Actions::Katello::ContentView::IncrementalUpdates',
    export: 'Actions::Katello::ContentViewVersion::Export',
  };

  const columnHeaders = [
    __('Date'),
    __('Version'),
    __('Status'),
    __('Action'),
    __('Description'),
    __('User'),
  ];


  useEffect(() => {
    const actionText = (history) => {
      const {
        action,
        task,
        environment,
      } = history;

      const taskType = task ? task.label : taskTypes[action];

      if (taskType === taskTypes.removal) {
        return <React.Fragment> {__('Deleted from')} <Label key="1" color="blue" href={`/lifecycle_environments/${environment.id}`}>{`${environment.name}`}</Label>{}</React.Fragment>;
      } else if (taskType === taskTypes.promotion) {
        return <React.Fragment> {__('Promoted to')} <Label key="2" color="blue" href={`/lifecycle_environments/${environment.id}`}>{`${environment.name}`}</Label>{}</React.Fragment>;
      } else if (taskType === taskTypes.publish) {
        return ('Published new version');
      } else if (taskType === taskTypes.export) {
        return ('Exported content view');
      } else if (taskType === taskTypes.incrementalUpdate) {
        return ('Incremental update');
      }
      return '';
    };

    const buildRows = (results) => {
      const newRows = [];
      results.forEach((history) => {
        const {
          version,
          version_id: versionId,
          created_at: createdAt,
          status: taskStatus,
          description,
          user,
        } = history;

        const actionMessage = actionText(history);

        const cells = [
          { title: <LongDateTime date={createdAt} showRelativeTimeTooltip /> },
          { title: <a href={urlBuilder(`content_views/${cvId}/versions/${versionId}`, '')}>{`Version ${version}`}</a> },
          taskStatus,
          actionMessage,
          { title: <TableText wrapModifier="truncate">{description}</TableText> },
          user,
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
  }, [JSON.stringify(response)], setMetadata, loading, setRows);

  const emptyContentTitle = __("You currently don't have any history for this content view.");
  const emptyContentBody = __('History will appear here when the content view is published or promoted.'); // needs link
  const emptySearchTitle = __('No matching history record found');
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
      autocompleteEndpoint={`/content_views/${cvId}/history/auto_complete_search`}
      fetchItems={params => getContentViewHistories(cvId, params)}
    />);
};

ContentViewHistories.propTypes = {
  cvId: PropTypes.number.isRequired,
};
export default ContentViewHistories;
