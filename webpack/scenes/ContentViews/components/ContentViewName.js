import React from 'react';
import PropTypes from 'prop-types';
import { CubeIcon, CubesIcon } from '@patternfly/react-icons';

const ContentViewName = ({ composite, name, cvId }) => {
  const props = {
    key: cvId,
    title: composite ? 'composite' : 'single',
    style: { margin: '1px 5px' },
  };
  return (
    <React.Fragment>
      {composite ? <CubesIcon {...props} /> : <CubeIcon {...props} />}
      {name}
    </React.Fragment>
  );
};

ContentViewName.propTypes = {
  cvId: PropTypes.number.isRequired,
  name: PropTypes.string.isRequired,
  composite: PropTypes.bool,
};

ContentViewName.defaultProps = {
  composite: undefined,
};

export default ContentViewName;
