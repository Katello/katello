import React, {
  useCallback,
  useEffect,
  useState,
  useMemo,
} from 'react';

import { propsToCamelCase } from 'foremanReact/common/helpers';
import { translate as __ } from 'foremanReact/common/I18n';
import { STATUS } from 'foremanReact/constants';
import { selectAPIResponse } from 'foremanReact/redux/API/APISelectors';
import PropTypes from 'prop-types';
import { FormattedMessage } from 'react-intl';
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
import { REPOSITORY_SETS_KEY } from './RepositorySetsConstants.js';
import { selectRepositorySetsStatus } from './RepositorySetsSelectors';
import './RepositorySetsTab.scss';

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

const RepositorySetsTab = () => {
  const hostDetails = useSelector(state => selectAPIResponse(state, 'HOST_DETAILS'));
  const {
    id: hostId,
    subscription_status: subscriptionStatus,
    content_facet_attributes: contentFacetAttributes,
  } = hostDetails;
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
  const { searchParam, show } = useUrlParams();
  const toggleGroupStates = ['noLimit', 'limitToEnvironment'];
  const [noLimit, limitToEnvironment] = toggleGroupStates;
  const defaultToggleGroupState = nonLibraryHost ? limitToEnvironment : noLimit;
  const [toggleGroupState, setToggleGroupState] =
    useState(show ?? defaultToggleGroupState);
  const [alertShowing, setAlertShowing] = useState(false);
  const emptyContentTitle = __('No repository sets to show.');
  const emptyContentBody = __('Repository sets will appear here when available.');
  const emptySearchTitle = __('No matching repository sets found');
  const emptySearchBody = __('Try changing your search query.');
  const columnHeaders = useMemo(() => [
    __('Repository'),
    __('Product'),
    __('Repository path'),
    __('Status'),
  ], []);

  const COLUMNS_TO_SORT_PARAMS = {
    [columnHeaders[0]]: 'name',
    [columnHeaders[1]]: 'product',
    [columnHeaders[2]]: 'path',
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
    params => (hostId ?
      getHostRepositorySets({
        content_access_mode_env: toggleGroupState === limitToEnvironment,
        content_access_mode_all: simpleContentAccess,
        host_id: hostId,
        ...apiSortParams,
        ...params,
      }) : hostIdNotReady),
    [hostId, toggleGroupState, limitToEnvironment,
      simpleContentAccess, apiSortParams],
  );

  const response = useSelector(state => selectAPIResponse(state, REPOSITORY_SETS_KEY));
  const { results, ...metadata } = response;
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

  let toggleGroup;
  if (nonLibraryHost) {
    toggleGroup = (
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
    );
  }

  const actionButtons = (
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
  );

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
            emptySearchTitle,
            emptySearchBody,
            status,
            searchQuery,
            updateSearchQuery,
            selectedCount,
            selectNone,
            toggleGroup,
            actionButtons,
          }
          }
          activeFilters={[toggleGroupState]}
          defaultFilters={[defaultToggleGroupState]}
          additionalListeners={[hostId, toggleGroupState, activeSortColumn, activeSortDirection]}
          fetchItems={fetchItems}
          autocompleteEndpoint="/repository_sets/auto_complete_search"
          bookmarkController="katello_product_contents" // Katello::ProductContent.table_name
          rowsCount={results?.length}
          variant={TableVariant.compact}
          {...selectAll}
          displaySelectAllCheckbox
        >
          <Thead>
            <Tr>
              <Th key="select-all" />
              <Th key="repo" sort={pfSortParams('Repository')}>{__('Repository')}</Th>
              <Th key="product" sort={pfSortParams('Product')}>{__('Product')}</Th>
              <Th key="path">{__('Repository path')}</Th>
              <Th key="status" sort={pfSortParams('Status')}>{__('Status')}</Th>
              <Th />
              <Th key="action-menu" />
            </Tr>
          </Thead>
          <>
            {results?.map((repoSet, rowIndex) => {
              const {
                id,
                content: { name: repoName },
                enabled,
                enabled_content_override: enabledContentOverride,
                contentUrl: repoPath,
                product: { name: productName, id: productId },
              } = repoSet;
              const { isEnabled, isOverridden } =
                getEnabledValue({ enabled, enabledContentOverride });
              return (
                <Tbody key={`${id}_${repoPath}`}>
                  <Tr>
                    <Td select={{
                      disable: !isSelectable(id),
                      isSelected: isSelected(id),
                      onSelect: (event, selected) => selectOne(selected, id),
                      rowIndex,
                      variant: 'checkbox',
                    }}
                    />
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
                    </Td>
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

export default RepositorySetsTab;
