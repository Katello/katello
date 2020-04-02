import React from 'react';
import PropTypes from 'prop-types';

const IconWithCount = ({ count, title, Icon }) => (
  <React.Fragment>
    <Icon title={title} className="ktable-cell-icon" />
    {count}
  </React.Fragment>
);

IconWithCount.propTypes = {
  count: PropTypes.number.isRequired,
  title: PropTypes.string.isRequired,
  Icon: PropTypes.elementType.isRequired,
};

export default IconWithCount;
