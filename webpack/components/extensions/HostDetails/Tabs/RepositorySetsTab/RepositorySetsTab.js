import React, {
  useCallback,
  useEffect,
  useState,
  useMemo,
} from 'react';

import { propsToCamelCase } from 'foremanReact/common/helpers';
import { translate as __ } from 'foremanReact/common/I18n';
import { selectAPIResponse } from 'foremanReact/redux/API/APISelectors';
import PropTypes from 'prop-types';
import { FormattedMessage } from 'react-intl';
import { STATUS } from 'foremanReact/constants';
import {
  useDispatch,
  useSelector,
} from 'react-redux';

import {
  ActionList,
  ActionListItem,
  Alert,
  AlertActionCloseButton,
  Dropdown,
  DropdownItem,
  KebabToggle,
  Label,
  Skeleton,
  Split,
  SplitItem,
  ToggleGroup,
  ToggleGroupItem,
  Tooltip,
} from '@patternfly/react-core';
import { FlagIcon } from '@patternfly/react-icons';
import {
  TableVariant,
  Tbody,
  Td,
  Th,
  Thead,
  Tr,
} from '@patternfly/react-table';

import {
  useBulkSelect,
  useTableSort,
  useUrlParams,
} from '../../../../../components/Table/TableHooks';
import TableWrapper from '../../../../../components/Table/TableWrapper';
import hostIdNotReady from '../../HostDetailsActions';
import { selectHostDetailsStatus } from '../../HostDetailsSelectors.js';
import {
  getHostRepositorySets,
  setContentOverrides,
} from './RepositorySetsActions';
import { REPOSITORY_SETS_KEY, STATUSES, STATUS_TO_PARAM, PARAM_TO_FRIENDLY_NAME } from './RepositorySetsConstants.js';
import { selectRepositorySetsStatus } from './RepositorySetsSelectors';
import './RepositorySetsTab.scss';
import SortableColumnHeaders from '../../../../Table/components/SortableColumnHeaders';
import SelectableDropdown from '../../../../SelectableDropdown';
import { hasRequiredPermissions as can,
  missingRequiredPermissions as cannot,
  userPermissionsFromHostDetails } from '../../hostDetailsHelpers';

const viewRepoSets = [
  'view_hosts', 'view_activation_keys', 'view_products',
];
const createBookmarks = ['create_bookmarks'];

export const hideRepoSetsTab = ({ hostDetails }) =>
  cannot(
    viewRepoSets,
    userPermissionsFromHostDetails({ hostDetails }),
  );

const editHosts = ['edit_hosts'];
const getEnabledValue = ({ enabled, enabledContentOverride }) => {
  const isOverridden = (enabledContentOverride !== null);
  return {
    isOverridden,
    isEnabled: (isOverridden ? enabledContentOverride : enabled),
  };
};

const EnabledIcon = ({ isEnabled, isOverridden }) => {
  const enabledLabel = (
    <Label
      color={isEnabled ? 'green' : 'gray'}
      icon={isOverridden ? <FlagIcon /> : null}
      className={`${isEnabled ? 'enabled' : 'disabled'}-label${isOverridden ? ' content-override' : ''}`}
    >
      {isEnabled ? __('Enabled') : __('Disabled')}
    </Label>
  );
  if (isOverridden) {
    return (
      <Tooltip
        position="right"
        content={__('Overridden')}
      >
        {enabledLabel}
      </Tooltip>
    );
  }
  return enabledLabel;
};

EnabledIcon.propTypes = {
  isEnabled: PropTypes.bool.isRequired,
  isOverridden: PropTypes.bool.isRequired,
};

const OsRestrictedIcon = ({ osRestricted }) => (
  <Tooltip
    position="right"
    content={<FormattedMessage
      id="os-restricted-tooltip"
      defaultMessage={__('OS restricted to {osRestricted}. If host OS does not match, the repository will not be available on this host.')}
      values={{ osRestricted }}
    />}
  >
    <Label color="blue" className="os-restricted-label" style={{ marginLeft: '8px' }}>
      {__(osRestricted)}
    </Label>
  </Tooltip>
);

OsRestrictedIcon.propTypes = {
  osRestricted: PropTypes.string,
};

OsRestrictedIcon.defaultProps = {
  osRestricted: null,
};

