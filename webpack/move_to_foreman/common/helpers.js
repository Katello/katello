import { addToast } from 'foremanReact/redux/actions/toasts';
import { SUBSCRIPTIONS_QUANTITIES_FAILURE } from '../../scenes/Subscriptions/SubscriptionConstants';

const urlBuilder = (controller, action, id = undefined) =>
  `/${controller}/${id ? `${id}/` : ''}${action}`;

const urlWithSearch = (base, searchQuery) => `/${base}?search=${searchQuery}`;

const stringIsInteger = (value) => {
  // checking for positive integers only
  const reg = new RegExp('^[0-9]+$');
  return reg.test(value);
};


const getSubscriptionsErrorMessege = (message) => {
  const errorMessageHash = {
    '404 Not Found': __('The subscription cannot be found upstream'),
    '410 Gone': __('The subscription is no longer available'),
  };
  return errorMessageHash[message];
};

const getCustomMessage = (actionType, message) => {
  let customMessage;
  switch (actionType) {
    case SUBSCRIPTIONS_QUANTITIES_FAILURE:
      customMessage = getSubscriptionsErrorMessege(message);
      break;
    default:
      customMessage = null;
  }
  return customMessage;
};

export const getResponseErrorMsgs = ({ data, customErrorMessage, actionType }) => {
  if (data) {
    const customMessage = customErrorMessage || getCustomMessage(actionType, data.displayMessage);
    const messages =
      customMessage ||
      data.errors ||
      data.displayMessage ||
      data.message ||
      data.error;
    return Array.isArray(messages) ? messages : [messages];
  }
  return [];
};

export const apiError = (actionType, result, customErrorMessage) => (dispatch) => {
  const errorsData = { data: result.response.data, customErrorMessage, actionType };
  const messages = getResponseErrorMsgs(errorsData);
  dispatch({
    type: actionType,
    payload: {
      result,
      messages,
    },
  });
  messages.forEach((msg) => {
    dispatch(addToast({
      type: 'error',
      message: msg,
      sticky: true,
    }));
  });
};

export const KEY_CODES = {
  TAB_KEY: 9,
  ENTER_KEY: 13,
  ESCAPE_KEY: 27,
};

export default {
  urlBuilder,
  urlWithSearch,
  getResponseErrorMsgs,
  apiError,
  KEY_CODES,
  stringIsInteger,
};
