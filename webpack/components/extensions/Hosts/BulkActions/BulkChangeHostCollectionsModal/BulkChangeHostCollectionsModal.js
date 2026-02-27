import React, { useState, useCallback } from 'react';
import PropTypes from 'prop-types';
import { useDispatch } from 'react-redux';
import { FormattedMessage } from 'react-intl';
import {
  Modal,
  Button,
  Radio,
  TextContent,
  Text,
  ToolbarItem,
  Bullseye,
  EmptyState,
  EmptyStateBody,
  EmptyStateIcon,
  EmptyStateVariant,
  EmptyStateHeader,
  EmptyStateFooter,
} from '@patternfly/react-core';
import { Tr, Td } from '@patternfly/react-table';
import { ExclamationTriangleIcon, PlusCircleIcon } from '@patternfly/react-icons';
import { addToast } from 'foremanReact/components/ToastsList';
import { translate as __ } from 'foremanReact/common/I18n';
import { STATUS } from 'foremanReact/constants';
import { foremanUrl, noop } from 'foremanReact/common/helpers';
import { APIActions } from 'foremanReact/redux/API';
import {
  HOSTS_API_PATH,
  API_REQUEST_KEY,
} from 'foremanReact/routes/Hosts/constants';
import { useForemanOrganization } from 'foremanReact/Root/Context/ForemanContext';
import { useTableIndexAPIResponse, useSetParamsAndApiAndSearch } from 'foremanReact/components/PF4/TableIndexPage/Table/TableIndexHooks';
import { useBulkSelect } from 'foremanReact/components/PF4/TableIndexPage/Table/TableHooks';
import { getPageStats } from 'foremanReact/components/PF4/TableIndexPage/Table/helpers';
import TableIndexPage from 'foremanReact/components/PF4/TableIndexPage/TableIndexPage';
import { Table } from 'foremanReact/components/PF4/TableIndexPage/Table/Table';
import SelectAllCheckbox from 'foremanReact/components/PF4/TableIndexPage/Table/SelectAllCheckbox';
import {
  bulkAddHostCollections,
  bulkRemoveHostCollections,
} from './actions';
import katelloApi from '../../../../../services/api';

