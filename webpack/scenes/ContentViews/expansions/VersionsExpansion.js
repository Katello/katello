import React from 'react';
import PropTypes from 'prop-types';

const VersionsExpansion = ({ cvId }) => <React.Fragment><div id={`cv-versions-expansion-${cvId}`}>Versions</div></React.Fragment>;

VersionsExpansion.propTypes = {
  cvId: PropTypes.number.isRequired,
};

export default VersionsExpansion;
