import React from 'react';
import PropTypes from 'prop-types';
import { EnterpriseIcon, RegistryIcon } from '@patternfly/react-icons';
import './contentViewIcon.scss';

const ContentViewIcon = ({ composite }) => {
  const props = {
    title: composite ? 'composite' : 'component',
    className: 'svg-icon-centered',
  };
  return (
    <div className="svg-centered-container">
      {composite ? <RegistryIcon {...props} /> : <EnterpriseIcon {...props} />}
    </div>
  );
};

ContentViewIcon.propTypes = {
  composite: PropTypes.bool,
};

ContentViewIcon.defaultProps = {
  composite: false,
};

export default ContentViewIcon;
