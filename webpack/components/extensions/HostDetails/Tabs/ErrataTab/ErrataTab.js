import React, { useCallback, useState } from 'react';
import { useSelector, useDispatch } from 'react-redux';
import {
  Button, Split, SplitItem, ActionList, ActionListItem, Dropdown,
  DropdownItem, KebabToggle, Skeleton, Tooltip, ToggleGroup, ToggleGroupItem,
} from '@patternfly/react-core';
import { TimesIcon, CheckIcon } from '@patternfly/react-icons';
import {
  TableVariant,
  TableText,
  Thead,
  Tbody,
  Tr,
  Th,
  Td,
  ExpandableRowContent,
} from '@patternfly/react-table';
import { translate as __ } from 'foremanReact/common/I18n';
import { selectAPIResponse } from 'foremanReact/redux/API/APISelectors';
import IsoDate from 'foremanReact/components/common/dates/IsoDate';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import { propsToCamelCase } from 'foremanReact/common/helpers';
import SelectableDropdown from '../../../../SelectableDropdown';
import { useSet, useBulkSelect, useUrlParams, useTableSort } from '../../../../../components/Table/TableHooks';
import TableWrapper from '../../../../../components/Table/TableWrapper';
import { ErrataType, ErrataSeverity } from '../../../../../components/Errata';
import { getInstallableErrata, regenerateApplicability, applyViaKatelloAgent } from './HostErrataActions';
import ErratumExpansionDetail from './ErratumExpansionDetail';
import ErratumExpansionContents from './ErratumExpansionContents';
import { selectHostErrataStatus } from './HostErrataSelectors';
import { HOST_ERRATA_KEY, ERRATA_TYPES, ERRATA_SEVERITIES, TYPES_TO_PARAM, SEVERITIES_TO_PARAM, PARAM_TO_FRIENDLY_NAME } from './HostErrataConstants';
import { installErrata } from '../RemoteExecutionActions';
import { errataInstallUrl } from '../customizedRexUrlHelpers';
import './ErrataTab.scss';
import hostIdNotReady from '../../HostDetailsActions';
import defaultRemoteActionMethod, { KATELLO_AGENT } from '../../hostDetailsHelpers';
import SortableColumnHeaders from '../../../../Table/components/SortableColumnHeaders';

