// eslint-disable-next-line import/prefer-default-export
export const filterRHSubscriptions = subscriptions =>
  subscriptions.filter(sub => sub.available >= 0);
