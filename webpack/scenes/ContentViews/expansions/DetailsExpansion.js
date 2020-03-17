import React from 'react';
import PropTypes from 'prop-types';

const DetailsExpansion = ({ cvId }) => <React.Fragment><div id={`cv-details-expansion-${cvId}`}>Details</div></React.Fragment>;

DetailsExpansion.propTypes = {
  cvId: PropTypes.number.isRequired,
};

export default DetailsExpansion;
