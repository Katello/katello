import React, { useMemo, useCallback, useEffect, useRef } from 'react';
import PropTypes from 'prop-types';
import {
  Button,
  Checkbox,
  FormGroup,
  FormHelperText,
  HelperText,
  HelperTextItem,
  Spinner,
  TextInput,
  ToolbarItem,
} from '@patternfly/react-core';
import { AngleDownIcon, AngleRightIcon } from '@patternfly/react-icons';
import { Tr, Td } from '@patternfly/react-table';
import TableIndexPage from 'foremanReact/components/PF4/TableIndexPage/TableIndexPage';
import { Table as TableIndexTable } from 'foremanReact/components/PF4/TableIndexPage/Table/Table';
import {
  useTableIndexAPIResponse,
  useSetParamsAndApiAndSearch,
} from 'foremanReact/components/PF4/TableIndexPage/Table/TableIndexHooks';
import { translate as __, sprintf } from 'foremanReact/common/I18n';
import { STATUS } from 'foremanReact/constants';
import { noop } from 'foremanReact/common/helpers';
import EmptyState from 'foremanReact/components/common/EmptyState';
import { orgId } from '../../../../../services/api';
import { SUBSCRIPTIONS_TABLE_KEY } from '../../../SubscriptionConstants';
import { validateQuantity } from '../../../SubscriptionValidations';
import { getEntitlementsDisplayValue } from '../SubscriptionsTableHelpers';

const SUBSCRIPTIONS_API_URL = '/katello/api/v2/subscriptions';

const renderEntitlementsCell = (rowData, rowIndex, inlineEditController) => {
  const additionalData = { rowData, rowIndex };
  const {
    hasChanged, onChange, onActivate, isEditing,
  } = inlineEditController;
  const value = rowData.quantity;

  if (isEditing(additionalData)) {
    const {
      upstreamAvailable, upstreamAvailableLoaded, maxQuantity,
    } = rowData;

    const className = hasChanged(additionalData)
      ? 'editable editing changed'
      : 'editable editing';

    let maxMessage;
    if (maxQuantity && upstreamAvailableLoaded && (upstreamAvailable !== undefined)) {
      maxMessage = (upstreamAvailable < 0)
        ? __('Unlimited')
        : sprintf(__('Max %(maxQuantity)s'), { maxQuantity });
    }

    const validation = validateQuantity(value, maxQuantity);

    const formGroup = !upstreamAvailableLoaded ? (
      <Spinner size="sm" />
    ) : (
      <FormGroup>
        <TextInput
          type="text"
          defaultValue={value}
          validated={validation.state}
          onChange={(_event, newValue) => onChange(newValue, additionalData)}
          ouiaId={`edit-entitlements-${rowData.id ?? rowIndex}`}
        />
        <FormHelperText>
          <HelperText>
            <HelperTextItem variant={validation.state}>
              {maxMessage}
              <div className="validationMessages">
                {validation.message}
              </div>
            </HelperTextItem>
          </HelperText>
        </FormHelperText>
      </FormGroup>
    );

    return (
      <Td key="quantity" dataLabel={__('Entitlements')} className={className}>
        {formGroup}
      </Td>
    );
  }

  const displayValue = getEntitlementsDisplayValue({
    quantity: value,
    collapsible: rowData.collapsible,
  });
  const editable = (typeof displayValue === 'number' && !rowData.expired);

  return (
    <Td key="quantity" dataLabel={__('Entitlements')} className={editable ? 'editable' : undefined}>
      {editable ? (
        <div
          onClick={() => onActivate(additionalData)}
          onKeyDown={(e) => {
            if (e.key === 'Enter' || e.key === ' ') {
              e.preventDefault();
              onActivate(additionalData);
            }
          }}
          className="input"
          role="button"
          aria-label={__('Edit entitlements')}
          tabIndex={0}
        >
          {displayValue}
        </div>
      ) : displayValue}
    </Td>
  );
};

