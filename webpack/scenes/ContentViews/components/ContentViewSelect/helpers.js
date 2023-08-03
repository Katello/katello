import { STATUS } from 'foremanReact/constants';
import { translate as __ } from 'foremanReact/common/I18n';

export const getCVPlaceholderText = ({
  contentSourceId = null,
  environments = [],
  contentViewsStatus = STATUS.PENDING,
  cvSelectOptions = [],
}) => {
  if (contentSourceId === '') return __('Select a content source first');
  if (environments.length === 0) return __('Select a lifecycle environment first');
  if (contentViewsStatus === STATUS.PENDING) return __('Loading...');
  if (contentViewsStatus === STATUS.ERROR) return __('Error loading content views');
  if (cvSelectOptions.length === 0) return __('No content views available');
  return __('Select a content view');
};

export const shouldDisableCVSelect = ({
  contentSourceId = null,
  environments = [],
  contentViewsStatus = STATUS.PENDING,
  cvSelectOptions = [],
}) => {
  if (contentSourceId === '') return true;
  if (environments.length === 0) return true;
  if (contentViewsStatus === STATUS.PENDING) return true;
  if (contentViewsStatus === STATUS.ERROR) return true;
  if (cvSelectOptions.length === 0) return true;
  return false;
};

export default getCVPlaceholderText;
