import { STATUS } from 'foremanReact/constants';

export const getHostIds = () => {
  const url = new URL(window.location);
  const hostId = url.searchParams.get('host_id');

  if (hostId) return [hostId];

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

export const copyToClipboard = (event, textToCopy) => {
  const clipboard = event.currentTarget.parentElement;
  const el = document.createElement('textarea');
  el.value = textToCopy;
  clipboard.appendChild(el);
  el.select();
  document.execCommand('copy');
  clipboard.removeChild(el);
};
