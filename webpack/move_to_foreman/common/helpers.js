export default {
  urlBuilder(controller, action, id = undefined) {
    return `/${controller}/${id ? `${id}/` : ''}${action}`;
  },
};

export const KEY_CODES = {
  TAB_KEY: 9,
  ENTER_KEY: 13,
  ESCAPE_KEY: 27,
};