const RepositorySetsTab = () => {
  const hostDetails = useSelector(state => selectAPIResponse(state, 'HOST_DETAILS'));
  const {
    id: hostId,
    subscription_status: subscriptionStatus,
    content_facet_attributes: contentFacetAttributes,
  } = hostDetails;
  const canDoContentOverrides = can(
    editHosts,
    userPermissionsFromHostDetails({ hostDetails }),
  );
  const STATUS_LABEL = __('Status');

  const contentFacet = propsToCamelCase(contentFacetAttributes ?? {});
  const {
    contentViewDefault,
    lifecycleEnvironmentLibrary,
    contentViewName,
    lifecycleEnvironmentName,
  } = contentFacet;
  const nonLibraryHost = contentViewDefault === false &&
    lifecycleEnvironmentLibrary === false;
  const simpleContentAccess = (Number(subscriptionStatus) === 5);
  const [isBulkActionOpen, setIsBulkActionOpen] = useState(false);
  const toggleBulkAction = () => setIsBulkActionOpen(prev => !prev);
  const dispatch = useDispatch();
  const { searchParam, show, status: initialStatus } = useUrlParams();

  const toggleGroupStates = ['noLimit', 'limitToEnvironment'];
  const [noLimit, limitToEnvironment] = toggleGroupStates;
  const defaultToggleGroupState = nonLibraryHost ? limitToEnvironment : noLimit;
  const [toggleGroupState, setToggleGroupState] =
    useState(show ?? defaultToggleGroupState);
  const [statusSelected, setStatusSelected]
    = useState(PARAM_TO_FRIENDLY_NAME[initialStatus] ?? STATUS_LABEL);
  const activeFilters = [statusSelected, toggleGroupState];
  const defaultFilters = [STATUS_LABEL, defaultToggleGroupState];

  const [alertShowing, setAlertShowing] = useState(false);
  const emptyContentTitle = __('No repository sets to show.');
  const emptyContentBody = __('Repository sets will appear here when available.');
  const emptySearchTitle = __('No matching repository sets found');
  const emptySearchBody = __('Try changing your search query.');
  const errorSearchTitle = __('Problem searching repository sets');
  const columnHeaders = useMemo(() => [
    __('Repository'),
    __('Product'),
    __('Repository path'),
    __('Status'),
  ], []);

  const COLUMNS_TO_SORT_PARAMS = {
    [columnHeaders[0]]: 'name',
    [columnHeaders[1]]: 'product',
    [columnHeaders[3]]: 'enabled_by_default',
  };

  const {
    pfSortParams, apiSortParams,
    activeSortColumn, activeSortDirection,
  } = useTableSort({
    allColumns: columnHeaders,
    columnsToSortParams: COLUMNS_TO_SORT_PARAMS,
  });

  const fetchItems = useCallback(
    (params) => {
      if (!hostId) return hostIdNotReady;
      const modifiedParams = { ...params };
      if (statusSelected !== STATUS_LABEL) {
        modifiedParams.status = STATUS_TO_PARAM[statusSelected];
      }
      return getHostRepositorySets({
        content_access_mode_env: toggleGroupState === limitToEnvironment,
        content_access_mode_all: simpleContentAccess,
        host_id: hostId,
        ...apiSortParams,
        ...modifiedParams,
      });
    },
    [hostId, toggleGroupState, limitToEnvironment,
      simpleContentAccess, apiSortParams, statusSelected, STATUS_LABEL],
  );

  const response = useSelector(state => selectAPIResponse(state, REPOSITORY_SETS_KEY));
  const { results, error: errorSearchBody, ...metadata } = response;
  const status = useSelector(state => selectRepositorySetsStatus(state));
  const repoSetSearchQuery = label => `cp_content_id = ${label}`;
  const {
    selectOne, isSelected, searchQuery, selectedCount, isSelectable,
    updateSearchQuery, selectNone, fetchBulkParams, ...selectAll
  } = useBulkSelect({
    results,
    metadata,
    initialSearchQuery: searchParam || '',
  });

  const hostDetailsStatus = useSelector(state => selectHostDetailsStatus(state));

  useEffect(() => {
    // wait until host details are loaded to set alertShowing
    if (hostDetailsStatus === STATUS.RESOLVED) {
      setAlertShowing(nonLibraryHost);
    }
  }, [hostDetailsStatus, nonLibraryHost]);

  if (!hostId) return <Skeleton />;
  const updateResults = newResponse => dispatch({
    type: `${REPOSITORY_SETS_KEY}_SUCCESS`,
    key: REPOSITORY_SETS_KEY,
    response: {
      ...response,
      results: results.map((result) => {
        const {
          enabled,
          enabled_content_override: enabledContentOverride,
        } = newResponse.results.find(r => r.id === result.id);
        if (enabled !== null) {
          return { ...result, enabled, enabled_content_override: enabledContentOverride };
        }
        return result;
      }),
    },
  });

  const handleStatusSelected = newType => setStatusSelected((prevType) => {
    if (prevType === newType) {
      return STATUS_LABEL;
    }
    return newType;
  });

  const updateOverrides = ({
    enabled, remove = false, search, singular = false,
  }) => {
    setIsBulkActionOpen(false);
    selectNone();

    dispatch(setContentOverrides({
      hostId,
      search,
      enabled,
      remove,
      updateResults: resp => updateResults(resp),
      singular: singular || selectedCount === 1,
    }));
  };
  const bulkParams = () => fetchBulkParams('cp_content_id');
  const enableRepoSets = () => updateOverrides({ enabled: true, search: bulkParams() });
  const disableRepoSets = () => updateOverrides({ enabled: false, search: bulkParams() });
  const resetToDefaultRepoSets = () => updateOverrides({ remove: true, search: bulkParams() });

  const enableRepoSet = id => updateOverrides({
    enabled: true,
    search: repoSetSearchQuery(id),
    singular: true,
  });
  const disableRepoSet = id => updateOverrides({
    enabled: false,
    search: repoSetSearchQuery(id),
    singular: true,
  });
  const resetToDefaultRepoSet = id => updateOverrides({
    remove: true,
    search: repoSetSearchQuery(id),
    singular: true,
  });

  const readOnlyBookmarks =
  cannot(createBookmarks, userPermissionsFromHostDetails({ hostDetails }));

  const dropdownItems = [
    <DropdownItem aria-label="bulk_enable" key="bulk_enable" component="button" onClick={enableRepoSets} isDisabled={selectedCount === 0}>
      {__('Override to enabled')}
    </DropdownItem>,
    <DropdownItem aria-label="bulk_disable" key="bulk_disable" component="button" onClick={disableRepoSets} isDisabled={selectedCount === 0}>
      {__('Override to disabled')}
    </DropdownItem>,
    <DropdownItem aria-label="bulk_reset_default" key="bulk_reset_default" component="button" onClick={resetToDefaultRepoSets} isDisabled={selectedCount === 0}>
      {__('Reset to default')}
    </DropdownItem>,
  ];

  const toggleGroup = (
    <Split hasGutter>
      {nonLibraryHost &&
        <SplitItem>
          <ToggleGroup aria-label="Repository Set toggle">
            <ToggleGroupItem
              text={__('Show all')}
              buttonId="no-limit-toggle"
              aria-label="No limit"
              isSelected={toggleGroupState === noLimit}
              onChange={() => setToggleGroupState(noLimit)}
            />
            <ToggleGroupItem
              text={__('Limit to environment')}
              buttonId="limit-to-env-toggle"
              aria-label="Limit to environment"
              isSelected={toggleGroupState === limitToEnvironment}
              onChange={() => setToggleGroupState(limitToEnvironment)}
            />
          </ToggleGroup>
        </SplitItem>
      }
      <SplitItem>
        <SelectableDropdown
          id="status-dropdown"
          title={STATUS_LABEL}
          showTitle={false}
          items={Object.values(STATUSES)}
          selected={statusSelected}
          setSelected={handleStatusSelected}
        />
      </SplitItem>
    </Split>
  );

  const actionButtons = canDoContentOverrides ? (
    <Split hasGutter>
      <SplitItem>
        <ActionList isIconList>
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
  ) : null;

  const hostEnvText = 'the "{contentViewName}" content view and "{lifecycleEnvironmentName}" environment';

  const scaAlert = (toggleGroupState === limitToEnvironment ?
    `Showing only repositories in ${hostEnvText}.` :
    'Showing all available repositories.');

  const nonScaAlert = (toggleGroupState === limitToEnvironment ?
    `Showing repositories in ${hostEnvText} that are available through subscriptions.` :
    'Showing all repositories available through subscriptions.');

  let alertText;
  if (simpleContentAccess) {
    alertText = scaAlert;
  } else {
    alertText = nonScaAlert;
  }
  return (
    <div>
      <div id="repo-sets-tab">
        <div className="content-header">
          <div className="repo-sets-blurb">
            <FormattedMessage
              className="repo-sets-blurb"
              id="repo-sets-blurb"
              defaultMessage={__('Below are the repository sets currently available for this content host. For Red Hat subscriptions, additional content can be made available through the {rhrp}. Changing default settings requires subscription-manager 1.10 or newer to be installed on this host.')}
              values={{
                rhrp: <a href="/redhat_repositories">{__('Red Hat Repositories page')}</a>,
              }}
            />
          </div>
          {alertShowing &&
            <Alert
              variant="info"
              className="repo-sets-alert"
              isInline
              title={
                <FormattedMessage
                  className="repo-sets-alert-title"
                  id="repo-sets-alert-title"
                  defaultMessage={alertText}
                  values={{
                    contentViewName,
                    lifecycleEnvironmentName,
                  }}
                />
              }
              actionClose={<AlertActionCloseButton onClose={() => setAlertShowing(false)} />}
            />
          }
        </div>
        <TableWrapper
          {...{
            metadata,
            emptyContentTitle,
            emptyContentBody,
            status,
            searchQuery,
            updateSearchQuery,
            selectedCount,
            selectNone,
            toggleGroup,
            actionButtons,
            emptySearchTitle,
            emptySearchBody,
            activeFilters,
            defaultFilters,
          }
          }
          ouiaId="host-repository-sets-table"
          errorSearchTitle={errorSearchTitle}
          errorSearchBody={errorSearchBody}
          additionalListeners={[hostId, toggleGroupState, statusSelected,
            activeSortColumn, activeSortDirection]}
          fetchItems={fetchItems}
          autocompleteEndpoint="/repository_sets/auto_complete_search"
          bookmarkController="katello_product_contents" // Katello::ProductContent.table_name
          readOnlyBookmarks={readOnlyBookmarks}
          rowsCount={results?.length}
          variant={TableVariant.compact}
          {...selectAll}
          displaySelectAllCheckbox={canDoContentOverrides}
        >
          <Thead>
            <Tr>
              <Th key="select-all" />
              <SortableColumnHeaders
                columnHeaders={columnHeaders}
                pfSortParams={pfSortParams}
                columnsToSortParams={COLUMNS_TO_SORT_PARAMS}
              />
              <Th />
              <Th key="action-menu" />
            </Tr>
          </Thead>
          <Tbody>
            {results?.map((repoSet, rowIndex) => {
              const {
                id,
                content: { name: repoName },
                enabled,
                enabled_content_override: enabledContentOverride,
                contentUrl: repoPath,
                product: { name: productName, id: productId },
                osRestricted,
              } = repoSet;
              const { isEnabled, isOverridden } =
                getEnabledValue({ enabled, enabledContentOverride });
              return (
                <Tr key={id}>
                  {canDoContentOverrides ? (
                    <Td select={{
                      disable: !isSelectable(id),
                      isSelected: isSelected(id),
                      onSelect: (event, selected) => selectOne(selected, id),
                      rowIndex,
                      variant: 'checkbox',
                    }}
                    />
                  ) : <Td>&nbsp;</Td>}
                  <Td>
                    <span>{repoName}</span>
                  </Td>
                  <Td>
                    <a href={`/products/${productId}`}>{productName}</a>
                  </Td>
                  <Td>
                    <span>{repoPath}</span>
                  </Td>
                  <Td>
                    <span><EnabledIcon key={`enabled-icon-${id}`} {...{ isEnabled, isOverridden }} /></span>
                    {osRestricted &&
                      <span><OsRestrictedIcon key={`os-restricted-icon-${id}`} {...{ osRestricted }} /></span>
                    }
                  </Td>
                  {canDoContentOverrides ? (
                    <Td
                      key={`rowActions-${id}`}
                      actions={{
                        items: [
                          {
                            title: __('Override to disabled'),
                            isDisabled: isOverridden && !isEnabled,
                            onClick: () => disableRepoSet(id),
                          },
                          {
                            title: __('Override to enabled'),
                            isDisabled: isOverridden && isEnabled,
                            onClick: () => enableRepoSet(id),
                          },
                          {
                            title: __('Reset to default'),
                            isDisabled: !isOverridden,
                            onClick: () => resetToDefaultRepoSet(id),
                          },
                        ],
                      }}
                    />
                  ) : <Td />}
                </Tr>
              );
            })
            }
          </Tbody>
        </TableWrapper>
      </div>
    </div>
  );
};

export default RepositorySetsTab;
