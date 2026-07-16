import React, { useMemo, useCallback } from 'react';
import PropTypes from 'prop-types';
import {
  Button,
  Checkbox,
  FormControl,
  FormGroup,
  HelpBlock,
  Spinner,
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
import { KEYCODES } from 'foremanReact/common/keyCodes';
import EmptyState from 'foremanReact/components/common/EmptyState';
import classNames from 'classnames';
import { createSubscriptionsTableSchema } from '../SubscriptionsTableSchema';
import { validateQuantity } from '../../../SubscriptionValidations';
import { getEntitlementsDisplayValue } from '../SubscriptionsTableHelpers';
import { useHistory } from 'react-router-dom';

const SUBSCRIPTIONS_API_URL = '/katello/api/v2/subscriptions';

const schemaCellToTd = (cell, column) => {
  if (React.isValidElement(cell) && cell.type === 'td') {
    const { children, className, ...tdProps } = cell.props;
    return (
      <Td
        key={column.property}
        dataLabel={column.header?.label}
        className={className}
        {...tdProps}
      >
        {children}
      </Td>
    );
  }

  if (React.isValidElement(cell)) {
    return (
      <Td key={column.property} dataLabel={column.header?.label}>
        {cell}
      </Td>
    );
  }

  return (
    <Td key={column.property} dataLabel={column.header?.label}>
      {cell}
    </Td>
  );
};

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
      <FormGroup validationState={validation.state}>
        <FormControl
          type="text"
          defaultValue={value}
          onBlur={e => onChange(e.target.value, additionalData)}
        />
        <HelpBlock>
          {maxMessage}
          <div className="validationMessages">
            {validation.message}
          </div>
        </HelpBlock>
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
          onKeyPress={(e) => {
            if (e.keyCode === KEYCODES.ENTER) {
              onActivate(additionalData);
            }
          }}
          className="input"
          role="textbox"
          tabIndex={0}
        >
          {displayValue}
        </div>
      ) : displayValue}
    </Td>
  );
};

const renderSubscriptionRows = ({
  columnsDefinition,
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
        <Td colSpan={columnsDefinition.length}>{bodyMessage}</Td>
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
        className={classNames({
          'open-grouped-row': !groupingController.isCollapsed(additionalData),
        })}
      >
        {columnsDefinition.map((column) => {
          if (column.property === 'select') {
            return (
              <Td key="select" dataLabel={__('Select all rows')}>
                {shouldShowCollapse && (
                  <Button
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
                    id={`select${rowIndex}`}
                    isChecked={selectionController.isSelected(additionalData)}
                    onChange={() => selectionController.selectRow(additionalData)}
                    isDisabled={disabled}
                    aria-label={__('Select row')}
                  />
                )}
              </Td>
            );
          }

          if (column.property === 'quantity') {
            return renderEntitlementsCell(rowData, rowIndex, inlineEditController);
          }

          const value = rowData[column.property];
          let cell = value;
          column.cell?.formatters?.forEach((formatter) => {
            cell = formatter(cell, additionalData);
          });

          return schemaCellToTd(cell, column);
        })}
      </Tr>
    );
  });
};

