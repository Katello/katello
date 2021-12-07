import React from 'react';
import PropTypes from 'prop-types';
import { Label } from '@patternfly/react-core';
import { CheckCircleIcon } from '@patternfly/react-icons';
import { translate as __ } from 'foremanReact/common/I18n';
import InactiveText from '../scenes/ContentViews/components/InactiveText';

const AddedStatusLabel = ({ added }) => {
  if (added) {
    return (
      <Label variant="outline" color="green" icon={<CheckCircleIcon />}>
        {__('Added')}
      </Label>
    );
  }
  return <InactiveText text={__('Not added')} />;
};

AddedStatusLabel.propTypes = {
  added: PropTypes.bool.isRequired,
};

export default AddedStatusLabel;
