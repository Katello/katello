import React, { useCallback, useState, useEffect } from 'react';
import { FormattedMessage } from 'react-intl';
import PropTypes from 'prop-types';
import { useSelector, useDispatch } from 'react-redux';
import { Skeleton, ToggleGroup, ToggleGroupItem, Label, Tooltip, Alert, AlertActionCloseButton } from '@patternfly/react-core';
import {
  TableVariant,
  Thead,
  Tbody,
  Tr,
  Th,
  Td,
} from '@patternfly/react-table';
import { FlagIcon } from '@patternfly/react-icons';
import { translate as __ } from 'foremanReact/common/I18n';
import { propsToCamelCase } from 'foremanReact/common/helpers';
import { selectAPIResponse } from 'foremanReact/redux/API/APISelectors';
import { STATUS } from 'foremanReact/constants';
import TableWrapper from '../../../../../components/Table/TableWrapper';
import { enableRepoSetRepo, disableRepoSetRepo, resetRepoSetRepo, getHostRepositorySets } from './RepositorySetsActions';
import { selectRepositorySetsStatus } from './RepositorySetsSelectors';
import { selectHostDetailsStatus } from '../../HostDetailsSelectors.js';
import { useBulkSelect, useUrlParams } from '../../../../../components/Table/TableHooks';
import { REPOSITORY_SETS_KEY } from './RepositorySetsConstants.js';
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
  const columnHeaders = [
    __('Repository'),
    __('Product'),
    __('Repository path'),
    __('Status'),
  ];
  const fetchItems = useCallback(
    params => (hostId ?
      getHostRepositorySets({
        content_access_mode_env: toggleGroupState === limitToEnvironment,
        content_access_mode_all: simpleContentAccess,
        host_id: hostId,
        ...params,
      }) : null),
    [hostId, toggleGroupState, limitToEnvironment, simpleContentAccess],
  );

  const response = useSelector(state => selectAPIResponse(state, REPOSITORY_SETS_KEY));
  const { results, ...metadata } = response;
  const status = useSelector(state => selectRepositorySetsStatus(state));
  const {
    selectOne, isSelected, searchQuery, selectedCount, isSelectable,
    updateSearchQuery, selectNone, fetchBulkParams, ...selectAll
  } = useBulkSelect({
    results,
    metadata,
    isSelectable: () => false,
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

  const updateResults = ({ labels, enabled, newResponse }) => dispatch({
    type: `${REPOSITORY_SETS_KEY}_SUCCESS`,
    key: REPOSITORY_SETS_KEY,
    response: {
      ...response,
      results: results.map((result) => {
        if (labels.includes(result.label)) {
          const isEnabled = enabled === null ?
            newResponse.results.find(r => r.id === result.id).enabled :
            enabled;
          return { ...result, enabled: isEnabled, enabled_content_override: enabled };
        }
        return result;
      }),
    },
  });
  const overrideToEnabled = ({ labels }) =>
    dispatch(enableRepoSetRepo({ hostId, labels, updateResults }));
  const overrideToDisabled = ({ labels }) =>
    dispatch(disableRepoSetRepo({ hostId, labels, updateResults }));
  const resetToDefault = ({ labels }) =>
    dispatch(resetRepoSetRepo({ hostId, labels, updateResults }));

  // uncomment (and remove rule disablement) when Select All is added
  /* eslint-disable max-len */
  // const dropdownItems = [
  //   <DropdownItem aria-label="bulk_enable" key="bulk_enable" component="button" onClick={overrideToEnabled}>
  //     {__('Override to enabled')}
  //   </DropdownItem>,
  //   <DropdownItem aria-label="bulk_disable" key="bulk_disable" component="button" onClick={overrideToDisabled}>
  //     {__('Override to disabled')}
  //   </DropdownItem>,
  //   <DropdownItem aria-label="bulk_disable" key="bulk_disable" component="button" onClick={resetToDefault}>
  //     {__('Reset to default')}
  //   </DropdownItem>,
  // ];
  /* eslint-enable max-len */

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
          }
          }
          activeFilters={[toggleGroupState]}
          defaultFilters={[defaultToggleGroupState]}
          additionalListeners={[hostId, toggleGroupState]}
          fetchItems={fetchItems}
          autocompleteEndpoint="/repository_sets/auto_complete_search"
          bookmarkController="katello_product_contents" // Katello::ProductContent.table_name
          rowsCount={results?.length}
          variant={TableVariant.compact}
          {...selectAll}
          displaySelectAllCheckbox={false}
        >
          <Thead>
            <Tr>
              <Th key="select-all" />
              {columnHeaders.map(col =>
                <Th key={col}>{col}</Th>)}
              <Th />
              <Th key="action-menu" />
            </Tr>
          </Thead>
          <>
            {results?.map((repoSet, rowIndex) => {
              const {
                id,
                label,
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
                            onClick: () => overrideToDisabled({ labels: [label] }),
                          },
                          {
                            title: __('Override to enabled'),
                            isDisabled: isOverridden && isEnabled,
                            onClick: () => overrideToEnabled({ labels: [label] }),
                          },
                          {
                            title: __('Reset to default'),
                            isDisabled: !isOverridden,
                            onClick: () => resetToDefault({ labels: [label] }),
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
