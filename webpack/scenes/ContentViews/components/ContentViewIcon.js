import React from 'react';
import PropTypes from 'prop-types';
import { EnterpriseIcon, RegistryIcon } from '@patternfly/react-icons';
import './contentViewIcon.scss';

const ContentViewIcon = ({ composite, count, description }) => {
  const props = {
    title: composite ? 'composite' : 'component',
    className: 'svg-icon-centered',
  };
  return (
    <div aria-label="content_view_icon" className="svg-centered-container">
      {count}
      {composite ? <RegistryIcon {...props} /> : <EnterpriseIcon {...props} />}
      {description}
    </div>
  );
};

ContentViewIcon.propTypes = {
  composite: PropTypes.bool,
  count: PropTypes.node,
  description: PropTypes.node,
};

ContentViewIcon.defaultProps = {
  composite: false,
  count: null,
  description: null,
};

export default ContentViewIcon;