const renderSubscriptionRows = ({
  columnKeys,
  columns,
  rows,
  bodyMessage,
  groupingController,
  selectionController,
  selectionEnabled,
  inlineEditController,
}) => {
  if (bodyMessage) {
    return (
      <Tr ouiaId="subscriptions-table-body-message">
        <Td colSpan={columnKeys.length}>{bodyMessage}</Td>
      </Tr>
    );
  }

  return rows.map((rowData, rowIndex) => {
    const additionalData = { rowData, rowIndex };
    const isGenericRow = rowData.collapsible;
    const shouldShowCollapse = groupingController.isCollapseable(additionalData);
    const disabled = !selectionEnabled || !rowData.upstream_pool_id;

    return (
      <Tr
        key={rowData.id ?? rowIndex}
        ouiaId={`subscriptions-table-row-${rowData.id ?? rowIndex}`}
        className={!groupingController.isCollapsed(additionalData) ? 'open-grouped-row' : ''}
      >
        {columnKeys.map((key) => {
          if (key === 'select') {
            return (
              <Td key="select" dataLabel={__('Select row')} className="subscriptions-table-select">
                <div className="subscriptions-table-select-cell">
                  {shouldShowCollapse && (
                    <Button
                      ouiaId={`collapse-subscription-group-${rowData.id ?? rowIndex}`}
                      variant="plain"
                      className="collapse-subscription-group-button"
                      onClick={() => groupingController.toggle(additionalData)}
                      aria-label={
                        groupingController.isCollapsed(additionalData)
                          ? __('Expand group')
                          : __('Collapse group')
                      }
                      icon={
                        groupingController.isCollapsed(additionalData)
                          ? <AngleRightIcon />
                          : <AngleDownIcon />
                      }
                    />
                  )}
                  {!isGenericRow && (
                    <Checkbox
                      ouiaId={`select-subscription-row-${rowData.id ?? rowIndex}`}
                      id={`select${rowIndex}`}
                      isChecked={selectionController.isSelected(additionalData)}
                      onChange={() => selectionController.selectRow(additionalData)}
                      isDisabled={disabled}
                      aria-label={__('Select row')}
                    />
                  )}
                </div>
              </Td>
            );
          }

          if (key === 'quantity') {
            return renderEntitlementsCell(rowData, rowIndex, inlineEditController);
          }

          const column = columns[key];
          const content = column?.wrapper ? column.wrapper(rowData) : rowData[key];

          return (
            <Td key={key} dataLabel={column?.title}>
              {content}
            </Td>
          );
        })}
      </Tr>
    );
  });
};

const extractMissingPermissions = (status, response) => {
  if (status !== STATUS.ERROR) {
    return undefined;
  }

  const error = response;
  const errors = error?.response?.data?.errors;
  const explicitMissingPermissions =
    (Array.isArray(errors) && errors[0]?.missing_permissions) ||
    error?.response?.data?.missing_permissions;
  const statusCode = error?.response?.status;
  let errorMessages = [];
  if (error?.response?.data?.displayMessage) {
    errorMessages = [error.response.data.displayMessage];
  } else if (Array.isArray(errors)) {
    errorMessages = errors.filter(e => typeof e === 'string');
  }

  let missingPermissions = explicitMissingPermissions;
  if (!missingPermissions && (statusCode === 403 || statusCode === 404)) {
    missingPermissions = errorMessages.length > 0 ? errorMessages : ['view_subscriptions'];
  }
  return missingPermissions;
};

