import React, { useState, useEffect, useCallback } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { TableVariant, TableText, Tbody, Thead, Td, Tr, Th } from '@patternfly/react-table';
import { Checkbox, Dropdown, DropdownItem, Grid, KebabToggle } from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import { STATUS } from 'foremanReact/constants';
import { Link } from 'react-router-dom';
import PropTypes from 'prop-types';
import { first } from 'lodash';
import { selectIntervals } from 'foremanReact/redux/middlewares/IntervalMiddleware/IntervalSelectors.js';
import { useSelectionSet } from '../../../../components/Table/TableHooks';
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
import { startPollingTask, stopPollingTask } from '../../../Tasks/TaskActions';
import RemoveCVVersionWizard from './Delete/RemoveCVVersionWizard';
import { hasPermission } from '../../helpers';
import { pollTaskKey } from '../../../Tasks/helpers';
import BulkDeleteModal from './BulkDelete/BulkDeleteModal';


const ContentViewVersions = ({ cvId, details }) => {
  const response = useSelector(state => selectCVVersions(state, cvId));
  const { results, ...metadata } = response;
  const status = useSelector(state => selectCVVersionsStatus(state, cvId));
  const error = useSelector(state => selectCVVersionsError(state, cvId));
  const [pollingFinished, setPollingFinished] = useState(false);
  const dispatch = useDispatch();
  const [searchQuery, updateSearchQuery] = useState('');
  const [versionIdToPromote, setVersionIdToPromote] = useState('');
  const [versionNameToPromote, setVersionNameToPromote] = useState('');
  const [versionIdToRemove, setVersionIdToRemove] = useState('');
  const [versionNameToRemove, setVersionNameToRemove] = useState('');
  const [versionEnvironments, setVersionEnvironments] = useState([]);
  const [bulkDeleteModalOpen, setBulkDeleteModalOpen] = useState(false);
  const [promoting, setPromoting] = useState(false);
  const [removingFromEnv, setRemovingFromEnv] = useState(false);
  const [deleteVersion, setDeleteVersion] = useState(false);
  const [currentStep, setCurrentStep] = useState(1);
  const { permissions } = details;
  const [currentTask, setCurrentTask] = useState(null);
  const [kebabOpen, setKebabOpen] = useState(false);
  const intervals = useSelector(state => selectIntervals(state));
  const hasActionPermissions = hasPermission(permissions, 'promote_or_remove_content_views');
  const renderActionButtons =
    hasActionPermissions && status === STATUS.RESOLVED && !!results?.length;
  const {
    selectOne, isSelected, isSelectable: _isSelectable,
    selectedCount, selectionSet, ...selectionSetVars
  } = useSelectionSet({
    results,
    metadata,
  });

  const columnHeaders = [
    '',
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

  useEffect(() => {
    if (currentTask) {
      dispatch(startPollingTask(
        currentTask.id, currentTask,
        ({ data: { result, pending, progress } = {} }) => {
          if (result !== 'pending' &&
            !pending && progress === 1) {
            dispatch(stopPollingTask(currentTask.id));
            // This is what is getting called 5 times
          }
        },
      ));
    }
    return () => { setCurrentTask(null); };
  }, [currentTask, dispatch, pollingFinished]);


  useEffect(() => {
    if (pollingFinished) {
      setPollingFinished(false);
      setCurrentTask(null);
      dispatch(getContentViewVersions(cvId));
      // For some reason this needs to finish for the above to stop being called.
    }
  }, [cvId, dispatch, pollingFinished]);

  const buildCells = (cvVersion) => {
    const {
      version,
      description,
      id: versionId,
      environments,
      rpm_count: packageCount,
      errata_counts: errataCounts,
    } = cvVersion;
    return [
      <Checkbox
        id={versionId}
        isChecked={isSelected(versionId)}
        onChange={selected =>
          selectOne(selected, versionId)
        }
      />,
      <Link to={`/versions/${versionId}`}>{__('Version ')}{version}</Link>,
      <ContentViewVersionEnvironments {...{ environments }} />,
      Number(packageCount) ?
        <a href={urlBuilder(`content_views/${cvId}#/versions/${versionId}/packages`, '')}>{packageCount}</a> :
        <InactiveText text={__('No packages')} />,
      <ContentViewVersionErrata {...{ cvId, versionId, errataCounts }} />,
      <ContentViewVersionContent {...{ cvId, versionId, cvVersion }} />,
      description ? <TableText wrapModifier="truncate">{description}</TableText> : <InactiveText text={__('No description')} />,
    ];
  };

  const buildActiveTaskCells = (cvVersion, pollIntervals) => {
    const {
      version,
      description,
      id: versionId,
      active_history: activeHistory,
    } = cvVersion;
    const [{ task }] = activeHistory;
    const { result } = task || {};

    if (!currentTask && result !== 'error' && !pollIntervals[pollTaskKey(task.id)]) {
      setCurrentTask(task);
    }

    return [
      '',
      <Link disabled to={`/versions/${versionId}`}>{__('Version ')}{version}</Link>,
      <TaskPresenter
        activeHistory={first(activeHistory)}
        setPollingFinished={setPollingFinished}
      />,
      '',
      '',
      '',
      description ? <TableText wrapModifier="truncate">{description}</TableText> : <InactiveText text={__('No description')} />,
    ];
  };


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

  const rowDropdownItems = ({
    version,
    id: versionId,
    environments,
  }) =>
    [
      {
        title: __('Promote'),
        onClick: () => {
          onPromote({
            cvVersionId: versionId,
            cvVersionName: version,
            cvVersionEnvironments: environments,
          });
        },
      },
      {
        title: __('Remove from environments'),
        onClick: () => {
          onRemoveFromEnv({
            cvVersionId: versionId,
            cvVersionName: version,
            cvVersionEnvironments: environments,
            deleting: false,
          });
        },
      },
      {
        title: __('Delete'),
        onClick: () => {
          selectionSet.clear();
          selectOne(true, versionId);
          setPollingFinished(false);
          setBulkDeleteModalOpen(true);
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
        metadata,
        emptyContentTitle,
        emptyContentBody,
        emptySearchTitle,
        emptySearchBody,
        searchQuery,
        updateSearchQuery,
        error,
        status,
        selectedCount,
      }}
      variant={TableVariant.compact}
      autocompleteEndpoint={`/content_view_versions/auto_complete_search?content_view_id=${cvId}`}
      fetchItems={useCallback((params) => {
        selectionSet.clear();
        return getContentViewVersions(cvId, params);
        // eslint-disable-next-line react-hooks/exhaustive-deps
      }, [cvId])}
      {...hasActionPermissions ? selectionSetVars : []}
      actionButtons={
        renderActionButtons && (
          <Grid>
            <Dropdown
              toggle={<KebabToggle aria-label="bulk_actions" onToggle={setKebabOpen} />}
              isOpen={kebabOpen}
              isPlain
              dropdownItems={[
                <DropdownItem
                  aria-label="bulk_delete"
                  key="bulk_delete"
                  isDisabled={selectedCount < 1}
                  component="button"
                  onClick={() => {
                    setPollingFinished(false);
                    setKebabOpen(false);
                    setBulkDeleteModalOpen(true);
                  }}
                >
                  {__('Delete')}
                </DropdownItem>]}
            />
          </Grid>
        )}
      displaySelectAllCheckbox={hasActionPermissions}
    >
      <Thead>
        {bulkDeleteModalOpen &&
          <BulkDeleteModal
            versions={results?.filter(({ id }) => selectionSet.has(id))}
            onClose={() => {
              selectionSet.clear();
              setBulkDeleteModalOpen(false);
            }}
          />
        }
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
        <Tr key="version-header">
          {columnHeaders.map((title, index) => {
            if (index === 0 && !hasActionPermissions) return undefined;
            return <Th key={`col-header-${title}`}>{title}</Th>;
          })}
        </Tr>
      </Thead>
      <Tbody>
        {results?.map((cvVersion) => {
          const hasHistory = !!cvVersion?.active_history?.length;
          const cells = hasHistory ?
            buildActiveTaskCells(cvVersion, intervals) :
            buildCells(cvVersion);
          return (
            <Tr key={`column-${cvVersion.id}`}>
              {cells.map((cell, index) => {
                if (index === 0 && !hasActionPermissions) return undefined;
                return (
                  <Td
                    key={`cell-${index + 1}`}
                    style={index === 0 ? { padding: '0px 16px', width: '45px' } : undefined}
                  >
                    {cell}
                  </Td>);
              })}
              {(!hasHistory && hasActionPermissions) &&
                <Td
                  actions={{
                    items: rowDropdownItems(cvVersion),
                  }}
                />}
            </Tr>);
        })}
      </Tbody>
    </TableWrapper >);
};

ContentViewVersions.propTypes = {
  cvId: PropTypes.number.isRequired,
  details: PropTypes.shape({
    permissions: PropTypes.shape({}),
  }).isRequired,
};

export default ContentViewVersions;
