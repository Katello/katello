export const addToast = toast => ({
  type: 'toasts/addToast',
  payload: {
    key: 'addToast',
    toast,
  },
});

export default addToast;
