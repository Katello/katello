import React from 'react';
import PropTypes from 'prop-types';
import { BugIcon, EnhancementIcon, SecurityIcon, UnknownIcon } from '@patternfly/react-icons';

const ErratumTypeLabel = ({ type }) => {
  switch (type) {
    case 'bugfix':
      return (
        <p><BugIcon /> Bugfix</p>
      );
    case 'enhancement':
      return (
        <p><EnhancementIcon /> Enhancement</p>
      );
    case 'security':
      return (
        <p><SecurityIcon /> Security</p>
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
