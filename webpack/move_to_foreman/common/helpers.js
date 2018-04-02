export default {
  urlBuilder(controller, action, id = undefined) {
    return `/${controller}/${id ? `${id}/` : ''}${action}`;
  },
};
