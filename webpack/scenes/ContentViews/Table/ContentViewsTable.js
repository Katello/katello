import React, { useState, useCallback } from 'react';
import { useSelector, useDispatch } from 'react-redux';
import { Link } from 'react-router-dom';
import { omit } from 'lodash';
import { translate as __ } from 'foremanReact/common/I18n';
import LongDateTime from 'foremanReact/components/common/dates/LongDateTime';
import { Button } from '@patternfly/react-core';
import { TableVariant, Thead, Tbody, Th, Tr, Td, ExpandableRowContent } from '@patternfly/react-table';
import TableWrapper from '../../../components/Table/TableWrapper';
import getContentViews from '../ContentViewsActions';
import CreateContentViewModal from '../Create/CreateContentViewModal';
import CopyContentViewModal from '../Copy/CopyContentViewModal';
import PublishContentViewWizard from '../Publish/PublishContentViewWizard';
import { selectContentViews, selectContentViewStatus, selectContentViewError } from '../ContentViewSelectors';
import ContentViewVersionPromote from '../Details/Promote/ContentViewVersionPromote';
import getEnvironmentPaths from '../components/EnvironmentPaths/EnvironmentPathActions';
import { hasPermission } from '../helpers';
import { useSet, useTableSort } from '../../../components/Table/TableHooks';
import ContentViewIcon from '../components/ContentViewIcon';
import { urlBuilder } from '../../../__mocks__/foremanReact/common/urlHelpers';
import LastSync from '../Details/Repositories/LastSync';
import InactiveText from '../components/InactiveText';
import ContentViewVersionCell from './ContentViewVersionCell';
import DetailsExpansion from '../expansions/DetailsExpansion';
import ContentViewDeleteWizard from '../Delete/ContentViewDeleteWizard';

