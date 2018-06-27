import { addToast } from 'foremanReact/redux/actions/toasts';

const urlBuilder = (controller, action, id = undefined) =>
  `/${controller}/${id ? `${id}/` : ''}${action}`;

const urlWithSearch = (base, searchQuery) =>
  `/${base}?search=${searchQuery}`;

export const getResponseErrorMsgs = ({ data }) => {
  if (data) {
    const messages = (data.errors || data.displayMessage || data.message || data.error);
    return (Array.isArray(messages) ? messages : [messages]);
  }
  return [];
};

export const apiError = (actionType, result) => (dispatch) => {
  const messages = getResponseErrorMsgs(result.response);
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
};
