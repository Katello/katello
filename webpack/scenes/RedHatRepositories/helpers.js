import React from 'react';
import PropTypes from 'prop-types';
import { ListView } from 'patternfly-react';

import RepositorySet from './components/RepositorySet';
import EnabledRepository from './components/EnabledRepository';

export const stringIncludes = (string, includes) => {
  const a = string.replace(/\s/g, '').toLowerCase();
  const b = includes.replace(/\s/g, '').toLowerCase();
  return a.includes(b);
};

export const getSetsComponent = ({ results, searchIsActive }) => {
  if (results.length === 0) {
    if (searchIsActive) {
      return <p>No repository sets match your search criteria.</p>;
    }
    return (
      <p>
        No Red Hat products currently exist, please import a manifest{' '}
        <a href="/subscriptions/manifest/import">here</a> to receive Red Hat content. No repository
        sets available.
      </p>
    );
  }
  return <ListView>{results.map(set => <RepositorySet key={set.id} {...set} />)}</ListView>;
};

getSetsComponent.propTypes = {
  results: PropTypes.arrayOf({}).isRequired,
  searchIsActive: PropTypes.bool,
};
getSetsComponent.defaultProps = {
  searchIsActive: false,
};

export const getEnabledComponent = ({ repositories, searchIsActive }) => {
  if (repositories.length === 0) {
    if (searchIsActive) {
      return <p>No enabled repositories match your search criteria.</p>;
    }
    return <p>No repositories enabled.</p>;
  }

  return (
    <ListView>{repositories.map(repo => <EnabledRepository key={repo.id} {...repo} />)}</ListView>
  );
};

getEnabledComponent.propTypes = {
  repositories: PropTypes.arrayOf({}).isRequired,
  searchIsActive: PropTypes.bool,
};
getEnabledComponent.defaultProps = {
  searchIsActive: false,
};
