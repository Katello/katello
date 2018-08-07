
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
      message: {
        message,
        sticky: true,
        type: 'error',
      },
    },
    type: 'TOASTS_ADD',
  }
);

export default {
  failureAction,
  toastErrorAction,
};
