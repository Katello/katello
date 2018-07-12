import React from 'react';
import { ListView } from 'patternfly-react';
import { sprintf } from 'jed';

import PaginationRow from '../../components/PaginationRow/index';
import RepositorySet from './components/RepositorySet';
import EnabledRepository from './components/EnabledRepository';

export const getSetsComponent = (repoSetsState, onPaginationChange) => {
  const {
    results,
    searchIsActive,
    pagination,
    itemCount,
  } = repoSetsState;

  if (!results || results.length === 0) {
    if (searchIsActive) {
      return <p>{__('No repository sets match your search criteria.')}</p>;
    }
    const noProductsMessage =
      sprintf(
        __('No Red Hat products currently exist, please import a manifest %(anchorBegin)s here %(anchorEnd)s to receive Red Hat content. No repository sets available.'),
        {
          anchorBegin: '<a href="/subscriptions/">',
          anchorEnd: '</a>',
        },
      );

    // eslint-disable-next-line react/no-danger
    return <p dangerouslySetInnerHTML={{ __html: noProductsMessage }} />;
  }
  return (
    <ListView>
      <PaginationRow
        viewType="list"
        itemCount={itemCount}
        pagination={pagination}
        onChange={onPaginationChange}
      />
      {results.map(set => <RepositorySet id={set.id} key={set.id} {...set} />)}
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
      return <p>{__('No enabled repositories match your search criteria.')}</p>;
    }
    return <p>{__('No repositories enabled.')}</p>;
  }

  return (
    <ListView>
      <PaginationRow
        viewType="list"
        itemCount={itemCount}
        pagination={pagination}
        onChange={onPaginationChange}
      />
      {repositories.map(repo => <EnabledRepository key={repo.id} {...repo} />)}
    </ListView>
  );
};
