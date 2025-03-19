import React, { useCallback, useEffect, useRef, useState } from 'react';
import { useHistory, useLocation } from 'react-router-dom';
import { useDispatch, useSelector } from 'react-redux';
import { capitalize, upperCase, omit } from 'lodash';
import { translate as __ } from 'foremanReact/common/I18n';
import { STATUS } from 'foremanReact/constants';
import {
  Button,
  Checkbox,
  Drawer,
  DrawerActions,
  DrawerCloseButton,
  DrawerContent,
  DrawerContentBody,
  DrawerHead,
  DrawerPanelContent,
  DrawerPanelBody,
  Text,
  TextContent,
  TextList,
  TextListItem,
  TextListItemVariants,
  TextListVariants,
  TextVariants,
} from '@patternfly/react-core';
import {
  Dropdown,
  DropdownItem,
  KebabToggle,
} from '@patternfly/react-core/deprecated';
import { TableVariant, Tbody, Td, Th, Thead, Tr, ActionsColumn } from '@patternfly/react-table';
import { useSelectionSet } from 'foremanReact/components/PF4/TableIndexPage/Table/TableHooks';
import { useTableSort } from 'foremanReact/components/PF4/Helpers/useTableSort';

import TableWrapper from '../../../components/Table/TableWrapper';
import {
  selectAlternateContentSources,
  selectAlternateContentSourcesError,
  selectAlternateContentSourcesStatus,
} from '../ACSSelectors';
import getAlternateContentSources, { deleteACS, bulkDeleteACS, getACSDetails, refreshACS, bulkRefreshACS } from '../ACSActions';
import ACSCreateWizard from '../Create/ACSCreateWizard';
import LastSync from '../../ContentViews/Details/Repositories/LastSync';
import ACSExpandableDetails from '../Details/ACSExpandableDetails';
import './ACSTable.scss';
import Loading from '../../../components/Loading';
import EmptyStateMessage from '../../../components/Table/EmptyStateMessage';
import { hasPermission } from '../../ContentViews/helpers';