const BulkChangeHostCollectionsModal = ({
  isOpen,
  closeModal,
  fetchBulkParams,
  selectedCount: selectedHostsCount,
}) => {
  const dispatch = useDispatch();
  const [addRadioChecked, setAddRadioChecked] = useState(true);

  const orgId = useForemanOrganization()?.id;
  const DEFAULT_PER_PAGE = 5;
  const hostCollectionsUrlForOrg =
    katelloApi.getApiUrl(`/host_collections?per_page=${DEFAULT_PER_PAGE}&include_permissions=true&enabled=true&with_custom=true&organization_id=${orgId}`);
  const apiOptions = { key: 'BULK_HOST_COLLECTIONS' };
  const replacementResponse = isOpen ? false : { response: {} };

  const hostCollectionsResponse = useTableIndexAPIResponse({
    replacementResponse, // don't fetch data if modal is closed
    apiUrl: hostCollectionsUrlForOrg,
    apiOptions,
    defaultParams: { per_page: DEFAULT_PER_PAGE },
  });

  const {
    response: {
      results: hostCollectionsResults,
      ...hostCollectionsMetadata
    },
    setAPIOptions,
    status: hostCollectionsLoadingStatus,
  } = hostCollectionsResponse;

  const {
    total, page, subtotal, per_page: perPage,
  } = hostCollectionsMetadata;

  // Function to determine if a host collection row should be selectable
  const isSelectableRow = useCallback((hc) => {
    // When removing, all collections are selectable
    if (!addRadioChecked) return true;

    // When adding, check if there's enough space for the selected hosts
    if (hc?.unlimited_hosts) return true; // Unlimited collections always have space

    const currentHosts = Number(hc?.total_hosts || 0);
    const maxHosts = Number(hc?.max_hosts || 0);
    const availableSpace = maxHosts - currentHosts;

    // Collection is selectable only if it has enough space for all selected hosts
    return availableSpace >= selectedHostsCount;
  }, [addRadioChecked, selectedHostsCount]);

  const hostCollectionsBulkSelect = useBulkSelect({
    results: hostCollectionsResults,
    metadata: { total, page, selectable: subtotal },
    isSelectable: isSelectableRow,
  });

  const {
    setParamsAndAPI: setHostCollectionsParamsAndAPI,
  } = useSetParamsAndApiAndSearch({
    defaultParams: { search: '' },
    apiOptions,
    setAPIOptions,
    updateSearchQuery: hostCollectionsBulkSelect.updateSearchQuery,
    pushToHistory: false,
  });

  const {
    selectNone,
    selectOne,
    selectPage,
    isSelected,
    selectedCount,
    selectedResults,
    areAllRowsSelected,
    areAllRowsOnPageSelected,
    updateSearchQuery,
  } = hostCollectionsBulkSelect;

  const pageStats = getPageStats({ total: subtotal, page, perPage });

  // Handler for switching between Add/Remove modes
  const handleRadioChange = (isAdd) => {
    setAddRadioChecked(isAdd);

    // If switching to "Add" mode, deselect any collections that don't have enough space
    if (isAdd) {
      selectedResults.forEach((hc) => {
        if (!isSelectableRow(hc)) {
          selectOne(false, hc.id);
        }
      });
    }
  };

  // Derive selected IDs directly from selectedResults instead of storing in state
  const HCIds = selectedResults.map(result => result.id);

  const handleModalClose = () => {
    setAddRadioChecked(true);
    selectNone();
    setHostCollectionsParamsAndAPI({ page: 1 });
    closeModal();
  };

  const handleError = (error) => {
    const message = error?.response?.data?.error?.message || __('An error occurred while updating host collections');
    dispatch(addToast({ type: 'danger', message }));
  };

  const handleSuccess = (response) => {
    const messages = response?.data?.displayMessages;
    const message = Array.isArray(messages) && messages.length > 0
      ? (
        <>
          {messages.map(msg => (
            <div key={msg}>{msg}</div>
          ))}
        </>
      )
      : __('Host collections updated');

    dispatch(addToast({ type: 'success', message }));
    dispatch(APIActions.get({
      key: API_REQUEST_KEY,
      url: foremanUrl(HOSTS_API_PATH),
    }));
    handleModalClose();
  };

  const handleSave = () => {
    const requestBody = {
      included: {
        search: fetchBulkParams(),
      },
      host_collection_ids: HCIds,
      organization_id: orgId,
    };

    if (addRadioChecked) {
      dispatch(bulkAddHostCollections(requestBody, handleSuccess, handleError));
    } else {
      dispatch(bulkRemoveHostCollections(requestBody, handleSuccess, handleError));
    }
  };

  const isLoadingHostCollections = hostCollectionsLoadingStatus === STATUS.PENDING;

  const hasSearchQuery = !!hostCollectionsMetadata?.search;

  const hasNoResults = !hostCollectionsResults || hostCollectionsResults.length === 0;
  const customEmptyState =
    !isLoadingHostCollections && !hasSearchQuery && hasNoResults ? (
      <Tr ouiaId="table-empty">
        <Td colSpan={100}>
          <Bullseye>
            <EmptyState variant={EmptyStateVariant.sm}>
              <EmptyStateIcon icon={PlusCircleIcon} />
              <EmptyStateHeader titleText={<>{__('No host collections yet')}</>} headingLevel="h2" />
              <EmptyStateBody>
                {__('To get started, create a host collection.')}
              </EmptyStateBody>
              <EmptyStateFooter>
                <Button
                  ouiaId="create-host-collection-button"
                  variant="primary"
                  component="a"
                  href="/host_collections/new"
                >
                  {__('Create host collection')}
                </Button>
              </EmptyStateFooter>
            </EmptyState>
          </Bullseye>
        </Td>
      </Tr>
    ) : null;

  const isSaveDisabled = HCIds.length === 0 || isLoadingHostCollections;

  // Selection toolbar
  const selectionToolbar = (
    <ToolbarItem key="selectAll">
      <SelectAllCheckbox
        {...{
          selectAll: noop,
          selectOne,
          updateSearchQuery,
          selectNone,
          selectPage,
          selectedCount,
          pageRowCount: pageStats.pageRowCount,
          areAllRowsSelected,
          areAllRowsOnPageSelected,
        }}
        totalCount={total}
        areAllRowsOnPageSelected={areAllRowsOnPageSelected()}
        areAllRowsSelected={areAllRowsSelected()}
      />
    </ToolbarItem>
  );

  const modalActions = [
    <Button
      key="save"
      ouiaId="bulk-change-host-collections-modal-save-button"
      variant="primary"
      onClick={handleSave}
      isDisabled={isSaveDisabled}
      isLoading={isLoadingHostCollections}
    >
      {__('Save')}
    </Button>,
    <Button
      key="cancel"
      ouiaId="bulk-change-host-collections-modal-cancel-button"
      variant="link"
      onClick={handleModalClose}
    >
      {__('Cancel')}
    </Button>,
  ];

  const columns = {
    name: {
      title: __('Host collection'),
      wrapper: hc => hc?.name || '',
      isSorted: true,
      weight: 50,
    },
    limit: {
      title: __('Limit'),
      wrapper: (hc) => {
        const totalLimit = hc?.unlimited_hosts ? 'unlimited' : (hc?.max_hosts || 0);
        const count = Number(hc?.total_hosts || 0);
        const maxHosts = Number(hc?.max_hosts || 0);
        const availableSpace = maxHosts - count;

        // Show warning if collection doesn't have enough space for selected hosts (when adding)
        const showWarning = addRadioChecked
          && !hc?.unlimited_hosts
          && availableSpace < selectedHostsCount;

        return (
          <>
            {showWarning && (
              <ExclamationTriangleIcon
                color="var(--pf-v5-global--warning-color--100)"
                style={{ marginRight: '8px' }}
                aria-label={__('Insufficient space for selected hosts')}
              />
            )}
            {`${count}/${totalLimit}`}
          </>
        );
      },
      isSorted: false,
      weight: 100,
    },
    description: {
      title: __('Description'),
      wrapper: hc => hc?.description || '',
      isSorted: false,
      weight: 150,
    },
  };

  return (
    <Modal
      isOpen={isOpen}
      onClose={handleModalClose}
      onEscapePress={handleModalClose}
      title={__('Change host collections')}
      width="60%"
      position="top"
      actions={modalActions}
      id="bulk-update-host-collections-modal"
      key="bulk-update-host-collections-modal"
      ouiaId="bulk-update-host-collections-modal"
    >
      <TextContent>
        <Text ouiaId="bulk-update-host-collections-text">
          <FormattedMessage
            defaultMessage={__('Select host collections to change their associations with {selectedHosts}. Changing host collection will affect all your selected hosts. Some hosts may already be in your chosen collections.')}
            values={{
              selectedHosts: (
                <strong>
                  <FormattedMessage
                    defaultMessage="{count, plural, one {# {singular}} other {# {plural}}}"
                    values={{
                      count: selectedHostsCount,
                      singular: __('selected host'),
                      plural: __('selected hosts'),
                    }}
                    id="bulk-change-host-collections-selected-hosts"
                  />
                </strong>
              ),
            }}
            id="bulk-change-host-collections-description"
          />
        </Text>
      </TextContent>
      <h3><strong>{__('Select action')}</strong></h3>
      <div style={{ display: 'flex', alignItems: 'baseline' }}>
        <Radio
          isChecked={addRadioChecked}
          onChange={(_e, checked) => handleRadioChange(checked)}
          name="radio-add"
          label={__('Add to host collections')}
          id="radio-add-action"
          ouiaId="radio-add-action"
        />
        <Radio
          isChecked={!addRadioChecked}
          onChange={(_e, checked) => handleRadioChange(!checked)}
          name="radio-remove"
          label={__('Remove from host collections')}
          id="radio-remove-action"
          ouiaId="radio-remove-action"
          style={{ marginLeft: '50px' }}
          isDisabled={!hostCollectionsResults?.length}
        />
      </div>
      <div>
        <TableIndexPage
          selectionToolbar={selectionToolbar}
          results={hostCollectionsResults}
          metadata={hostCollectionsMetadata}
          response={hostCollectionsResponse}
          tableType="host_collections"
          apiUrl={hostCollectionsUrlForOrg}
          apiOptions={apiOptions}
          selectedCount={selectedCount}
          selectPage={selectPage}
          selectNone={selectNone}
          customSearchProps={{
            autocomplete: {
              url: katelloApi.getApiUrl('/host_collections/auto_complete_search'),
            },
          }}
          bulkSelect={hostCollectionsBulkSelect}
          updateParamsByUrl={false}
          isSelectableRow={isSelectableRow}
        >
          <Table
            showCheckboxes
            selectOne={selectOne}
            isSelected={isSelected}
            isSelectable={isSelectableRow}
            isEmbedded
            idColumn="id"
            columns={columns}
            refreshData={noop}
            url=""
            results={hostCollectionsResults}
            isPending={hostCollectionsLoadingStatus === STATUS.PENDING}
            params={{ ...hostCollectionsMetadata, perPage, page }}
            setParams={setHostCollectionsParamsAndAPI}
            page={page}
            perPage={perPage}
            itemCount={subtotal}
            customEmptyState={customEmptyState}
          />
        </TableIndexPage>
      </div>
    </Modal>
  );
};

BulkChangeHostCollectionsModal.propTypes = {
  isOpen: PropTypes.bool,
  closeModal: PropTypes.func,
  fetchBulkParams: PropTypes.func,
  selectedCount: PropTypes.number,
};

BulkChangeHostCollectionsModal.defaultProps = {
  isOpen: false,
  closeModal: () => {},
  fetchBulkParams: () => '',
  selectedCount: 0,
};

export default BulkChangeHostCollectionsModal;
