export default {
  urlBuilder(controller, action, id = undefined) {
    return `/${controller}/${id ? `${id}/` : ''}${action}`;
  },

  urlWithSearch(base, searchQuery) {
    return `/${base}?search=${searchQuery}`;
  },
};

export const KEY_CODES = {
  TAB_KEY: 9,
  ENTER_KEY: 13,
  ESCAPE_KEY: 27,
};

export const getResponseError = ({ data }) => data && (data.displayMessage || data.error);