export const ErrataTab = () => {
  const hostDetails = useSelector(state => selectAPIResponse(state, 'HOST_DETAILS'));
  const {
    id: hostId,
    name: hostname,
    content_facet_attributes: contentFacetAttributes,
  } = hostDetails;
  const contentFacet = propsToCamelCase(contentFacetAttributes ?? {});
  const dispatch = useDispatch();
  const toggleGroupStates = ['all', 'installable'];
  const [ALL, INSTALLABLE] = toggleGroupStates;
  const ERRATA_TYPE = __('Type');
  const ERRATA_SEVERITY = __('Severity');
  const [isBulkActionOpen, setIsBulkActionOpen] = useState(false);
  const toggleBulkAction = () => setIsBulkActionOpen(prev => !prev);
  const expandedErrata = useSet([]);
  const erratumIsExpanded = id => expandedErrata.has(id);
  const {
    type: initialType,
    severity: initialSeverity,
    show,
    searchParam,
  } = useUrlParams();
  const [toggleGroupState, setToggleGroupState] = useState(show ?? INSTALLABLE);
  const [errataTypeSelected, setErrataTypeSelected]
    = useState(PARAM_TO_FRIENDLY_NAME[initialType] ?? ERRATA_TYPE);
  const [errataSeveritySelected, setErrataSeveritySelected]
    = useState(PARAM_TO_FRIENDLY_NAME[initialSeverity] ?? ERRATA_SEVERITY);
  const activeFilters = [errataTypeSelected, errataSeveritySelected];
  const defaultFilters = [ERRATA_TYPE, ERRATA_SEVERITY];

  const emptyContentTitle = __('This host does not have any installable errata.');
  const emptyContentBody = __('Installable errata will appear here when available.');
  const emptySearchTitle = __('No matching errata found');
  const emptySearchBody = __('Try changing your search settings.');
  const columnHeaders = [
    __('Errata'),
    __('Type'),
    __('Severity'),
    __('Installable'),
    __('Synopsis'),
    __('Published date'),
  ];
  const COLUMNS_TO_SORT_PARAMS = {
    [columnHeaders[0]]: 'errata_id',
    [columnHeaders[1]]: 'type',
    [columnHeaders[2]]: 'severity',
    [columnHeaders[5]]: 'updated',
  };

  const {
    pfSortParams, apiSortParams,
    activeSortColumn, activeSortDirection,
  } = useTableSort({
    allColumns: columnHeaders,
    columnsToSortParams: COLUMNS_TO_SORT_PARAMS,
    initialSortColumnName: 'Errata',
  });

  const fetchItems = useCallback(
    (params) => {
      if (!hostId) return hostIdNotReady;
      const modifiedParams = { ...params };
      if (errataTypeSelected !== ERRATA_TYPE) {
        modifiedParams.type = TYPES_TO_PARAM[errataTypeSelected];
      }
      if (errataSeveritySelected !== ERRATA_SEVERITY) {
        modifiedParams.severity = SEVERITIES_TO_PARAM[errataSeveritySelected];
      }
      return getInstallableErrata(
        hostId,
        {
          include_applicable: toggleGroupState === ALL,
          ...apiSortParams,
          ...modifiedParams,
        },
      );
    },
    [hostId, toggleGroupState, ALL, ERRATA_SEVERITY, ERRATA_TYPE,
      errataTypeSelected, errataSeveritySelected, apiSortParams],
  );

  const response = useSelector(state => selectAPIResponse(state, HOST_ERRATA_KEY));
  const { results, ...metadata } = response;
  const status = useSelector(state => selectHostErrataStatus(state));
  const errataSearchQuery = id => `errata_id = ${id}`;
  const {
    selectOne, isSelected, searchQuery, selectedCount, isSelectable,
    updateSearchQuery, selectNone, fetchBulkParams, ...selectAll
  } = useBulkSelect({
    results,
    metadata,
    idColumn: 'errata_id',
    isSelectable: result => result.installable,
    initialSearchQuery: searchParam || '',
  });

  if (!hostId) return <Skeleton />;

  const applyErratumViaRemoteExecution = id => dispatch(installErrata({
    hostname,
    search: errataSearchQuery(id),
  }));

  const applyViaRemoteExecution = () => {
    dispatch(installErrata({
      hostname, search: fetchBulkParams(),
    }));

    const params = { page: metadata.page, per_page: metadata.per_page, search: metadata.search };
    dispatch(getInstallableErrata(
      hostId,
      { ...params, include_applicable: toggleGroupState === ALL },
    ));
  };

  const bulkCustomizedRexUrl = () => errataInstallUrl({
    hostname, search: (selectedCount > 0) ? fetchBulkParams() : '',
  });

  const recalculateErrata = () => {
    setIsBulkActionOpen(false);
    dispatch(regenerateApplicability(hostId));
  };

  const applyByKatelloAgent = () => {
    const selected = fetchBulkParams();
    setIsBulkActionOpen(false);
    selectNone();
    dispatch(applyViaKatelloAgent(hostId, { search: selected }));
  };

  const applyErratumViaKatelloAgent = id => dispatch(applyViaKatelloAgent(
    hostId,
    { errata_ids: [id] },
  ));

  const defaultRemoteAction = defaultRemoteActionMethod({ hostDetails });
  const apply = () => {
    if (defaultRemoteAction === KATELLO_AGENT) {
      applyByKatelloAgent();
    } else {
      applyViaRemoteExecution();
    }
  };

  const dropdownItems = [
    <DropdownItem
      aria-label="bulk_add"
      key="bulk_add"
      component="button"
      onClick={recalculateErrata}
    >
      {__('Recalculate')}
    </DropdownItem>,
  ];

  if (defaultRemoteAction === KATELLO_AGENT) {
    dropdownItems.push((
      <DropdownItem
        aria-label="apply_via_katello_agent"
        key="apply_via_katello_agent"
        component="button"
        onClick={applyByKatelloAgent}
        isDisabled={selectedCount === 0}
      >
        {__('Apply via Katello agent')}
      </DropdownItem>));
  }

  dropdownItems.push((
    <DropdownItem
      aria-label="apply_via_remote_execution"
      key="apply_via_remote_execution"
      component="button"
      onClick={applyViaRemoteExecution}
      isDisabled={selectedCount === 0}
    >
      {__('Apply via remote execution')}
    </DropdownItem>));

  dropdownItems.push((
    <DropdownItem
      aria-label="apply_via_customized_remote_execution"
      key="apply_via_customized_remote_execution"
      component="a"
      href={bulkCustomizedRexUrl()}
      isDisabled={selectedCount === 0}
    >
      {__('Apply via customized remote execution')}
    </DropdownItem>));

  const handleErrataTypeSelected = newType => setErrataTypeSelected((prevType) => {
    if (prevType === newType) {
      return ERRATA_TYPE;
    }
    return newType;
  });

  const handleErrataSeveritySelected = newSeverity => setErrataSeveritySelected((prevSeverity) => {
    if (prevSeverity === newSeverity) {
      return ERRATA_SEVERITY;
    }
    return newSeverity;
  });

  const actionButtons = (
    <>
      <Split hasGutter>
        <SplitItem>
          <ActionList isIconList>
            <ActionListItem>
              <Button isDisabled={selectedCount === 0} onClick={apply}> {__('Apply')} </Button>
            </ActionListItem>
            <ActionListItem>
              <Dropdown
                toggle={<KebabToggle aria-label="bulk_actions" onToggle={toggleBulkAction} />}
                isOpen={isBulkActionOpen}
                isPlain
                dropdownItems={dropdownItems}
              />
            </ActionListItem>
          </ActionList>
        </SplitItem>
      </Split>
    </>
  );

  const hostIsNonLibrary = (
    contentFacet?.contentViewDefault === false && contentFacet.lifecycleEnvironmentLibrary === false
  );
  const toggleGroup = (
    <Split hasGutter>
      <SplitItem>
        <SelectableDropdown
          id="errata-type-dropdown"
          title={ERRATA_TYPE}
          showTitle={false}
          items={Object.values(ERRATA_TYPES)}
          selected={errataTypeSelected}
          setSelected={handleErrataTypeSelected}
        />
      </SplitItem>
      <SplitItem>
        <SelectableDropdown
          id="errata-severity-dropdown"
          title={ERRATA_SEVERITY}
          showTitle={false}
          items={Object.values(ERRATA_SEVERITIES)}
          selected={errataSeveritySelected}
          setSelected={handleErrataSeveritySelected}
        />
      </SplitItem>
      {hostIsNonLibrary &&
        <SplitItem>
          <ToggleGroup aria-label="Installable Errata">
            <ToggleGroupItem
              text={__('All')}
              buttonId="allToggle"
              aria-label="Show All"
              isSelected={toggleGroupState === ALL}
              onChange={() => setToggleGroupState(ALL)}
            />

            <ToggleGroupItem
              text={__('Installable')}
              buttonId="installableToggle"
              aria-label="Show Installable"
              isSelected={toggleGroupState === INSTALLABLE}
              onChange={() => setToggleGroupState(INSTALLABLE)}
            />
          </ToggleGroup>
        </SplitItem>
      }
    </Split>
  );

  return (
    <div>
      <div id="errata-tab">
        <TableWrapper
          {...{
            metadata,
            emptyContentTitle,
            emptyContentBody,
            emptySearchTitle,
            emptySearchBody,
            status,
            activeFilters,
            defaultFilters,
            actionButtons,
            searchQuery,
            updateSearchQuery,
            selectedCount,
            selectNone,
            toggleGroup,
          }
          }
          additionalListeners={[
            hostId, toggleGroupState, errataTypeSelected,
            errataSeveritySelected, activeSortColumn, activeSortDirection]}
          fetchItems={fetchItems}
          autocompleteEndpoint={`/hosts/${hostId}/errata/auto_complete_search`}
          foremanApiAutoComplete
          rowsCount={results?.length}
          variant={TableVariant.compact}
          {...selectAll}
          displaySelectAllCheckbox
        >
          <Thead>
            <Tr>
              <Th key="expand-carat" />
              <Th key="select-all" />
              <SortableColumnHeaders
                columnHeaders={columnHeaders}
                pfSortParams={pfSortParams}
                columnsToSortParams={COLUMNS_TO_SORT_PARAMS}
              />
              <Th key="action-menu" />
            </Tr>
          </Thead>
          <>
            {results?.map((erratum, rowIndex) => {
              const {
                id,
                errata_id: errataId,
                created_at: createdAt,
                updated: publishedAt,
                title,
                installable: isInstallable,
              } = erratum;
              const isExpanded = erratumIsExpanded(id);
              let rowActions;
              if (isInstallable) {
                rowActions = [
                  {
                    title: __('Apply via remote execution'),
                    onClick: () => applyErratumViaRemoteExecution(errataId),
                  },
                  {
                    title: __('Apply via customized remote execution'),
                    component: 'a',
                    href: errataInstallUrl({ hostname, search: errataSearchQuery(errataId) }),
                  },
                ];

                if (contentFacet.katelloAgentInstalled && contentFacet.katelloAgentEnabled) {
                  rowActions.unshift({
                    title: __('Apply via Katello agent'),
                    onClick: () => applyErratumViaKatelloAgent(errataId),
                  });
                }
              } else {
                rowActions = [
                  {
                    title: __('Apply Erratum'),
                    component: 'a',
                    href: urlBuilder(`errata/${id}/content-hosts`, ''),
                  },
                ];
              }

              return (
                <Tbody isExpanded={isExpanded} key={`${id}_${createdAt}`}>
                  <Tr>
                    <Td
                      expand={{
                        rowIndex,
                        isExpanded,
                        onToggle: (_event, _rInx, isOpen) => expandedErrata.onToggle(isOpen, id),
                      }}
                    />
                    <Td select={{
                      disable: !isSelectable(errataId),
                      isSelected: isSelected(errataId),
                      onSelect: (event, selected) => selectOne(selected, errataId),
                      rowIndex,
                      variant: 'checkbox',
                    }}
                    />
                    <Td>
                      <a href={urlBuilder(`errata/${id}`, '')}>{errataId}</a>
                    </Td>
                    <Td><ErrataType {...erratum} /></Td>
                    <Td><ErrataSeverity {...erratum} /></Td>
                    <Td>
                      {isInstallable ?
                        <span><CheckIcon /> {__('Yes')}</span> :
                        <span>
                          <Tooltip
                            content={
                              __("This erratum is not installable because it is not in this host's content view and lifecycle environment.")
                            }
                          >

                            <TimesIcon />
                          </Tooltip>
                          {__('No')}
                        </span>
                      }
                    </Td>
                    <Td><TableText wrapModifier="truncate">{title}</TableText></Td>
                    <Td key={publishedAt}><IsoDate date={publishedAt} /></Td>
                    <Td
                      key={`rowActions-${id}`}
                      actions={{
                        items: rowActions,
                      }}

                    />
                  </Tr>
                  <Tr key="child_row" isExpanded={isExpanded}>
                    <Td colSpan={3}>
                      <ExpandableRowContent>
                        <ErratumExpansionContents erratum={erratum} />
                      </ExpandableRowContent>
                    </Td>
                    <Td colSpan={4}>
                      <ExpandableRowContent>
                        <ErratumExpansionDetail erratum={erratum} />
                      </ExpandableRowContent>
                    </Td>
                  </Tr>
                </Tbody>
              );
            })
            }
          </>
        </TableWrapper>
      </div>
    </div>
  );
};

export default ErrataTab;
