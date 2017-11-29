import React from 'react';
import PropTypes from 'prop-types';

import RepositorySet from './RepositorySet';

const RepositorySetsList = ({ repositorySets }) =>
  repositorySets.map(repo => <RepositorySet key={repo.id} {...repo} />);

RepositorySetsList.propTypes = {
  repositorySets: PropTypes.arrayOf(PropTypes.object),
};

export default RepositorySetsList;
