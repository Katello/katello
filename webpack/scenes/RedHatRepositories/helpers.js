import React from 'react';
import { ListView } from 'patternfly-react';

import PaginationRow from '../../components/PaginationRow/index';
import RepositorySet from './components/RepositorySet';
import EnabledRepository from './components/EnabledRepository';

export const stringIncludes = (string, includes) => {
  const a = string.replace(/\s/g, '').toLowerCase();
  const b = includes.replace(/\s/g, '').toLowerCase();
  return a.includes(b);
};

export const getSetsComponent = (repoSetsState, onPaginationChange) => {
  const {
    results,
    searchIsActive,
    pagination,
    itemCount,
  } = repoSetsState;

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
  return (
    <ListView>
      {results.map(set => <RepositorySet id={set.id} key={set.id} {...set} />)}
      <PaginationRow
        viewType="list"
        itemCount={itemCount}
        pagination={pagination}
        onChange={onPaginationChange}
      />
    </ListView>
  );
};

export const getEnabledComponent = (enabledReposState, onPaginationChange) => {
  const {
    repositories,
    searchIsActive,
    pagination,
    itemCount,
  } = enabledReposState;

  if (repositories.length === 0) {
    if (searchIsActive) {
      return <p>No enabled repositories match your search criteria.</p>;
    }
    return <p>No repositories enabled.</p>;
  }

  return (
    <ListView>
      {repositories.map(repo => <EnabledRepository key={repo.id} {...repo} />)}
      <PaginationRow
        viewType="list"
        itemCount={itemCount}
        pagination={pagination}
        onChange={onPaginationChange}
      />
    </ListView>
  );
};
