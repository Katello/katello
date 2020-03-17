import React from 'react';
import PropTypes from 'prop-types';

const RepositoriesExpansion = ({ cvId }) => <React.Fragment><div id={`cv-repositories-expansion-${cvId}`}>Repositories</div></React.Fragment>;

RepositoriesExpansion.propTypes = {
  cvId: PropTypes.number.isRequired,
};

export default RepositoriesExpansion;
