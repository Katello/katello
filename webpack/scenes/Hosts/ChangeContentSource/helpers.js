import { STATUS } from 'foremanReact/constants';

export const getHostIds = (hostIdFromUrl) => {
  if (hostIdFromUrl) return [hostIdFromUrl];

  const cookie = document.cookie.split('; ')
    .find(row => row.startsWith('_ForemanSelectedhosts'));
  const params = new URLSearchParams(cookie);
  const ids = params.get('_ForemanSelectedhosts');

  if (ids) return JSON.parse(ids);
  return [];
};

export const formIsLoading = (data, contentView, change) => (
  data === STATUS.PENDING ||
  contentView === STATUS.PENDING ||
  change === STATUS.PENDING
);

export const copyToClipboard = async (event, textToCopy) => {
  await navigator.clipboard.writeText(textToCopy);
};
