import { translate as __ } from 'foremanReact/common/I18n';
import { filterRHSubscriptions } from './SubscriptionHelpers.js';

export const validateQuantity = (quantity, maxQuantity) => {
  let state;
  let message;

  const numberValue = Number(quantity);
  if (Number.isNaN(numberValue)) {
    state = 'error';
    message = __('Not a number');
  } else if (numberValue <= 0) {
    state = 'error';
    message = __('Has to be > 0');
  } else if (maxQuantity && maxQuantity >= 0 && numberValue > maxQuantity) {
    state = 'error';
    message = __('Exceeds available quantity');
  }
  return {
    state,
    message,
  };
};

export const recordsValid = rows =>
  filterRHSubscriptions(rows).every(row => validateQuantity(row.quantity, row.maxQuantity).state !== 'error');
