import React, { useState, useCallback, useRef, useEffect } from 'react';
import { useHistory, useLocation } from 'react-router-dom';
import { useSelector, useDispatch } from 'react-redux';
import { translate as __ } from 'foremanReact/common/I18n';
import { STATUS } from 'foremanReact/constants';
import { Button,
  Drawer,
  DrawerPanelContent,
  DrawerContent,
  DrawerContentBody,
  DrawerHead,
  DrawerActions,
  DrawerCloseButton,
  TextContent,
  Text,
  TextVariants,
  TextList,
  TextListItem,
  TextListVariants,
  TextListItemVariants } from '@patternfly/react-core';
import { TableVariant, Thead, Tbody, Tr, Th, Td } from '@patternfly/react-table';
import TableWrapper from '../../../components/Table/TableWrapper';
import {
  selectAlternateContentSources, selectAlternateContentSourcesError,
  selectAlternateContentSourcesStatus,
} from '../ACSSelectors';
import { useTableSort } from '../../../components/Table/TableHooks';
import getAlternateContentSources, { deleteACS, getACSDetails, refreshACS } from '../ACSActions';
import ACSCreateWizard from '../Create/ACSCreateWizard';
import LastSync from '../../ContentViews/Details/Repositories/LastSync';
import ACSExpandableDetails from '../Details/ACSExpandableDetails';
import './ACSTable.scss';

const ACSTable = () => {
  const response = useSelector(selectAlternateContentSources);
  const status = useSelector(selectAlternateContentSourcesStatus);
  const error = useSelector(selectAlternateContentSourcesError);
  const resolved = status === STATUS.RESOLVED;
  const [searchQuery, updateSearchQuery] = useState('');
  const [isCreateWizardOpen, setIsCreateWizardOpen] = useState(false);
  const dispatch = useDispatch();
  const { results, ...metadata } = response;
  const { pathname } = useLocation();
  const { push } = useHistory();
  const acsId = pathname.split('/')[3];
  const [expandedId, setExpandedId] = useState(acsId);
  const [isExpanded, setIsExpanded] = useState(false);
  const drawerRef = useRef(null);

  useEffect(() => {
    if (acsId) {
      dispatch(getACSDetails(acsId));
      setIsExpanded(true);
    }
  }, [dispatch, acsId]);

  const onExpand = () => {
    if (drawerRef.current) drawerRef.current.focus();
  };

  const onDelete = (id) => {
    dispatch(deleteACS(id, () =>
      dispatch(getAlternateContentSources())));
  };

  const onRefresh = (id) => {
    dispatch(refreshACS(id, () =>
      dispatch(getAlternateContentSources())));
  };

  const createButtonOnclick = () => {
    setIsCreateWizardOpen(true);
  };

  const onClick = (id) => {
    setExpandedId(id);
  };

  const onCloseClick = () => {
    setExpandedId(null);
    push('/labs/alternate_content_sources');
    setIsExpanded(false);
  };

  const PanelContent = () => {
    if (!resolved) return <></>;
    const acs = results?.find(source => source?.id === Number(expandedId));
    const { last_refresh: lastTask } = acs ?? {};
    const { last_refresh_words: lastRefreshWords, started_at: startedAt } = lastTask ?? {};
    return (
      <DrawerPanelContent defaultSize="50%">
        <DrawerHead>
          {results && isExpanded &&
          <span ref={drawerRef}>
            <TextContent>
              <Text component={TextVariants.h1}>
                {acs?.name}
              </Text>
              <TextList component={TextListVariants.dl}>
                <TextListItem component={TextListItemVariants.dt}>
                  {__('Last refresh :')}
                </TextListItem>
                <TextListItem
                  aria-label="name_text_value"
                  component={TextListItemVariants.dd}
                >
                  <LastSync startedAt={startedAt} lastSync={lastTask} lastSyncWords={lastRefreshWords} emptyMessage="N/A" />
                </TextListItem>
              </TextList>
            </TextContent>
            <ACSExpandableDetails />
          </span>}
          <DrawerActions>
            <Button ouiaId="refresh-acs" onClick={() => onRefresh(acs?.id)} variant="secondary" aria-label="refresh_acs">
              {__('Refresh source')}
            </Button>
            <DrawerCloseButton onClick={onCloseClick} />
          </DrawerActions>
        </DrawerHead>
      </DrawerPanelContent>
    );
  };

  const columnHeaders = [
    __('Name'),
    __('Type'),
    __('Last Refresh'),
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

  const rowDropdownItems = ({ id }) => [
    {
      title: __('Delete'),
      ouiaId: `remove-acs-${id}`,
      onClick: () => {
        onDelete(id);
      },
    },
    {
      title: __('Refresh'),
      ouiaId: `remove-acs-${id}`,
      onClick: () => {
        onRefresh(id);
      },
    },
  ];

  const emptyContentTitle = __("You currently don't have any alternate content sources.");
  const emptyContentBody = __('An alternate content source can be added by using the "Add source" button above.');
  const emptySearchTitle = __('No matching alternate content sources found');
  const emptySearchBody = __('Try changing your search settings.');
  /* eslint-disable react/no-array-index-key */

  return (
    <Drawer isExpanded={isExpanded} isInline onExpand={onExpand}>
      <DrawerContent panelContent={<PanelContent />}>
        <DrawerContentBody style={{ paddingBottom: '5%' }}>
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
            }}
            ouiaId="alternate-content-sources-table"
            variant={TableVariant.compact}
            additionalListeners={[activeSortColumn, activeSortDirection]}
            autocompleteEndpoint="/alternate_content_sources/auto_complete_search"
            actionButtons={
              <>
                <Button ouiaId="create-acs" onClick={createButtonOnclick} variant="primary" aria-label="create_acs">
                  {__('Add source')}
                </Button>
                {isCreateWizardOpen &&
                <ACSCreateWizard
                  show={isCreateWizardOpen}
                  setIsOpen={setIsCreateWizardOpen}
                />
                }
              </>
            }
          >
            <Thead>
              <Tr>
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
                } = acs;
                const {
                  last_refresh_words: lastRefreshWords,
                  started_at: startedAt,
                } = lastTask ?? {};
                return (
                  <Tr key={index}>
                    <Td onClick={() => { onClick(id); push(`/labs/alternate_content_sources/${id}/details`); }}>
                      <Text component="a">{name}</Text>
                    </Td>
                    <Td>{acsType}</Td>
                    <Td><LastSync startedAt={startedAt} lastSync={lastTask} lastSyncWords={lastRefreshWords} emptyMessage="N/A" /></Td>
                    <Td
                      actions={{
                        items: rowDropdownItems(acs),
                      }}
                    />
                  </Tr>
                );
              })
            }
            </Tbody>
          </TableWrapper>
        </DrawerContentBody>
      </DrawerContent>
    </Drawer>
  );
  /* eslint-enable react/no-array-index-key */
};

export default ACSTable;

