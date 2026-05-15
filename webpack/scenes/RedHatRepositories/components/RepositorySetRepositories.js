import React, { useEffect, useMemo } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import { Alert, Spinner } from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';

import loadRepositorySetReposAction from '../../../redux/actions/RedHatRepositories/repositorySetRepositories';
import RepositorySetRepository from './RepositorySetRepository/';
import { yStream } from './RepositorySetRepositoriesHelpers';

export const RepositorySetRepositories = ({
  loadRepositorySetRepos,
  contentId,
  productId,
  type,
  data,
}) => {
  useEffect(() => {
    if (data.loading) {
      loadRepositorySetRepos(contentId, productId);
    }
  }, [contentId, productId, data.loading, loadRepositorySetRepos]);

  const sortedRepos = useMemo(() => {
    const repos = data.repositories || [];
    return [...repos.filter(({ enabled }) => !enabled)]
      .sort((repo1, repo2) => {
        const repo1YStream = yStream(repo1.releasever || '');
        const repo2YStream = yStream(repo2.releasever || '');

        if (repo1YStream < repo2YStream) {
          return -1;
        }

        if (repo2YStream < repo1YStream) {
          return 1;
        }

        if (repo1.arch === repo2.arch) {
          const repo1MajorMinor = (repo1.releasever || '0.0').split('.');
          const repo2MajorMinor = (repo2.releasever || '0.0').split('.');

          const repo1Major = parseInt(repo1MajorMinor[0], 10) || 0;
          const repo2Major = parseInt(repo2MajorMinor[0], 10) || 0;

          if (repo1Major === repo2Major) {
            const repo1Minor = parseInt(repo1MajorMinor[1], 10) || 0;
            const repo2Minor = parseInt(repo2MajorMinor[1], 10) || 0;

            if (repo1Minor === repo2Minor) {
              return 0;
            } return (repo1Minor > repo2Minor) ? -1 : 1;
          } return (repo1Major > repo2Major) ? -1 : 1;
        } return (repo1.arch > repo2.arch) ? -1 : 1;
      });
  }, [data.repositories]);

  if (data.error) {
    return (
      <Alert
        variant="danger"
        title={data.error.displayMessage}
        ouiaId="repository-set-error-alert"
        isInline
      />
    );
  }

  if (data.loading) {
    return <Spinner size="md" />;
  }

  const availableRepos = sortedRepos.map(repo => (
    <RepositorySetRepository
      key={`${repo.arch || 'noarch'}-${repo.releasever || 'none'}`}
      type={type}
      {...repo}
    />
  ));

  const repoMessage = ((data.repositories || []).length > 0 && availableRepos.length === 0 ?
    __('All available architectures for this repo are enabled.') : __('No repositories available.'));

  return availableRepos.length ? <>{availableRepos}</> : <div>{repoMessage}</div>;
};

RepositorySetRepositories.propTypes = {
  loadRepositorySetRepos: PropTypes.func.isRequired,
  contentId: PropTypes.number.isRequired,
  productId: PropTypes.number.isRequired,
  type: PropTypes.string,
  data: PropTypes.shape({
    loading: PropTypes.bool.isRequired,
    repositories: PropTypes.arrayOf(PropTypes.shape({})),
    error: PropTypes.shape({
      displayMessage: PropTypes.string,
    }),
  }).isRequired,
};

RepositorySetRepositories.defaultProps = {
  type: '',
};

const mapStateToProps = (
  { katello: { redHatRepositories: { repositorySetRepositories } } },
  props,
) => ({
  data: repositorySetRepositories[props.contentId] || {
    loading: true,
    repositories: [],
    error: null,
  },
});

export default connect(mapStateToProps, {
  loadRepositorySetRepos: loadRepositorySetReposAction,
})(RepositorySetRepositories);