const Table = ({
  emptyState,
  tableColumns,
  columns,
  searchQuery,
  organizationId,
  availableQuantities,
  selectionController,
  inlineEditController,
  rows,
  editing,
  selectionEnabled,
  groupedSubscriptions,
  toggleSubscriptionGroup,
  customHeader,
  customToolbar,
  onApiResponse,
  onRefreshReady,
}) => {
  const lastNotifiedRef = useRef(null);

  const persistentParams = useMemo(() => ({
    organization_id: organizationId || orgId(),
    ...(searchQuery ? { search: searchQuery } : {}),
  }), [organizationId, searchQuery]);

  const defaultParams = useMemo(() => ({
    page: 1,
    per_page: 20,
    ...persistentParams,
  }), [persistentParams]);

  const apiOptions = useMemo(() => ({ key: SUBSCRIPTIONS_TABLE_KEY }), []);

  const originalResponse = useTableIndexAPIResponse({
    apiUrl: SUBSCRIPTIONS_API_URL,
    apiOptions,
    defaultParams,
  });

  const {
    response: apiResponse = {},
    status = STATUS.PENDING,
    setAPIOptions,
  } = originalResponse;

  const wrappedSetAPIOptions = useCallback((options) => {
    setAPIOptions({
      ...options,
      params: {
        ...persistentParams,
        ...options?.params,
      },
    });
  }, [setAPIOptions, persistentParams]);

  // Refetch when org or search changes
  useEffect(() => {
    wrappedSetAPIOptions({ ...apiOptions, params: defaultParams });
  }, [searchQuery, organizationId]); // eslint-disable-line react-hooks/exhaustive-deps

  useEffect(() => {
    if (onRefreshReady) {
      onRefreshReady(() => wrappedSetAPIOptions({ ...apiOptions, params: defaultParams }));
    }
  }, [onRefreshReady, wrappedSetAPIOptions, apiOptions, defaultParams]);

  useEffect(() => {
    if (!onApiResponse) {
      return;
    }
    const quantitiesKey = JSON.stringify(availableQuantities);
    const notifyKey = `${status}:${apiResponse?.page}:${apiResponse?.subtotal}:${(apiResponse?.results || []).length}:${quantitiesKey}`;
    if (lastNotifiedRef.current === notifyKey) {
      return;
    }
    lastNotifiedRef.current = notifyKey;

    const missingPermissions = extractMissingPermissions(status, apiResponse);
    onApiResponse({
      results: apiResponse.results || [],
      page: Number(apiResponse.page) || 1,
      perPage: Number(apiResponse.per_page) || 20,
      itemCount: Number(apiResponse.subtotal) || 0,
      loading: status === STATUS.PENDING,
      searchIsActive: !!searchQuery,
      availableQuantities,
      missingPermissions,
      activePermissions: {
        can_import_manifest: apiResponse.can_import_manifest,
        can_delete_manifest: apiResponse.can_delete_manifest,
        can_manage_subscription_allocations: apiResponse.can_manage_subscription_allocations,
        can_edit_organizations: apiResponse.can_edit_organizations,
      },
    });
  }, [apiResponse, status, searchQuery, availableQuantities, onApiResponse]);

  let bodyMessage;
  if ((apiResponse.results || []).length === 0 && searchQuery) {
    bodyMessage = __('No subscriptions match your search criteria.');
  }

  const groupingController = {
    isCollapseable: ({ rowData }) => rowData.collapsible,
    isCollapsed: ({ rowData }) => !groupedSubscriptions[rowData.product_id]?.open,
    toggle: ({ rowData }) => toggleSubscriptionGroup(rowData.product_id),
  };

  const collapsibleGroup =
    Object.values(groupedSubscriptions || {}).some(v => v.subscriptions.length > 1);

  const showSelectColumn = selectionEnabled || collapsibleGroup;

  const visibleColumns = useMemo(() => {
    const nextColumns = {};

    if (showSelectColumn) {
      nextColumns.select = {
        title: (
          <div className="subscriptions-table-select-cell">
            <Checkbox
              ouiaId="select-all-subscriptions"
              id="selectAll"
              aria-label={__('Select all rows')}
              isChecked={selectionController.allRowsSelected()}
              onChange={() => selectionController.selectAllRows()}
              isDisabled={!selectionEnabled}
            />
          </div>
        ),
      };
    }

    Object.keys(columns).forEach((key) => {
      if (tableColumns.includes(key)) {
        nextColumns[key] = columns[key];
      }
    });

    return nextColumns;
  }, [columns, tableColumns, showSelectColumn, selectionController, selectionEnabled]);

  const columnKeys = useMemo(() => Object.keys(visibleColumns), [visibleColumns]);

  const replacementResponse = useMemo(() => ({
    response: {
      results: rows,
      subtotal: apiResponse.subtotal,
      // TableIndexPage shows top pagination when total > 0; keep only bottom pagination
      total: 0,
      page: apiResponse.page || 1,
      per_page: apiResponse.per_page || 20,
    },
    status: status === STATUS.PENDING ? STATUS.PENDING : STATUS.RESOLVED,
    setAPIOptions: wrappedSetAPIOptions,
  }), [rows, apiResponse, status, wrappedSetAPIOptions]);

  const response = useTableIndexAPIResponse({
    replacementResponse,
    apiUrl: SUBSCRIPTIONS_API_URL,
    apiOptions,
    defaultParams,
  });

  const {
    response: {
      page,
      per_page: perPage,
      subtotal,
    } = {},
    setAPIOptions: setAPIOptionsFromResponse,
  } = response;

  const { setParamsAndAPI, params } = useSetParamsAndApiAndSearch({
    defaultParams: {
      page: page || defaultParams.page,
      per_page: perPage || defaultParams.per_page,
      ...persistentParams,
    },
    apiOptions,
    setAPIOptions: setAPIOptionsFromResponse,
    pushToHistory: false,
  });

  const showCustomEmptyState = rows.length === 0 && !bodyMessage && emptyState;
  const isPending = status === STATUS.PENDING;

  const customToolbarItems = editing ? (
    <>
      <ToolbarItem>
        <Button
          ouiaId="confirm-subscription-edit-button"
          variant="primary"
          onClick={inlineEditController.onConfirm}
        >
          {__('Confirm')}
        </Button>
      </ToolbarItem>
      <ToolbarItem>
        <Button
          ouiaId="cancel-subscription-edit-button"
          variant="link"
          onClick={inlineEditController.onCancel}
        >
          {__('Cancel')}
        </Button>
      </ToolbarItem>
    </>
  ) : null;

  return (
    <TableIndexPage
      header={__('Subscriptions')}
      customHeader={customHeader}
      beforeToolbarComponent={customToolbar}
      apiUrl={SUBSCRIPTIONS_API_URL}
      apiOptions={apiOptions}
      columns={visibleColumns}
      replacementResponse={response}
      searchable={false}
      creatable={false}
      updateParamsByUrl={false}
      customToolbarItems={customToolbarItems}
      customEmptyState={showCustomEmptyState ? <EmptyState {...emptyState} /> : null}
      emptyMessage={bodyMessage}
      ouiaId="subscriptions-table"
    >
      <TableIndexTable
        columns={visibleColumns}
        results={rows}
        params={{
          ...params,
          page: page || params.page,
          perPage: perPage || params.per_page,
        }}
        setParams={setParamsAndAPI}
        itemCount={subtotal ?? apiResponse.subtotal}
        refreshData={noop}
        url={SUBSCRIPTIONS_API_URL}
        isPending={isPending}
        isEmbedded
        ouiaId="subscriptions-table"
      >
        {renderSubscriptionRows({
          columnKeys,
          columns: visibleColumns,
          rows,
          bodyMessage,
          groupingController,
          selectionController,
          selectionEnabled,
          inlineEditController,
        })}
      </TableIndexTable>
    </TableIndexPage>
  );
};

