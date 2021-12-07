import React, { useState, useEffect, useCallback } from 'react';
import useDeepCompareEffect from 'use-deep-compare-effect';
import { useDispatch, useSelector } from 'react-redux';
import { TableVariant, TableText } from '@patternfly/react-table';
import { translate as __ } from 'foremanReact/common/I18n';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import { STATUS } from 'foremanReact/constants';
import { Link } from 'react-router-dom';
import PropTypes from 'prop-types';
import { selectIntervals } from 'foremanReact/redux/middlewares/IntervalMiddleware/IntervalSelectors.js';

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
import RemoveCVVersionWizard from './Delete/RemoveCVVersionWizard';
import { hasPermission } from '../../helpers';
import { pollTaskKey } from '../../../Tasks/helpers';

const ContentViewVersions = ({ cvId, details }) => {
  const response = useSelector(state => selectCVVersions(state, cvId));
  const { results, ...metadata } = response;
  const status = useSelector(state => selectCVVersionsStatus(state, cvId));
  const error = useSelector(state => selectCVVersionsError(state, cvId));
  const [pollingFinished, setPollingFinished] = useState(false);
  const loading = status === STATUS.PENDING;
  const dispatch = useDispatch();
  const [rows, setRows] = useState([]);
  const [searchQuery, updateSearchQuery] = useState('');
  const [versionIdToPromote, setVersionIdToPromote] = useState('');
  const [versionNameToPromote, setVersionNameToPromote] = useState('');
  const [versionIdToRemove, setVersionIdToRemove] = useState('');
  const [versionNameToRemove, setVersionNameToRemove] = useState('');
  const [versionEnvironments, setVersionEnvironments] = useState([]);
  const [promoting, setPromoting] = useState(false);
  const [removingFromEnv, setRemovingFromEnv] = useState(false);
  const [deleteVersion, setDeleteVersion] = useState(false);
  const [currentStep, setCurrentStep] = useState(1);
  const { permissions } = details;
  const intervals = useSelector(state => selectIntervals(state));

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
      { title: <Link to={`/versions/${versionId}`}>{__('Version ')}{version}</Link> },
      { title: <ContentViewVersionEnvironments {...{ environments }} /> },
      {
        title: Number(packageCount) ?
          <a href={urlBuilder(`content_views/${cvId}#/versions/${versionId}/packages`, '')}>{packageCount}</a> :
          <InactiveText text={__('No packages')} />,
      },
      { title: <ContentViewVersionErrata {...{ cvId, versionId, errataCounts }} /> },
      { title: <ContentViewVersionContent {...{ cvId, versionId, cvVersion }} /> },
      { title: description ? <TableText wrapModifier="truncate">{description}</TableText> : <InactiveText text={__('No description')} /> },
    ];
  }, [cvId]);

  const buildActiveTaskCells = useCallback((cvVersion, pollIntervals) => {
    const {
      version,
      description,
      id: versionId,
      active_history: activeHistory,
    } = cvVersion;
    const { task } = activeHistory[0];
    const { result } = task || {};
    if (result !== 'error' && !pollIntervals[pollTaskKey(task.id)]) {
      dispatch(startPollingTask(task.id, task));
    }

    return [
      { title: <Link disabled to={`/versions/${versionId}`}>{__('Version ')}{version}</Link> },
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
  }, [dispatch]);

  useDeepCompareEffect(() => {
    const buildRows = () => {
      const newRows = [];
      results.forEach((cvVersion) => {
        const {
          version,
          id: versionId,
          environments,
          active_history: activeHistory,
        } = cvVersion;

        const cells = activeHistory.length ?
          buildActiveTaskCells(cvVersion, intervals) :
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

    if (!loading && results) {
      const newRows = buildRows();
      setRows(newRows);
    }
  }, [response, results, buildActiveTaskCells, buildCells, dispatch, loading, setRows, intervals]);

  const onPromote = ({ cvVersionId, cvVersionName, cvVersionEnvironments }) => {
    setVersionIdToPromote(cvVersionId);
    setVersionNameToPromote(cvVersionName);
    setVersionEnvironments(cvVersionEnvironments);
    setPromoting(true);
    setPollingFinished(false);
  };

  const onRemoveFromEnv = ({
    cvVersionId, cvVersionName, cvVersionEnvironments, deleting,
  }) => {
    setVersionIdToRemove(cvVersionId);
    setVersionNameToRemove(cvVersionName);
    setVersionEnvironments(cvVersionEnvironments);
    setRemovingFromEnv(true);
    setDeleteVersion(deleting);
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
      title: __('Remove from environments'),
      isDisabled: rowData.activeHistory.length,
      onClick: (_event, rowId, rowInfo) => {
        onRemoveFromEnv({
          cvVersionId: rowInfo.cvVersionId,
          cvVersionName: rowInfo.cvVersionName,
          cvVersionEnvironments: rowInfo.cvVersionEnvironments,
          deleting: false,
        });
      },
    },
    {
      title: __('Delete'),
      isDisabled: rowData.activeHistory.length,
      onClick: (_event, rowId, rowInfo) => {
        onRemoveFromEnv({
          cvVersionId: rowInfo.cvVersionId,
          cvVersionName: rowInfo.cvVersionName,
          cvVersionEnvironments: rowInfo.cvVersionEnvironments,
          deleting: true,
        });
      },
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
        error,
        status,
      }}
      actionResolver={hasPermission(permissions, 'promote_or_remove_content_views') ? actionResolver : null}
      cells={columnHeaders}
      variant={TableVariant.compact}
      autocompleteEndpoint={`/content_view_versions/auto_complete_search?content_view_id=${cvId}`}
      fetchItems={useCallback(params => getContentViewVersions(cvId, params), [cvId])}
      additionalListeners={[pollingFinished]}
      actionButtons={
        <>
          {promoting &&
            <ContentViewVersionPromote
              cvId={cvId}
              versionIdToPromote={versionIdToPromote}
              versionNameToPromote={versionNameToPromote}
              versionEnvironments={versionEnvironments}
              setIsOpen={setPromoting}
              aria-label="promote_content_view_modal"
            />
          }
          {removingFromEnv &&
            <RemoveCVVersionWizard
              cvId={cvId}
              versionIdToRemove={versionIdToRemove}
              versionNameToRemove={versionNameToRemove}
              versionEnvironments={versionEnvironments}
              show={removingFromEnv}
              setIsOpen={setRemovingFromEnv}
              currentStep={currentStep}
              setCurrentStep={setCurrentStep}
              deleteWizard={deleteVersion}
              aria-label="remove_content_view_version_modal"
            />
          }
        </>
      }
    />);
};

ContentViewVersions.propTypes = {
  cvId: PropTypes.number.isRequired,
  details: PropTypes.shape({
    permissions: PropTypes.shape({}),
  }).isRequired,
};

export default ContentViewVersions;
