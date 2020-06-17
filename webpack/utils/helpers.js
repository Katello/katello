import { addToast } from 'foremanReact/redux/actions/toasts';
import { translate as __ } from 'foremanReact/common/I18n';
import { SUBSCRIPTIONS_QUANTITIES_FAILURE } from '../scenes/Subscriptions/SubscriptionConstants';


const getSubscriptionsErrorMessage = (message) => {
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
      customMessage = getSubscriptionsErrorMessage(message);
      break;
    default:
      customMessage = null;
  }
  return customMessage;
};

export const getResponseErrorMsgs = ({ data, actionType } = {}) => {
  if (data) {
    const customMessage = getCustomMessage(actionType, data.displayMessage);
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


export const resultWithSuccessFlag = result => (
  {
    ...result,
    success: (result.status < 300),
  }
);

export const apiSuccess = (actionType, result, additionalData = {}) => (dispatch) => {
  dispatch({
    type: actionType,
    response: result.data,
    ...additionalData,
  });

  return resultWithSuccessFlag(result);
};

export const apiResponse = (actionType, result, additionalData = {}) => (dispatch) => {
  dispatch({
    type: actionType,
    payload: {
      result,
      ...additionalData,
    },
  });

  return resultWithSuccessFlag(result);
};

export const sendErrorNotifications = messages => (dispatch) => {
  messages.forEach((msg) => {
    const message = typeof msg === 'string' ? msg : `${msg.message}: ${msg.details}`;
    dispatch(addToast({
      type: 'error',
      message,
      sticky: true,
    }));
  });
};

export const apiError = (actionType, result, additionalData = {}) => (dispatch) => {
  const messages = getResponseErrorMsgs(result.response);

  // If no actionType passed in, only create notification and skip dispatching action
  if (actionType) {
    const dataExtenstion = {
      messages,
      ...additionalData,
    };

    apiResponse(actionType, result, dataExtenstion)(dispatch);
  }
  sendErrorNotifications(messages)(dispatch);

  return resultWithSuccessFlag(result);
};


export default {
  getResponseErrorMsgs,
  apiError,
};