const ContentViewTable = () => {
  const response = useSelector(selectContentViews);
  const status = useSelector(selectContentViewStatus);
  const error = useSelector(selectContentViewError);
  const [searchQuery, updateSearchQuery] = useState('');
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [copy, setCopy] = useState(false);
  const expandedTableRows = useSet([]);
  const tableRowIsExpanded = id => expandedTableRows.has(id);
  const [isPublishModalOpen, setIsPublishModalOpen] = useState(false);
  const [isPromoteModalOpen, setIsPromoteModalOpen] = useState(false);
  const [isDeleteModalOpen, setIsDeleteModalOpen] = useState(false);
  const [actionableCvDetails, setActionableCvDetails] = useState({});
  const [actionableCvId, setActionableCvId] = useState('');
  const [actionableCvName, setActionableCvName] = useState('');
  const dispatch = useDispatch();
  const metadata = omit(response, ['results']);
  const { can_create: canCreate = false, results } = response;
  const columnHeaders = [
    __('Type'),
    __('Name'),
    __('Last published'),
    __('Last task'),
    __('Latest version'),
  ];
  const COLUMNS_TO_SORT_PARAMS = {
    [columnHeaders[1]]: 'name',
  };
  const {
    pfSortParams, apiSortParams,
    activeSortColumn, activeSortDirection,
  } = useTableSort({
    allColumns: columnHeaders,
    columnsToSortParams: COLUMNS_TO_SORT_PARAMS,
    initialSortColumnName: 'Name',
  });

  const openForm = () => setIsModalOpen(true);

  const openPublishModal = (cvInfo) => {
    setActionableCvDetails(cvInfo);
    setIsPublishModalOpen(true);
  };

  const openPromoteModal = (cvInfo) => {
    dispatch(getEnvironmentPaths());
    setActionableCvDetails(cvInfo);
    setIsPromoteModalOpen(true);
  };

  const openDeleteModal = (cvInfo) => {
    setActionableCvDetails(cvInfo);
    setIsDeleteModalOpen(true);
  };

  const actionsWithPermissions = (cvInfo) => {
    const { version_count: cvVersionCount, generated_for: generatedFor, permissions } = cvInfo;

    const publishAction = {
      title: __('Publish'),
      isDisabled: generatedFor !== 'none',
      onClick: () => openPublishModal(cvInfo),
    };

    const promoteAction = {
      title: __('Promote'),
      isDisabled: !cvVersionCount,
      onClick: () => openPromoteModal(cvInfo),
    };

    const copyAction = {
      title: __('Copy'),
      onClick: () => {
        setCopy(true);
        setActionableCvId(cvInfo.id.toString());
        setActionableCvName(cvInfo.name);
      },
    };

    const deleteAction = {
      title: __('Delete'),
      onClick: () => openDeleteModal(cvInfo),
    };

    return [
      ...(hasPermission(permissions, 'publish_content_views') ? [publishAction] : []),
      ...(hasPermission(permissions, 'promote_or_remove_content_views') ? [promoteAction] : []),
      ...(canCreate ? [copyAction] : []),
      ...(hasPermission(permissions, 'destroy_content_views') ? [deleteAction] : []),
    ];
  };

  const fetchItems = useCallback(
    params =>
      getContentViews({
        ...apiSortParams,
        ...params,
      }),
    [apiSortParams],
  );

  const emptyContentTitle = __("You currently don't have any Content views.");
  const emptyContentBody = __('A content view can be added by using the "Create content view" button below.');
  const emptySearchTitle = __('No matching content views found');
  const emptySearchBody = __('Try changing your search settings.');
  const showPrimaryAction = true;
  const {
    id,
    latest_version_id: latestVersionId,
    latest_version: latestVersionName,
    latest_version_environments: latestVersionEnvironments,
    environments,
    versions,
  } = actionableCvDetails;
  return (
    <TableWrapper
      {...{
        error,
        metadata,
        emptyContentTitle,
        emptyContentBody,
        emptySearchTitle,
        emptySearchBody,
        searchQuery,
        updateSearchQuery,
        fetchItems,
        showPrimaryAction,
      }}
      ouiaId="content-views-table"
      additionalListeners={[activeSortColumn, activeSortDirection]}
      bookmarkController="katello_content_views"
      variant={TableVariant.compact}
      status={status}
      autocompleteEndpoint="/content_views/auto_complete_search"
      primaryActionButton={canCreate ? (
        <Button
          ouiaId="create-content-view"
          onClick={openForm}
          variant="primary"
          aria-label="create_content_view"
        > {__('Create content view')}
        </Button >) : undefined}
      actionButtons={
        <>
          {results?.length !== 0 &&
            <Button ouiaId="create-content-view" onClick={openForm} variant="primary" aria-label="create_content_view">
              {__('Create content view')}
            </Button>
          }
          <CreateContentViewModal show={isModalOpen} setIsOpen={setIsModalOpen} aria-label="create_content_view_modal" />
          <CopyContentViewModal cvId={actionableCvId} cvName={actionableCvName} show={copy} setIsOpen={setCopy} aria-label="copy_content_view_modal" />
          {
            isPublishModalOpen &&
            <PublishContentViewWizard
              details={actionableCvDetails}
              show={isPublishModalOpen}
              onClose={(makeCallback) => {
                if (makeCallback) {
                  dispatch(getContentViews(apiSortParams));
                }
                setIsPublishModalOpen(false);
              }}
              aria-label="publish_content_view_modal"
            />
          }
          {
            isPromoteModalOpen &&
            <ContentViewVersionPromote
              cvId={id && Number(id)}
              versionIdToPromote={latestVersionId}
              versionNameToPromote={latestVersionName}
              versionEnvironments={latestVersionEnvironments}
              setIsOpen={setIsPromoteModalOpen}
            />
          }
          {
            isDeleteModalOpen &&
            <ContentViewDeleteWizard
              cvId={id && Number(id)}
              cvEnvironments={environments}
              cvVersions={versions}
              show={isDeleteModalOpen}
              setIsOpen={setIsDeleteModalOpen}
              aria-label="delete_content_view_modal"
            />
          }
        </>
      }
    >
      <Thead>
        <Tr>
          <Th key="expand-carat" />
          {columnHeaders.map(col => (
            <Th
              key={col}
              sort={COLUMNS_TO_SORT_PARAMS[col] ? pfSortParams(col) : undefined}
            >
              {col}
            </Th>
          ))}
          <Th key="action-menu" />
        </Tr>
      </Thead>
      {
        results?.map((cvInfo, rowIndex) => {
          const {
            composite,
            name,
            id: cvId,
            last_published: lastPublished,
            latest_version: latestVersion,
            latest_version_id: cvLatestVersionId,
            latest_version_environments: cvLatestVersionEnvironments,
            last_task: lastTask,
            activation_keys: activationKeys,
            hosts,
            related_cv_count: relatedCVCount,
            related_composite_cvs: relatedCompositeCVs,
            description,
            createdAt,
          } = cvInfo;
          const { last_sync_words: lastSyncWords, started_at: startedAt } = lastTask ?? {};
          const isExpanded = tableRowIsExpanded(cvId);
          return (
            <Tbody isExpanded={isExpanded} key={`${cvId}_${createdAt}`}>
              <Tr key={cvId}>
                <Td
                  expand={{
                    rowIndex,
                    isExpanded,
                    onToggle: (_event, _rInx, isOpen) =>
                      expandedTableRows.onToggle(isOpen, cvId),
                  }}
                />
                <Td><ContentViewIcon position="right" composite={composite} /></Td>
                <Td><Link to={`${urlBuilder('content_views', '')}${cvId}`}>{name}</Link></Td>
                <Td>{lastPublished ? <LongDateTime date={lastPublished} showRelativeTimeTooltip /> : <InactiveText text={__('Not yet published')} />}</Td>
                <Td><LastSync startedAt={startedAt} lastSync={lastTask} lastSyncWords={lastSyncWords} emptyMessage="N/A" /></Td>
                <Td>{latestVersion ?
                  <ContentViewVersionCell {...{
                    id: cvId,
                    latestVersion,
                    latestVersionId: cvLatestVersionId,
                    latestVersionEnvironments: cvLatestVersionEnvironments,
                  }}
                  /> :
                  <InactiveText style={{ marginTop: '0.5em', marginBottom: '0.5em' }} text={__('Not yet published')} />}
                </Td>
                <Td
                  key={`rowActions-${id}`}
                  actions={{
                    items: actionsWithPermissions(cvInfo),
                  }}
                />
              </Tr>
              <Tr key="child_row" isExpanded={isExpanded}>
                <Td colSpan={2}>
                  <ExpandableRowContent>
                    <DetailsExpansion
                      cvId={cvId}
                      cvName={name}
                      cvComposite={composite}
                      {...{
                        activationKeys, hosts, relatedCVCount, relatedCompositeCVs,
                      }}
                    />
                  </ExpandableRowContent>
                </Td>
                <Td colSpan={4}>
                  <ExpandableRowContent>
                    {description || <InactiveText text={__('No description')} />}
                  </ExpandableRowContent>
                </Td>
              </Tr>
            </Tbody>
          );
        })
      }
    </TableWrapper >
  );
};

export default ContentViewTable;