const ACSTable = () => {
  const response = useSelector(selectAlternateContentSources);
  const status = useSelector(selectAlternateContentSourcesStatus);
  const error = useSelector(selectAlternateContentSourcesError);
  const resolved = status === STATUS.RESOLVED;
  const [searchQuery, updateSearchQuery] = useState('');
  const [isCreateWizardOpen, setIsCreateWizardOpen] = useState(false);
  const dispatch = useDispatch();
  const metadata = omit(response, ['results']);
  const {
    can_create: canCreate = false,
    can_edit: canEdit = false,
    can_delete: canDelete = false,
    can_view: canView = false,
    results,
  } = response;
  const { pathname } = useLocation();
  const { push } = useHistory();
  const [acsId, setAcsId] = useState(pathname.split('/')[2]);
  const [expandedId, setExpandedId] = useState(acsId);
  const [isExpanded, setIsExpanded] = useState(false);
  const drawerRef = useRef(null);
  const [kebabOpen, setKebabOpen] = useState(false);
  const [detailsKebabOpen, setDetailsKebabOpen] = useState(false);
  const [deleting, setDeleting] = useState(false);
  const renderActionButtons = status === STATUS.RESOLVED && !!results?.length;
  const {
    selectOne, isSelected, isSelectable: _isSelectable,
    selectedCount, selectionSet, ...selectionSetVars
  } = useSelectionSet({
    results,
    metadata,
  });

  useEffect(() => {
    if (acsId) {
      dispatch(getACSDetails(acsId));
      setExpandedId(acsId);
      setIsExpanded(true);
    }
  }, [dispatch, acsId]);

  const onExpand = () => drawerRef.current && drawerRef.current.focus();

  const onDelete = (id) => {
    setDeleting(true);
    dispatch(deleteACS(id, () => {
      setDeleting(false);
      if (id?.toString() === acsId?.toString()) {
        push('/alternate_content_sources');
      } else {
        dispatch(getAlternateContentSources());
      }
    }));
  };

  const onRefresh = (id) => {
    dispatch(refreshACS(id, () =>
      dispatch(getAlternateContentSources())));
  };

  const onBulkDelete = (ids) => {
    setDeleting(true);
    dispatch(bulkDeleteACS({ ids }, () => {
      setDeleting(false);
      if (acsId && ids.has(Number(acsId))) {
        push('/alternate_content_sources');
      } else {
        dispatch(getAlternateContentSources());
      }
    }));
  };

  const onBulkRefresh = (ids) => {
    dispatch(bulkRefreshACS({ ids }, () =>
      dispatch(getAlternateContentSources())));
  };

  const createButtonOnclick = () => {
    setIsCreateWizardOpen(true);
  };

  const onCloseClick = () => {
    setExpandedId(null);
    setAcsId(null);
    window.history.replaceState(null, '', '/alternate_content_sources');
    setIsExpanded(false);
  };

  const onClick = (id) => {
    if (Number(id) === Number(expandedId)) {
      onCloseClick();
    } else {
      setExpandedId(id);
      setAcsId(id);
      window.history.replaceState(null, '', `/alternate_content_sources/${id}/details`);
      setIsExpanded(true);
    }
  };

  const isSingleSelected = rowId => (Number(rowId) === Number(acsId) ||
      Number(rowId) === Number(expandedId));
  const customStyle = {
    borderLeft: '5px solid var(--pf-v5-global--primary-color--100)',
  };

  const PanelContent = () => {
    if (!resolved) return <></>;
    const acs = results?.find(source => source?.id === Number(expandedId));
    if (!acs && isExpanded) {
      setExpandedId(null);
      setIsExpanded(false);
    }
    const { last_refresh: lastTask, permissions } = acs ?? {};
    const { last_refresh_words: lastRefreshWords, started_at: startedAt } = lastTask ?? {};
    return (
      <DrawerPanelContent defaultSize="35%">
        <DrawerHead>
          {results && isExpanded &&
          <div ref={drawerRef}>
            <Text ouiaId="acs-name-text" component={TextVariants.h1} style={{ marginTop: '0px', fontWeight: 'bold' }}>
              {acs?.name}
            </Text>
            <TextContent>
              <TextList style={{ marginBottom: '0px' }} component={TextListVariants.dl}>
                <TextListItem component={TextListItemVariants.dt} style={{ fontWeight: 'normal' }}>
                  {__('Last refresh :')}
                </TextListItem>
                <TextListItem
                  aria-label="last_refresh_text_value"
                  component={TextListItemVariants.dd}
                >
                  <LastSync
                    startedAt={startedAt}
                    lastSync={lastTask}
                    lastSyncWords={lastRefreshWords}
                    emptyMessage="N/A"
                  />
                </TextListItem>
              </TextList>
            </TextContent>
          </div>
            }
          {error && <EmptyStateMessage error={error} />}
          <DrawerActions>
            {hasPermission(permissions, 'edit_alternate_content_sources') &&
            <>
              <Button
                ouiaId="refresh-acs"
                onClick={() => onRefresh(acs?.id)}
                variant="secondary"
                size="sm"
                aria-label="refresh_acs"
              >
                {__('Refresh source')}
              </Button>
              <Dropdown
                style={{ paddingRight: '0px' }}
                toggle={<KebabToggle aria-label="details_actions" onToggle={(_event, val) => setDetailsKebabOpen(val)} style={{ paddingRight: '0px' }} />}
                isOpen={detailsKebabOpen}
                ouiaId="acs-details-actions"
                isPlain
                dropdownItems={[
                  <DropdownItem
                    aria-label="details_delete"
                    ouiaId="details_delete"
                    key="details_delete"
                    component="button"
                    onClick={() => {
                      setDetailsKebabOpen(false);
                      onDelete(acs?.id);
                    }}
                  >
                    {__('Delete')}
                  </DropdownItem>]}
              />
            </>
            }
            <DrawerCloseButton onClick={onCloseClick} />
          </DrawerActions>
        </DrawerHead>
        <DrawerPanelBody>
          <ACSExpandableDetails {...{ expandedId }} />
        </DrawerPanelBody>
      </DrawerPanelContent>
    );
  };

  const columnHeaders = [
    __('Name'),
    __('Type'),
    __('Last refresh'),
  ];

  const COLUMNS_TO_SORT_PARAMS = {
    [columnHeaders[0]]: 'name',
    [columnHeaders[1]]: 'alternate_content_source_type',
  };

  const {
    pfSortParams, apiSortParams,
    activeSortColumn, activeSortDirection,
  } = useTableSort({
    allColumns: columnHeaders,
    columnsToSortParams: COLUMNS_TO_SORT_PARAMS,
    initialSortColumnName: 'Name',
  });

  const fetchItems = useCallback(
    params =>
      getAlternateContentSources({
        ...apiSortParams,
        ...params,
      }),
    [apiSortParams],
  );

  const actionsWithPermissions = (acs) => {
    const { id, permissions } = acs;
    const deleteAction = {
      title: __('Delete'),
      ouiaId: `remove-acs-${id}`,
      onClick: () => {
        onDelete(id);
      },
    };
    const refreshAction = {
      title: __('Refresh'),
      ouiaId: `refresh-acs-${id}`,
      onClick: () => {
        onRefresh(id);
      },
    };
    return [
      ...(hasPermission(permissions, 'destroy_alternate_content_sources') ? [deleteAction] : []),
      ...(hasPermission(permissions, 'edit_alternate_content_sources') ? [refreshAction] : []),
    ];
  };

  const primaryActionButton = (
    <Button
      ouiaId="create-acs"
      onClick={createButtonOnclick}
      variant="primary"
      aria-label="create_acs"
    >
      {__('Add source')}
    </Button>
  );

  const emptyContentTitle = __("You currently don't have any alternate content sources.");
  const emptyContentBody = canCreate ? __('An alternate content source can be added by using the "Add source" button below.') : '';
  const emptySearchTitle = __('No matching alternate content sources found');
  const emptySearchBody = __('Try changing your search settings.');
  const showPrimaryAction = canCreate;
  /* eslint-disable react/no-array-index-key */
  if (deleting) {
    return <Loading loadingText={__('Please wait...')} />;
  }
  return (
    <div className="primary-detail-border">
      <Drawer isExpanded={isExpanded} onExpand={onExpand} style={{ minHeight: '80vH' }}>
        <DrawerContent panelContent={<PanelContent />} style={{ minHeight: '80vH' }}>
          <DrawerContentBody>
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
                fetchItems,
                showPrimaryAction,
                primaryActionButton,
                selectedCount,
              }}
              ouiaId="alternate-content-sources-table"
              variant={TableVariant.compact}
              additionalListeners={[activeSortColumn, activeSortDirection]}
              autocompleteEndpoint="/katello/api/v2/alternate_content_sources"
              bookmarkController="katello_alternate_content_sources"
              {...selectionSetVars}
              actionButtons={
                <>
                  {renderActionButtons && canCreate &&
                  <Button
                    ouiaId="create-acs"
                    onClick={createButtonOnclick}
                    variant="primary"
                    aria-label="create_acs"
                  >
                    {__('Add source')}
                  </Button>}
                  {renderActionButtons && (canEdit || canDelete) &&
                  <Dropdown
                    toggle={<KebabToggle aria-label="bulk_actions" onToggle={(_event, val) => setKebabOpen(val)} />}
                    isOpen={kebabOpen}
                    ouiaId="acs-bulk-actions"
                    isPlain
                    dropdownItems={[
                      <DropdownItem
                        aria-label="bulk_refresh"
                        ouiaId="bulk_refresh"
                        key="bulk_refresh"
                        isDisabled={selectedCount < 1 || !canEdit}
                        component="button"
                        onClick={() => {
                          setKebabOpen(false);
                          onBulkRefresh(selectionSet);
                        }}
                      >
                        {__('Refresh')}
                      </DropdownItem>,
                      <DropdownItem
                        aria-label="bulk_delete"
                        ouiaId="bulk_delete"
                        key="bulk_delete"
                        isDisabled={selectedCount < 1 || !canDelete}
                        component="button"
                        onClick={() => {
                          setKebabOpen(false);
                          onBulkDelete(selectionSet);
                        }}
                      >
                        {__('Delete')}
                      </DropdownItem>,
                    ]}
                  />}
                  {isCreateWizardOpen &&
                  <ACSCreateWizard
                    show={isCreateWizardOpen}
                    setIsOpen={setIsCreateWizardOpen}
                  />
                }
                </>
                }
              displaySelectAllCheckbox={renderActionButtons}
              hideSearch={!canView}
            >
              <Thead>
                <Tr ouiaId="acs-table-column-headers-row">
                  <Th
                    key="acs-checkbox"
                    style={{ width: 0 }}
                  />
                  {columnHeaders.map(col => (
                    <Th
                      key={col}
                      sort={COLUMNS_TO_SORT_PARAMS[col] ? pfSortParams(col) : undefined}
                    >
                      {col}
                    </Th>
                  ))}
                </Tr>
              </Thead>
              <Tbody>
                {results?.map((acs, index) => {
                  const {
                    name,
                    id,
                    alternate_content_source_type: acsType,
                    last_refresh: lastTask,
                    permissions,
                  } = acs;
                  const {
                    last_refresh_words: lastRefreshWords,
                    started_at: startedAt,
                  } = lastTask ?? {};
                  return (
                    <Tr
                      key={index}
                      ouiaId={`acs-row-${id}`}
                      style={isSingleSelected(id) && isExpanded ? customStyle : {}}
                      isStriped={isSingleSelected(id) && isExpanded}
                    >
                      <Td>
                        <Checkbox
                          ouiaId={`select-acs-${id}`}
                          id={id}
                          aria-label={`Select ACS ${id}`}
                          isChecked={isSelected(id)}
                          onChange={(_event, selected) => selectOne(selected, id)}
                        />
                      </Td>
                      <Td>
                        <Text onClick={() => onClick(id)} component="a" ouiaId={`acs-link-text-${index}`}>{name}</Text>
                      </Td>
                      <Td>{acsType === 'rhui' ? upperCase(acsType) : capitalize(acsType)}</Td>
                      <Td><LastSync
                        startedAt={startedAt}
                        lastSync={lastTask}
                        lastSyncWords={lastRefreshWords}
                        emptyMessage="N/A"
                      />
                      </Td>
                      {(hasPermission(permissions, 'destroy_alternate_content_sources') ||
                        hasPermission(permissions, 'edit_alternate_content_sources')) ?
                          <Td isActionCell>
                            <ActionsColumn items={actionsWithPermissions(acs)} />
                          </Td> :
                          <Td />
                    }
                    </Tr>
                  );
                })
                }
              </Tbody>
            </TableWrapper>
          </DrawerContentBody>
        </DrawerContent>
      </Drawer>
    </div>
  );
  /* eslint-enable react/no-array-index-key */
};

export default ACSTable;

