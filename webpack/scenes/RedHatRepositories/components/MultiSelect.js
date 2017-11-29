import React from 'react';
import MultiSelect from '../../../components/MultiSelect/index';

const options = [
  { value: 'rpm', label: __('RPM') },
  { value: 'source-rpm', label: __('Source RPM') },
  { value: 'debug-rpm', label: __('Debug RPM') },
  { value: 'kickstarter', label: __('Kickstarter') },
  { value: 'ostree', label: __('OSTree') },
  { value: 'beta', label: __('Beta') },
  { value: 'other', label: __('Other') },
];

export default () => <MultiSelect options={options} />;
