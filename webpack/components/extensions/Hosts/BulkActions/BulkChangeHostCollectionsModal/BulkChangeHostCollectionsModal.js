import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';
import { useDispatch } from 'react-redux';
import {
  Modal,
  Button,
  Radio,
  TextContent,
  Text,
  ToolbarItem,
} from '@patternfly/react-core';
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
import { RowSelectTd } from 'foremanReact/components/HostsIndex/RowSelectTd';
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
}) => {
  const dispatch = useDispatch();
  const [HCIds, setHCIds] = useState([]);
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

  const hostCollectionsBulkSelect = useBulkSelect({
    results: hostCollectionsResults,
    metadata: { total, page, selectable: subtotal },
    idColumn: 'id',
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
    selectPage,
    selectNone,
    selectOne,
    isSelected,
    selectedCount,
    selectedResults,
    areAllRowsSelected,
    areAllRowsOnPageSelected,
    updateSearchQuery,
  } = hostCollectionsBulkSelect;

  const pageStats = getPageStats({ total: subtotal, page, perPage });

  // Update HCIds when selections change
  useEffect(() => {
    if (isOpen) {
      const selectedIds = selectedResults.map(result => result.id);
      setHCIds(selectedIds);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [selectedCount, isOpen]);

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

  const handleModalClose = () => {
    setHCIds([]);
    setAddRadioChecked(true);
    selectNone();
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
          {messages.map((msg, index) => (
            <div key={`host-status-${index}`}>{msg}</div>
          ))}
        </>
      )
      : __('Host collections updated successfully');

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
  const isSaveDisabled = HCIds.length === 0 || isLoadingHostCollections;

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
        const count = hc?.total_hosts || 0;
        return `${count}/${totalLimit}`;
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
          {__(`Select host collection(s) to change their associations with selected host(s).
            Changing host collection will affect all your selected hosts.
            Some hosts may already be in your chosen collection(s).`)}
        </Text>
      </TextContent>
      <h3><strong>{__('Select action')}</strong></h3>
      <div style={{ display: 'flex', alignItems: 'baseline' }}>
        <Radio
          isChecked={addRadioChecked}
          onChange={(_e, checked) => setAddRadioChecked(checked)}
          name="radio-add"
          label={__('Add to host collection(s)')}
          id="radio-add-action"
          ouiaId="radio-add-action"
        />
        <Radio
          isChecked={!addRadioChecked}
          onChange={(_e, checked) => setAddRadioChecked(!checked)}
          name="radio-remove"
          label={__('Remove from host collection(s)')}
          id="radio-remove-action"
          ouiaId="radio-remove-action"
          style={{ marginLeft: '50px' }}
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
        >
          <Table
            showCheckboxes
            rowSelectTd={RowSelectTd}
            selectOne={selectOne}
            isSelected={isSelected}
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
          />
        </TableIndexPage>
      </div>
    </Modal>
  );
};

BulkChangeHostCollectionsModal.propTypes = {
  isOpen: PropTypes.bool,
  closeModal: PropTypes.func,
  fetchBulkParams: PropTypes.func.isRequired,
};

BulkChangeHostCollectionsModal.defaultProps = {
  isOpen: false,
  closeModal: () => {},
};

export default BulkChangeHostCollectionsModal;
