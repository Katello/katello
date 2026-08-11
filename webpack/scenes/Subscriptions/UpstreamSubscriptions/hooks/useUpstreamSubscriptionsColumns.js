import React, { useMemo } from 'react';
import {
  FormGroup,
  TextInput,
  FormHelperText,
  HelperText,
  HelperTextItem,
} from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import quantityValidation from '../upstreamSubscriptionsHelpers';

const useUpstreamSubscriptionsColumns = ({
  getRowDataWithQuantity,
  quantityValidationInput,
  poolInSelectedRows,
  onChange,
  handleSaveUpstreamSubscriptions,
}) => useMemo(() => ({
  product_name: {
    title: __('Subscription Name'),
    wrapper: rowData => (
      <a
        href={`https://access.redhat.com/management/subscriptions/${rowData.subscription_id}`}
        rel="noopener noreferrer"
        target="_blank"
      >
        {rowData.product_name}
      </a>
    ),
  },
  contract_number: {
    title: __('Contract'),
  },
  start_date: {
    title: __('Start Date'),
  },
  end_date: {
    title: __('End Date'),
  },
  available: {
    title: __('Available Entitlements'),
    wrapper: rowData => (rowData.available === -1 ? __('Unlimited') : rowData.available),
  },
  quantity_to_allocate: {
    title: __('Quantity to Allocate'),
    wrapper: (rowData) => {
      const rowWithQuantity = getRowDataWithQuantity(rowData);
      const validationState = quantityValidationInput(rowWithQuantity);
      const selectedPool = poolInSelectedRows(rowData);

      return (
        <FormGroup>
          <TextInput
            ouiaId={`upstream-subscription-quantity-${rowData.id}`}
            className="upstream-subscriptions-quantity-input"
            type="text"
            aria-label={__('Number to Allocate')}
            value={selectedPool?.updatedQuantity ?? ''}
            validated={validationState || 'default'}
            onChange={(_event, value) => onChange(value, rowData)}
            onKeyDown={(event) => {
              if (event.key === 'Enter') {
                handleSaveUpstreamSubscriptions();
                event.preventDefault();
              }
            }}
          />
          {validationState === 'error' && (
            <FormHelperText className="upstream-subscriptions-quantity-helper-text">
              <HelperText>
                <HelperTextItem variant="error">
                  {quantityValidation(rowWithQuantity)[1]}
                </HelperTextItem>
              </HelperText>
            </FormHelperText>
          )}
        </FormGroup>
      );
    },
  },
}), [
  getRowDataWithQuantity,
  quantityValidationInput,
  poolInSelectedRows,
  onChange,
  handleSaveUpstreamSubscriptions,
]);

export default useUpstreamSubscriptionsColumns;
