import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';
import { useSelector, useDispatch } from 'react-redux';
import { FormattedMessage } from 'react-intl';
import {
  Modal,
  Button,
  Alert,
  TextContent,
  Text,
  ActionList,
  ActionListItem,
  ToolbarItem,
} from '@patternfly/react-core';
import {
  Dropdown,
  DropdownItem,
  DropdownToggle,
  DropdownToggleAction,
} from '@patternfly/react-core/deprecated';
import { ExclamationTriangleIcon } from '@patternfly/react-icons';
import { translate as __ } from 'foremanReact/common/I18n';
import { noop } from 'foremanReact/common/helpers';
import { useAPI } from 'foremanReact/common/hooks/API/APIHooks';
import TableIndexPage from 'foremanReact/components/PF4/TableIndexPage/TableIndexPage';
import SelectAllCheckbox from 'foremanReact/components/PF4/TableIndexPage/Table/SelectAllCheckbox';
import { RowSelectTd } from 'foremanReact/components/HostsIndex/RowSelectTd';
import { getPageStats } from 'foremanReact/components/PF4/TableIndexPage/Table/helpers';
import { useBulkSelect } from 'foremanReact/components/PF4/TableIndexPage/Table/TableHooks';
import { resolveBulkTraces } from './BulkManageTracesActions';
import { BULK_TRACES_KEY } from './BulkManageTracesConstants';
import { resolveTraceUrl } from '../../../HostDetails/Tabs/customizedRexUrlHelpers';
import { foremanApi } from '../../../../../services/api';

const containsStaticType = (results = []) => results.some(result => result.app_type === 'static');

