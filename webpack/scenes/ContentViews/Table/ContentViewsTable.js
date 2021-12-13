import React, { useState, useCallback } from 'react';
import useDeepCompareEffect from 'use-deep-compare-effect';
import { useSelector, useDispatch } from 'react-redux';
import { omit, upperCase } from 'lodash';
import { translate as __ } from 'foremanReact/common/I18n';
import { STATUS } from 'foremanReact/constants';
import { Button } from '@patternfly/react-core';
import { TableVariant } from '@patternfly/react-table';
import TableWrapper from '../../../components/Table/TableWrapper';
import tableDataGenerator from './tableDataGenerator';
import getContentViews from '../ContentViewsActions';
import CreateContentViewModal from '../Create/CreateContentViewModal';
import CopyContentViewModal from '../Copy/CopyContentViewModal';
import PublishContentViewWizard from '../Publish/PublishContentViewWizard';
import { selectContentViews, selectContentViewStatus, selectContentViewError } from '../ContentViewSelectors';
import ContentViewVersionPromote from '../Details/Promote/ContentViewVersionPromote';
import getEnvironmentPaths from '../components/EnvironmentPaths/EnvironmentPathActions';
import ContentViewDeleteWizard from '../Delete/ContentViewDeleteWizard';
import getContentViewDetails, { getContentViewVersions } from '../Details/ContentViewDetailActions';
import { hasPermission } from '../helpers';

