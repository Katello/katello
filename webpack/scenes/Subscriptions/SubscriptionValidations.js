import { filterRHSubscriptions } from './SubscriptionHelpers.js';

export const validateQuantity = (quantity, availableQuantity) => {
  let state;
  let message;

  const numberValue = Number(quantity);
  if (Number.isNaN(numberValue)) {
    state = 'error';
    message = __('Not a number');
  } else if (numberValue <= 0) {
    state = 'error';
    message = __('Has to be > 0');
  } else if (availableQuantity && availableQuantity >= 0 && numberValue > availableQuantity) {
    state = 'error';
    message = __('Exceeds available quantity');
  }
  return {
    state,
    message,
  };
};

export const recordsValid = rows =>
  filterRHSubscriptions(rows).every(row => validateQuantity(row.quantity, row.availableQuantity).state !== 'error');
