import React from 'react';
import { Label } from '@patternfly/react-core';
import { CheckCircleIcon } from '@patternfly/react-icons';
import { translate as __ } from 'foremanReact/common/I18n';

const AddedStatusLabel = ({ added }) => {
  if (added) {
    return (
      <Label variant="outline" color="green" icon={<CheckCircleIcon />}>
        {__('Added')}
      </Label>
    );
  }
  return __('Not added');
};

export default AddedStatusLabel;
