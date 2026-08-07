import { translate as __, sprintf } from 'foremanReact/common/I18n';
import { stringIsPositiveNumber } from 'foremanReact/common/helpers';

const quantityValidation = (pool) => {
  const origQuantity = pool.updatedQuantity;

  if (origQuantity && stringIsPositiveNumber(origQuantity)) {
    const parsedQuantity = parseInt(origQuantity, 10);
    const aboveZeroMsg = [false, __('Please enter a positive number above zero')];

    if (parsedQuantity.toString().length > 10) {
      return [false, __('Please limit number to 10 digits')];
    }

    if (!pool.available) {
      return [false, __('No pools available')];
    }

    // handling unlimited subscriptions, they show as -1
    if (pool.available === -1) {
      return parsedQuantity ? [true, ''] : aboveZeroMsg;
    }

    if (parsedQuantity > pool.available) {
      return [false, sprintf(__('Quantity must not be above %s'), pool.available)];
    }

    if (parsedQuantity <= 0) {
      return aboveZeroMsg;
    }
  } else {
    return [false, __('Please enter digits only')];
  }

  return [true, ''];
};

export default quantityValidation;
