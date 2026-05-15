import React from 'react';
import { DataList } from '@patternfly/react-core';
import { sprintf, translate as __ } from 'foremanReact/common/I18n';
import Pagination from 'foremanReact/components/Pagination';

import RepositorySet from './components/RepositorySet';
import EnabledRepository from './components/EnabledRepository';

export const getSetsComponent = (repoSetsState, onPaginationChange) => {
  const {
    results,
    searchIsActive,
    pagination,
    itemCount,
  } = repoSetsState;

  if (itemCount === 0 || !results) {
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
    <>
      <div className="sticky-pagination">
        <Pagination
          itemCount={itemCount}
          onChange={onPaginationChange}
          updateParamsByUrl={false}
          isCompact
          {...pagination}
        />
      </div>
      <DataList aria-label={__('Available repository sets')}>
        {results.map(set => <RepositorySet id={set.id} key={set.id} {...set} />)}
      </DataList>
    </>
  );
};

export const getEnabledComponent = (enabledReposState, onPaginationChange) => {
  const {
    repositories,
    searchIsActive,
    pagination,
    itemCount,
  } = enabledReposState;

  if (itemCount === 0) {
    if (searchIsActive) {
      return <p>{__('No enabled repositories match your search criteria.')}</p>;
    }
    return <p>{__('No repositories enabled.')}</p>;
  }

  return (
    <>
      <div className="sticky-pagination sticky-pagination-grey">
        <Pagination
          isCompact
          itemCount={itemCount}
          onChange={onPaginationChange}
          updateParamsByUrl={false}
          {...pagination}
        />
      </div>
      <DataList aria-label={__('Enabled repositories')}>
        {repositories.map(repo => <EnabledRepository key={repo.id} {...repo} />)}
      </DataList>
    </>
  );
};
