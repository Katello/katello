export const selectAllServices = state => state.systemServices.services || {};

export const selectStatus = state => state.systemServices.loaderStatus;
