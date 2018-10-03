
export const failureAction = (type, message = 'Request failed with status code 422') => (
  {
    type,
    payload: {
      messages: [message],
      result: new Error(message),
    },
  }
);

export const toastErrorAction = (message = 'Error 422: oh no, something went wrong') => (
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
