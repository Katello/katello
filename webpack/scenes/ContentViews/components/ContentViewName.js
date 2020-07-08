import React from 'react';
import PropTypes from 'prop-types';
import { CubesIcon, CubeIcon } from '@patternfly/react-icons';
import './contentViewName.scss';

const ContentViewName = ({ composite, cvId }) => {
  const props = {
    key: cvId,
    title: composite ? 'composite' : 'single',
    style: { margin: '1px 5px' },
    className: 'svg-icon-centered',
  };
  return (
    <React.Fragment>
      <div className="svg-centered-container">
        {composite ? <CubesIcon {...props} /> : <CubeIcon {...props} />}
      </div>
    </React.Fragment>
  );
};

ContentViewName.propTypes = {
  cvId: PropTypes.number.isRequired,
  composite: PropTypes.bool,
};

ContentViewName.defaultProps = {
  composite: false,
};

export default ContentViewName;
