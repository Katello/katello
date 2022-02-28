import React from 'react';
import PropTypes from 'prop-types';
import { BugIcon, EnhancementIcon, SecurityIcon, UnknownIcon } from '@patternfly/react-icons';
import { translate as __ } from 'foremanReact/common/I18n';

const ErratumTypeLabel = ({ type }) => {
  switch (type) {
  case 'bugfix':
    return (
      <p><BugIcon />{' '}{__('Bugfix')}</p>
    );
  case 'enhancement':
    return (
      <p><EnhancementIcon />{' '}{__('Enhancement')}</p>
    );
  case 'security':
    return (
      <p><SecurityIcon />{' '}{__('Security')}</p>
    );
  default:
    return (
      <p><UnknownIcon /> {type}</p>
    );
  }
};

ErratumTypeLabel.propTypes = {
  type: PropTypes.string.isRequired,
};

export default ErratumTypeLabel;
