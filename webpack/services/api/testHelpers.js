
export const failureAction = (type, message = 'Request failed with status code 422') => (
  {
    type,
    payload: {
      messages: [message],
      result: new Error(message),
    },
  }
);

export const toastErrorAction = (message = 'Request failed with status code 422') => (
  {
    payload: {
      key: 'addToast',
      toast: {
        key: 'toastError_0',
        message,
        sticky: true,
        type: 'danger',
      },
    },
    type: 'toasts/addToast',
  }
);

export default {
  failureAction,
  toastErrorAction,
};