const BulkManageTracesModal = ({
  isOpen,
  closeModal,
  selectedCount: hostsSelectedCount,
  orgId,
  fetchBulkParams,
}) => {
  const dispatch = useDispatch();
  const [isBulkActionOpen, setIsBulkActionOpen] = useState(false);
  const toggleBulkAction = () => setIsBulkActionOpen(prev => !prev);

  const bulkTracesUrl = foremanApi.getApiUrl('/hosts/bulk/traces');

  // Get API state from Redux - includes both response and status
  const apiState = useSelector(state => state.API?.[BULK_TRACES_KEY]);
  const apiResponse = apiState?.response;
  const apiStatus = apiState?.status;

  // Only call useAPI if we don't already have data (avoids overriding mocked test data)
  const shouldFetch = isOpen && fetchBulkParams && apiResponse?.results === undefined;

  // Fetch traces when modal opens using Foreman's useAPI hook
  const { setAPIOptions } = useAPI(
    shouldFetch ? 'post' : null,
    bulkTracesUrl,
    {
      key: BULK_TRACES_KEY,
    },
  );

  // Update API options when modal opens with fresh params
  // Only fetch if we don't already have results (prevents refetch in tests with mocked data)
  useEffect(() => {
    if (isOpen && fetchBulkParams && apiResponse?.results === undefined) {
      const searchQuery = fetchBulkParams();
      const bulkTracesParams = {
        organization_id: orgId,
        included: {
          search: searchQuery,
        },
      };
      setAPIOptions({ params: bulkTracesParams });
    }
  }, [isOpen, fetchBulkParams, orgId, setAPIOptions, apiResponse]);

  // Wrap replacementResponse in the structure that TableIndexPage expects from useAPI
  // Only provide when we have data, otherwise let TableIndexPage handle the API call
  const replacementResponse = (isOpen && apiResponse) ? {
    response: apiResponse,
    status: apiStatus || 'PENDING',
    setAPIOptions,
  } : undefined;

  const {
    results = [], total = 0, per_page: perPage = 20, page = 1, subtotal = 0,
  } = apiResponse || {};

  const {
    selectOne,
    isSelected,
    selectedCount: tracesSelectedCount,
    selectPage,
    selectNone,
    areAllRowsSelected,
    areAllRowsOnPageSelected,
    selectedResults,
    hasInteracted,
  } = useBulkSelect({
    results,
    metadata: apiResponse || { total: 0, subtotal: 0, selectable: 0 },
    isSelectable: result => result.app_type !== 'session',
    initialSearchQuery: '',
  });

  const willRestartHost = containsStaticType(selectedResults);

  const handleModalClose = () => {
    selectNone();
    closeModal();
  };

  const handleRestart = () => {
    const traceIds = selectedResults.map(trace => trace.id);
    dispatch(resolveBulkTraces({
      traceIds,
      bulkParams: {
        organization_id: orgId,
        included: {
          search: fetchBulkParams(),
        },
      },
    }));
    handleModalClose();
  };

  const customizedRexUrl = () => {
    if (tracesSelectedCount === 0) return '#';
    const traceIds = selectedResults.map(trace => trace.id);
    const traceSearch = `id ^ (${traceIds.join(',')})`;
    return resolveTraceUrl({
      hostSearch: fetchBulkParams(),
      search: traceSearch,
    });
  };

  const dropdownItems = [
    <DropdownItem
      isDisabled={tracesSelectedCount === 0}
      aria-label="bulk_rex_customized"
      ouiaId="bulk_rex_customized"
      key="bulk_rex_customized"
      component="a"
      href={customizedRexUrl()}
    >
      {__('Customize and restart')}
    </DropdownItem>,
  ];

  const primaryButtonText = willRestartHost
    ? __('Reboot hosts')
    : (
      <FormattedMessage
        defaultMessage="{count, plural, one {Restart} other {Restart}}"
        values={{ count: hostsSelectedCount }}
        id="bulk-traces-restart-button"
      />
    );

  const modalActions = [
    <ActionList key="action-list" isIconList>
      <ActionListItem>
        <Dropdown
          aria-label="bulk_restart_dropdown"
          ouiaId="bulk_restart_dropdown"
          toggle={
            <DropdownToggle
              aria-label="bulk_restart"
              ouiaId="bulk_restart"
              splitButtonItems={[
                <DropdownToggleAction
                  key="action"
                  onClick={handleRestart}
                  isDisabled={tracesSelectedCount === 0}
                >
                  {primaryButtonText}
                </DropdownToggleAction>,
              ]}
              isDisabled={tracesSelectedCount === 0}
              splitButtonVariant="action"
              toggleVariant="primary"
              onToggle={toggleBulkAction}
            />
          }
          isOpen={isBulkActionOpen}
          dropdownItems={dropdownItems}
        />
      </ActionListItem>
    </ActionList>,
    <Button
      key="cancel"
      ouiaId="bulk-manage-traces-modal-cancel-button"
      variant="link"
      onClick={handleModalClose}
    >
      {__('Cancel')}
    </Button>,
  ];

  const pageStats = getPageStats({ total: subtotal, page, perPage });
  const selectionToolbar = (
    <ToolbarItem key="selectAll">
      <SelectAllCheckbox
        {...{
          selectNone,
          selectPage,
          selectedCount: tracesSelectedCount,
          pageRowCount: pageStats.pageRowCount,
          areAllRowsSelected,
          areAllRowsOnPageSelected,
        }}
        selectAll={noop}
        totalCount={total}
        areAllRowsOnPageSelected={areAllRowsOnPageSelected()}
        areAllRowsSelected={areAllRowsSelected()}
      />
    </ToolbarItem>
  );

  const columns = {
    application: {
      title: __('Application'),
      isSorted: true,
      weight: 40,
    },
    app_type: {
      title: __('Type'),
      weight: 20,
    },
    helper: {
      title: __('Helper'),
      wrapper: ({ app_type: appType, helper }) => (
        <>
          {appType === 'static' && <ExclamationTriangleIcon />}{' '}
          {helper}
        </>
      ),
      weight: 40,
    },
  };

  // Minimal customSearchProps to satisfy TableIndexPage's search bar requirements
  const customSearchProps = {
    controller: 'katello_host_tracers',
    autocomplete: {
      id: 'searchBar-traces',
      url: foremanApi.getApiUrl('/hosts/bulk/traces/auto_complete_search'),
      searchQuery: '',
    },
  };

  return (
    <Modal
      isOpen={isOpen}
      onClose={handleModalClose}
      onEscapePress={handleModalClose}
      title={__('Restart applications')}
      width="50%"
      position="top"
      actions={modalActions}
      id="bulk-manage-traces-modal"
      key="bulk-manage-traces-modal"
      ouiaId="bulk-manage-traces-modal"
    >
      <TextContent>
        <Text ouiaId="bulk-manage-traces-description">
          <FormattedMessage
            defaultMessage="Tracer has identified applications on {hosts} that need to be restarted to fully apply system patches. Select the applications you want to restart below."
            values={{
              hosts: (
                <strong>
                  <FormattedMessage
                    defaultMessage="{count, plural, one {# selected host} other {# selected hosts}}"
                    values={{ count: hostsSelectedCount }}
                    id="bulk-traces-selected-hosts"
                  />
                </strong>
              ),
            }}
            id="bulk-manage-traces-description-i18n"
          />
        </Text>
      </TextContent>
      {willRestartHost && (
        <Alert
          isInline
          variant="warning"
          ouiaId="hosts-will-reboot-alert"
          title={__('At least one of the selected items requires the hosts to reboot')}
          style={{ marginTop: '1rem', marginBottom: '1rem' }}
        />
      )}
      {tracesSelectedCount === 0 && hasInteracted && results.length > 0 && (
        <Alert
          ouiaId="no-traces-selected-alert"
          variant="info"
          isInline
          title={__('Select at least one trace.')}
          style={{ marginBottom: '1rem' }}
        />
      )}
      {isOpen && (
        <TableIndexPage
          header={__('Traces')}
          columns={columns}
          showCheckboxes
          apiUrl={foremanApi.getApiUrl('/hosts/bulk/traces')}
          apiOptions={{ key: BULK_TRACES_KEY }}
          customSearchProps={customSearchProps}
          creatable={false}
          replacementResponse={replacementResponse}
          selectionToolbar={selectionToolbar}
          rowSelectTd={RowSelectTd}
          selectOne={selectOne}
          isSelected={isSelected}
          isRowSelectable={result => result.app_type !== 'session'}
          updateParamsByUrl={false}
          emptyMessage={__('The selected hosts do not show any applications needing restart.')}
        />
      )}
    </Modal>
  );
};

BulkManageTracesModal.propTypes = {
  isOpen: PropTypes.bool,
  closeModal: PropTypes.func,
  selectedCount: PropTypes.number.isRequired,
  orgId: PropTypes.number.isRequired,
  fetchBulkParams: PropTypes.func.isRequired,
};

BulkManageTracesModal.defaultProps = {
  isOpen: false,
  closeModal: () => {},
};

export default BulkManageTracesModal;
