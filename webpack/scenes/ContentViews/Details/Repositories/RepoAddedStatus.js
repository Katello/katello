import React from 'react';
import { Label } from '@patternfly/react-core';
import { CheckCircleIcon } from '@patternfly/react-icons';
import { ADDED, NOT_ADDED } from '../../ContentViewsConstants';

const RepoAddedStatus = ({ added }) => {
  if (added) {
    return (
      <Label variant="outline" color="green" icon={<CheckCircleIcon />}>
        {ADDED}
      </Label>
    );
  }
  return NOT_ADDED;
};

export default RepoAddedStatus;