const ContentViewTable = () => {
  const response = useSelector(selectContentViews);
  const status = useSelector(selectContentViewStatus);
  const error = useSelector(selectContentViewError);
  const [table, setTable] = useState({ rows: [], columns: [] });
  const [sortBy, setSortBy] = useState({});
  const [rowMappingIds, setRowMappingIds] = useState([]);
  const [searchQuery, updateSearchQuery] = useState('');
  const loadingResponse = status === STATUS.PENDING;
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [copy, setCopy] = useState(false);
  const [cvResults, setCvResults] = useState([]);
  const [cvTableStatus, setCvTableStatus] = useState(STATUS.PENDING);
  const [isPublishModalOpen, setIsPublishModalOpen] = useState(false);
  const [isPromoteModalOpen, setIsPromoteModalOpen] = useState(false);
  const [isDeleteModalOpen, setIsDeleteModalOpen] = useState(false);
  const [actionableCvDetails, setActionableCvDetails] = useState({});
  const [actionableCvId, setActionableCvId] = useState('');
  const [actionableCvName, setActionableCvName] = useState('');
  const [currentStep, setCurrentStep] = useState(1);
  const dispatch = useDispatch();
  const metadata = omit(response, ['results']);
  const { can_create: canCreate = false } = response;

  const openForm = () => setIsModalOpen(true);

  const openPublishModal = (rowInfo) => {
    setActionableCvDetails({
      id: rowInfo.cvId.toString(),
      name: rowInfo.cvName,
      composite: rowInfo.cvComposite,
      version_count: rowInfo.cvVersionCount,
      next_version: rowInfo.cvNextVersion,
    });
    setIsPublishModalOpen(true);
  };

  const openPromoteModal = (rowInfo) => {
    dispatch(getEnvironmentPaths());
    setActionableCvDetails({
      id: rowInfo.cvId.toString(),
      latestVersionId: rowInfo.latestVersionId,
      latestVersionEnvironments: rowInfo.latestVersionEnvironments,
      latestVersionName: rowInfo.latestVersionName,
    });
    setIsPromoteModalOpen(true);
  };

  const openDeleteModal = (rowInfo) => {
    dispatch(getContentViewDetails(rowInfo.cvId));
    dispatch(getContentViewVersions(rowInfo.cvId));
    setActionableCvDetails({
      id: rowInfo.cvId.toString(),
      name: rowInfo.cvName,
      environments: rowInfo.environments,
      versions: rowInfo.versions,
    });
    setIsDeleteModalOpen(true);
  };

  useDeepCompareEffect(
    () => {
      // Prevents flash of "No Content" before rows are loaded
      const tableStatus = () => {
        if (typeof cvResults === 'undefined' || status === STATUS.ERROR) return status; // will handle errored state
        const resultsIds = Array.from(cvResults.map(result => result.id));
        // All results are accounted for in row mapping, the page is ready to load
        if (resultsIds.length === rowMappingIds.length &&
          resultsIds.every(id => rowMappingIds.includes(id))) {
          return status;
        }
        return STATUS.PENDING; // Fallback to pending
      };

      const { results } = response;
      if (status === STATUS.ERROR) {
        setCvTableStatus(tableStatus());
      }
      if (!loadingResponse && results) {
        setCvResults(results);
        setCurrentStep(1);
        const { newRowMappingIds, ...tableData } = tableDataGenerator(results);
        setTable(tableData);
        setRowMappingIds(newRowMappingIds);
        setCvTableStatus(tableStatus());
      }
      return () => {
        // This sets the loading state so that the table doesn't flicker on return
        setCvTableStatus(STATUS.PENDING);
      };
    },
    [response, status, loadingResponse, setTable, setRowMappingIds,
      setCvResults, setCvTableStatus, setCurrentStep, cvResults, rowMappingIds],
  );

  const onCollapse = (_event, rowId, isOpen) => {
    let rows;
    if (rowId === -1) {
      rows = table.rows.map(row => ({ ...row, isOpen }));
    } else {
      rows = [...table.rows];
      rows[rowId].isOpen = isOpen;
    }

    setTable(prevTable => ({ ...prevTable, rows }));
  };

  const actionResolver = (rowData, { _rowIndex }) => {
    // don't show actions for the expanded parts
    if (rowData.parent !== undefined || rowData.compoundParent || rowData.noactions) return null;
    const publishAction = {
      title: __('Publish'),
      onClick: (_event, _rowId, rowInfo) => {
        openPublishModal(rowInfo);
      },
    };

    const promoteAction = {
      title: __('Promote'),
      isDisabled: !rowData.cvVersionCount,
      onClick: (_event, _rowId, rowInfo) => openPromoteModal(rowInfo),
    };

    const copyAction = {
      title: __('Copy'),
      onClick: (_event, _rowId, rowInfo) => {
        setCopy(true);
        setActionableCvId(rowInfo.cvId.toString());
        setActionableCvName(rowInfo.cvName);
      },
    };

    const deleteAction = {
      title: __('Delete'),
      onClick: (_event, _rowId, rowInfo) => openDeleteModal(rowInfo),
    };

    return [
      ...(hasPermission(rowData.permissions, 'publish_content_views') ? [publishAction] : []),
      ...(hasPermission(rowData.permissions, 'promote_or_remove_content_views') ? [promoteAction] : []),
      ...(canCreate ? [copyAction] : []),
      ...(hasPermission(rowData.permissions, 'destroy_content_views') ? [deleteAction] : []),
    ];
  };

  const indexToSortVariable = (key) => {
    switch (key) {
      case 2:
        return 'name';
      default:
        return undefined;
    }
  };

  const onSort = (_event, index, direction) => {
    setCvTableStatus(STATUS.PENDING);
    setSortBy({ index, direction });
  };

  const { index: sortByIndex, direction } = sortBy;
  const fetchItems = useCallback(
    params =>
      getContentViews({
        ...params,
        ...sortByIndex ? {
          sort_by: indexToSortVariable(sortByIndex),
          sort_order: upperCase(direction),
        } : {},
      }),
    [sortByIndex, direction],
  );

  const emptyContentTitle = __("You currently don't have any Content views.");
  const emptyContentBody = __('A content view can be added by using the "Create content view" button above.');
  const emptySearchTitle = __('No matching content views found');
  const emptySearchBody = __('Try changing your search settings.');
  const {
    id,
    latestVersionId,
    latestVersionName,
    latestVersionEnvironments,
    environments,
    versions,
  } = actionableCvDetails;

  const { rows, columns } = table;
  return (
    <TableWrapper
      {...{
        rows,
        error,
        metadata,
        emptyContentTitle,
        emptyContentBody,
        emptySearchTitle,
        emptySearchBody,
        actionResolver,
        searchQuery,
        updateSearchQuery,
        fetchItems,
      }}
      additionalListeners={[isPublishModalOpen, sortByIndex, direction]}
      sortBy={sortBy}
      onSort={onSort}
      bookmarkController="katello_content_views"
      variant={TableVariant.compact}
      status={cvTableStatus}
      onCollapse={onCollapse}
      canSelectAll={false}
      cells={columns}
      autocompleteEndpoint="/content_views/auto_complete_search"
      actionButtons={
        <>
          {canCreate &&
            <Button onClick={openForm} variant="primary" aria-label="create_content_view">
              {__('Create content view')}
            </Button>
          }
          <CreateContentViewModal show={isModalOpen} setIsOpen={setIsModalOpen} aria-label="create_content_view_modal" />
          <CopyContentViewModal cvId={actionableCvId} cvName={actionableCvName} show={copy} setIsOpen={setCopy} aria-label="copy_content_view_modal" />
          {isPublishModalOpen &&
            <PublishContentViewWizard
              details={actionableCvDetails}
              show={isPublishModalOpen}
              setIsOpen={setIsPublishModalOpen}
              currentStep={currentStep}
              setCurrentStep={setCurrentStep}
              aria-label="publish_content_view_modal"
            />
          }
          {isPromoteModalOpen &&
            <ContentViewVersionPromote
              cvId={id && Number(id)}
              versionIdToPromote={latestVersionId}
              versionNameToPromote={latestVersionName}
              versionEnvironments={latestVersionEnvironments}
              setIsOpen={setIsPromoteModalOpen}
            />
          }
          {isDeleteModalOpen && <ContentViewDeleteWizard
            cvId={id && Number(id)}
            cvEnvironments={environments}
            cvVersions={versions}
            show={isDeleteModalOpen}
            setIsOpen={setIsDeleteModalOpen}
            currentStep={currentStep}
            setCurrentStep={setCurrentStep}
            aria-label="delete_content_view_modal"
          />}
        </>
      }
    />
  );
};

export default ContentViewTable;
