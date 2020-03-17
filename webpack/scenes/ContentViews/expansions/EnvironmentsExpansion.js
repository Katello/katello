import React from 'react';
import PropTypes from 'prop-types';

const EnvironmentsExpansion = ({ cvId }) => {
  const identifier = `cv-environments-expansion-${cvId}`;
  return (
    <React.Fragment>
      <div id={identifier} data-testid={identifier}>Environments</div>
      <div>this should be showing but will be replaced by something else later</div>
    </React.Fragment>
  );
};

EnvironmentsExpansion.propTypes = {
  cvId: PropTypes.number.isRequired,
};

export default EnvironmentsExpansion;