Table.propTypes = {
  emptyState: PropTypes.shape({}).isRequired,
  tableColumns: PropTypes.arrayOf(PropTypes.string).isRequired,
  columns: PropTypes.objectOf(PropTypes.shape({
    title: PropTypes.node,
    wrapper: PropTypes.func,
  })).isRequired,
  searchQuery: PropTypes.string,
  organizationId: PropTypes.oneOfType([PropTypes.number, PropTypes.string]),
  availableQuantities: PropTypes.shape({}),
  toggleSubscriptionGroup: PropTypes.func.isRequired,
  selectionController: PropTypes.shape({
    allRowsSelected: PropTypes.func,
    selectAllRows: PropTypes.func,
    isSelected: PropTypes.func,
    selectRow: PropTypes.func,
  }).isRequired,
  inlineEditController: PropTypes.shape({
    onCancel: PropTypes.func,
    onConfirm: PropTypes.func,
  }).isRequired,
  groupedSubscriptions: PropTypes.shape({}),
  editing: PropTypes.bool.isRequired,
  rows: PropTypes.arrayOf(PropTypes.shape({})).isRequired,
  selectionEnabled: PropTypes.bool.isRequired,
  customHeader: PropTypes.node,
  customToolbar: PropTypes.node,
  onApiResponse: PropTypes.func,
  onRefreshReady: PropTypes.func,
};

Table.defaultProps = {
  searchQuery: '',
  organizationId: undefined,
  availableQuantities: null,
  customHeader: undefined,
  customToolbar: undefined,
  groupedSubscriptions: {},
  onApiResponse: undefined,
  onRefreshReady: undefined,
};

export default Table;