const Table = ({
  emptyState,
  tableColumns,
  subscriptions,
  loadSubscriptions,
  selectionController,
  inlineEditController,
  rows,
  editing,
  selectionEnabled,
  groupedSubscriptions,
  toggleSubscriptionGroup,
  customHeader,
  customToolbar,
}) => {
  const allSubscriptionResults = subscriptions.results;
  const history = useHistory();
  let bodyMessage;
  if (allSubscriptionResults.length === 0 && subscriptions.searchIsActive) {
    bodyMessage = __('No subscriptions match your search criteria.');
  }

  const groupingController = {
    isCollapseable: ({ rowData }) => rowData.collapsible,
    isCollapsed: ({ rowData }) => !groupedSubscriptions[rowData.product_id].open,
    toggle: ({ rowData }) => toggleSubscriptionGroup(rowData.product_id),
  };

  const collapsibleGroup =
    Object.values(groupedSubscriptions).some(v => v.subscriptions.length > 1);

  const alwaysDisplayColumns = [];

  if (selectionEnabled || collapsibleGroup) {
    alwaysDisplayColumns.push('select');
  }

  const columnsDefinition = createSubscriptionsTableSchema(
    inlineEditController,
    selectionController,
    groupingController,
    selectionEnabled,
  ).filter(column => tableColumns.includes(column.property) ||
    alwaysDisplayColumns.includes(column.property));

  const columns = useMemo(
    () => columnsDefinition.reduce((acc, column) => {
      if (column.property === 'select') {
        acc.select = {
          title: (
            <Checkbox
              id="selectAll"
              aria-label={__('Select all rows')}
              isChecked={selectionController.allRowsSelected()}
              onChange={() => selectionController.selectAllRows()}
              isDisabled={!selectionEnabled}
            />
          ),
        };
        return acc;
      }
      acc[column.property] = { title: column.header?.label || column.property };
      return acc;
    }, {}),
    [columnsDefinition, selectionController, selectionEnabled],
  );

  const setAPIOptions = useCallback((options) => {
    if (options?.params) {
      loadSubscriptions(options.params);
    }
  }, [loadSubscriptions]);

  const replacementResponse = useMemo(() => ({
    response: {
      results: rows,
      subtotal: subscriptions.itemCount,
      // TableIndexPage shows top pagination when total > 0; keep only bottom pagination
      total: 0,
      page: subscriptions.pagination?.page || 1,
      per_page: subscriptions.pagination?.perPage || subscriptions.pagination?.per_page || 20,
    },
    status: subscriptions.loading ? STATUS.PENDING : STATUS.RESOLVED,
    setAPIOptions,
  }), [rows, subscriptions, setAPIOptions]);

  const apiOptions = useMemo(() => ({ key: 'SUBSCRIPTIONS_TABLE' }), []);
  const defaultParams = useMemo(() => ({
    page: subscriptions.pagination?.page || 1,
    per_page: subscriptions.pagination?.perPage || subscriptions.pagination?.per_page || 20,
  }), [subscriptions.pagination]);

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
    },
    apiOptions,
    setAPIOptions: setAPIOptionsFromResponse,
    pushToHistory: false,
  });

  const showCustomEmptyState = rows.length === 0 && !bodyMessage && emptyState;

  const customToolbarItems = editing ? (
    <>
      <ToolbarItem>
        <Button variant="primary" onClick={inlineEditController.onConfirm}>
          {__('Confirm')}
        </Button>
      </ToolbarItem>
      <ToolbarItem>
        <Button variant="link" onClick={inlineEditController.onCancel}>
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
      customCreateAction={() => () => history.push(SUBSCRIPTIONS_API_URL)}
      apiOptions={apiOptions}
      columns={columns}
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
        columns={columns}
        results={rows}
        params={{
          ...params,
          page: page || params.page,
          perPage: perPage || params.per_page,
        }}
        setParams={setParamsAndAPI}
        itemCount={subtotal ?? subscriptions.itemCount}
        refreshData={noop}
        url={SUBSCRIPTIONS_API_URL}
        isPending={subscriptions.loading}
        isEmbedded
        ouiaId="subscriptions-table"
      >
        {renderSubscriptionRows({
          columnsDefinition,
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
  subscriptions: PropTypes.shape({
    searchIsActive: PropTypes.bool,
    itemCount: PropTypes.number,
    loading: PropTypes.bool,
    pagination: PropTypes.shape({}),
    // Disabling rule as existing code failed due to an eslint-plugin-react update
    // eslint-disable-next-line react/forbid-prop-types
    results: PropTypes.array,
  }).isRequired,
  loadSubscriptions: PropTypes.func.isRequired,
  toggleSubscriptionGroup: PropTypes.func.isRequired,
  selectionController: PropTypes.shape({}).isRequired,
  inlineEditController: PropTypes.shape({
    onCancel: PropTypes.func,
    onConfirm: PropTypes.func,
  }).isRequired,
  groupedSubscriptions: PropTypes.shape({}).isRequired,
  editing: PropTypes.bool.isRequired,
  rows: PropTypes.arrayOf(PropTypes.shape({})).isRequired,
  selectionEnabled: PropTypes.bool.isRequired,
  customHeader: PropTypes.node,
  customToolbar: PropTypes.node,
};

Table.defaultProps = {
  customHeader: undefined,
  customToolbar: undefined,
};

export default Table;
