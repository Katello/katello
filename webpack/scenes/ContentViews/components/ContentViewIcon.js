import React from 'react';
import PropTypes from 'prop-types';
import { CubesIcon, CubeIcon } from '@patternfly/react-icons';
import './contentViewIcon.scss';

const ContentViewIcon = ({ composite }) => {
  const props = {
    title: composite ? 'composite' : 'single',
    className: 'svg-icon-centered',
  };
  return (
    <div className="svg-centered-container">
      {composite ? <CubesIcon {...props} /> : <CubeIcon {...props} />}
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
