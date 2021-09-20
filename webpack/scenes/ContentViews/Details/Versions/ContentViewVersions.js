import React, { useState, useEffect, useCallback } from 'react';
import useDeepCompareEffect from 'use-deep-compare-effect';
import { useDispatch, useSelector } from 'react-redux';
import { TableVariant, TableText } from '@patternfly/react-table';
import { translate as __ } from 'foremanReact/common/I18n';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import { STATUS } from 'foremanReact/constants';
import { useParams, Link } from 'react-router-dom';

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
import getEnvironmentPaths from '../../components/EnvironmentPaths/EnvironmentPathActions';
import ContentViewVersionPromote from '../Promote/ContentViewVersionPromote';
import TaskPresenter from '../../components/TaskPresenter/TaskPresenter';
import { startPollingTask } from '../../../Tasks/TaskActions';

export default () => {
  const { id } = useParams();
  const cvId = Number(id);
  const response = useSelector(state => selectCVVersions(state, cvId));
  const status = useSelector(state => selectCVVersionsStatus(state, cvId));
  const error = useSelector(state => selectCVVersionsError(state, cvId));
  const [pollingFinished, setPollingFinished] = useState(false);
  const loading = status === STATUS.PENDING;
  const dispatch = useDispatch();
  const [rows, setRows] = useState([]);
  const [metadata, setMetadata] = useState({});
  const [searchQuery, updateSearchQuery] = useState('');
  const [versionIdToPromote, setVersionIdToPromote] = useState('');
  const [versionNameToPromote, setVersionNameToPromote] = useState('');
  const [versionEnvironments, setVersionEnvironments] = useState([]);
  const [promoting, setPromoting] = useState(false);

  const columnHeaders = [
    __('Version'),
    __('Environments'),
    __('Packages'),
    __('Errata'),
    __('Additional content'),
    __('Description'),
  ];

  useEffect(
    () => {
      dispatch(getEnvironmentPaths());
    },
    [dispatch],
  );

  const buildCells = useCallback((cvVersion) => {
    const {
      version,
      description,
      id: versionId,
      environments,
      rpm_count: packageCount,
      errata_counts: errataCounts,
    } = cvVersion;
    return [
      { title: <Link to={`/labs/content_views/${cvId}/versions/${versionId}/`}>{__('Version ')}{version}</Link> },
      { title: <ContentViewVersionEnvironments {...{ environments }} /> },
      { title: <a href={urlBuilder(`content_views/${cvId}/versions/${versionId}/packages`, '')}>{`${packageCount}`}</a> },
      { title: <ContentViewVersionErrata {...{ cvId, versionId, errataCounts }} /> },
      { title: <ContentViewVersionContent {...{ cvId, versionId, cvVersion }} /> },
      { title: description ? <TableText wrapModifier="truncate">{description}</TableText> : <InactiveText text={__('No description')} /> },
    ];
  }, [cvId]);

  const buildActiveTaskCells = useCallback((cvVersion) => {
    const {
      version,
      description,
      id: versionId,
      active_history: activeHistory,
    } = cvVersion;
    const { task } = activeHistory[0];
    const { result } = task || {};
    if (result !== 'error') {
      dispatch(startPollingTask(task.id, task));
    }

    return [
      { title: <a href={urlBuilder(`content_views/${cvId}/versions/${versionId}`, '')}>{__('Version ')}{version}</a> },
      {
        title: <TaskPresenter
          activeHistory={activeHistory[0]}
          setPollingFinished={setPollingFinished}
        />,
      },
      { title: '' },
      { title: '' },
      { title: '' },
      { title: description ? <TableText wrapModifier="truncate">{description}</TableText> : <InactiveText text={__('No description')} /> },
    ];
  }, [cvId, dispatch]);

  useDeepCompareEffect(() => {
    const buildRows = (results) => {
      const newRows = [];
      results.forEach((cvVersion) => {
        const {
          version,
          id: versionId,
          environments,
          active_history: activeHistory,
        } = cvVersion;

        const cells = activeHistory.length ?
          buildActiveTaskCells(cvVersion) :
          buildCells(cvVersion);
        newRows.push({
          cvVersionId: versionId,
          cvVersionName: version,
          cvVersionEnvironments: environments,
          activeHistory,
          cells,
        });
      });
      return newRows;
    };

    const { results, ...meta } = response;
    setMetadata(meta);
    if (!loading && results) {
      const newRows = buildRows(results);
      setRows(newRows);
    }
  }, [response, setMetadata, buildActiveTaskCells, buildCells, dispatch, loading, setRows]);

  const onPromote = ({ cvVersionId, cvVersionName, cvVersionEnvironments }) => {
    setVersionIdToPromote(cvVersionId);
    setVersionNameToPromote(cvVersionName);
    setVersionEnvironments(cvVersionEnvironments);
    setPromoting(true);
    setPollingFinished(false);
  };

  const actionResolver = (rowData, { _rowIndex }) => [
    {
      title: __('Promote'),
      isDisabled: rowData.activeHistory.length,
      onClick: (_event, rowId, rowInfo) => {
        onPromote({
          cvVersionId: rowInfo.cvVersionId,
          cvVersionName: rowInfo.cvVersionName,
          cvVersionEnvironments: rowInfo.cvVersionEnvironments,
        });
      },
    },
    {
      title: __('Remove'),
      isDisabled: true,
    },
  ];

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
        actionResolver,
        error,
        status,
      }}
      cells={columnHeaders}
      variant={TableVariant.compact}
      autocompleteEndpoint={`/content_view_versions/auto_complete_search?content_view_id=${cvId}`}
      fetchItems={useCallback(params => getContentViewVersions(cvId, params), [cvId])}
      additionalListeners={[pollingFinished]}
      actionButtons={promoting && <ContentViewVersionPromote
        cvId={cvId}
        versionIdToPromote={versionIdToPromote}
        versionNameToPromote={versionNameToPromote}
        versionEnvironments={versionEnvironments}
        setIsOpen={setPromoting}
        aria-label="promote_content_view_modal"
      />
      }
    />);
};

