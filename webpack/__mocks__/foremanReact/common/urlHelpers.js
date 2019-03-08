export const urlBuilder = (controller, action, id = undefined) =>
  `/${controller}/${id ? `${id}/` : ''}${action}`;

export const urlWithSearch = (base, searchQuery) =>
  `/${base}?search=${searchQuery}`;

export default { urlBuilder, urlWithSearch };
