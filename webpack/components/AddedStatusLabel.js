import React from 'react';
import { Label } from '@patternfly/react-core';
import { CheckCircleIcon } from '@patternfly/react-icons';
// TODO move constants here and use in CV
//import { ADDED, NOT_ADDED } from '../../ContentViewsConstants';

const AddedStatusLabel = ({ added }) => {
  if (added) {
    return (
      <Label variant="outline" color="green" icon={<CheckCircleIcon />}>
        {"Added"}
      </Label>
    );
  }
  return "Not added";
};

export default AddedStatusLabel;
