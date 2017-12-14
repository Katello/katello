import React from 'react';
import PropTypes from 'prop-types';

import EnabledRepository from './EnabledRepository';

const EnabledRepositoriesList = ({ repositorySets }) =>
  repositorySets.map(({ type, repositories }) =>
    repositories.map(repo => <EnabledRepository key={repo.id} type={type} {...repo} />));

EnabledRepositoriesList.propTypes = {
  repositorySets: PropTypes.arrayOf(PropTypes.shape({
    repositories: PropTypes.arrayOf(PropTypes.object).isRequired,
    type: PropTypes.string.isRequired,
    vendor: PropTypes.string.isRequired,
    gpgUrl: PropTypes.string.isRequired,
    contentUrl: PropTypes.string.isRequired,
    id: PropTypes.string.isRequired,
    name: PropTypes.string.isRequired,
    label: PropTypes.string.isRequired,
  })),
};

export default EnabledRepositoriesList;
