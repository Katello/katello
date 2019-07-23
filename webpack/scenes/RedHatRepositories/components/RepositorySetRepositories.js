import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import { Alert, Spinner } from 'patternfly-react';
import { translate as __ } from 'foremanReact/common/I18n';

import loadRepositorySetRepos from '../../../redux/actions/RedHatRepositories/repositorySetRepositories';
import RepositorySetRepository from './RepositorySetRepository/';
import { yStream } from './RepositorySetRepositoriesHelpers';

class RepositorySetRepositories extends Component {
  componentDidMount() {
    const { contentId, productId } = this.props;

    if (this.props.data.loading) {
      this.props.loadRepositorySetRepos(contentId, productId);
    }
  }

  sortedRepos = repos => [...repos.filter(({ enabled }) => !enabled)]
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
        const repo1MajorMinor = repo1.releasever.split('.');
        const repo2MajorMinor = repo2.releasever.split('.');

        const repo1Major = parseInt(repo1MajorMinor[0], 10);
        const repo2Major = parseInt(repo2MajorMinor[0], 10);

        if (repo1Major === repo2Major) {
          const repo1Minor = parseInt(repo1MajorMinor[1], 10);
          const repo2Minor = parseInt(repo2MajorMinor[1], 10);

          if (repo1Minor === repo2Minor) {
            return 0;
          } return (repo1Minor > repo2Minor) ? -1 : 1;
        } return (repo1Major > repo2Major) ? -1 : 1;
      } return (repo1.arch > repo2.arch) ? -1 : 1;
    });

  render() {
    const { data, type } = this.props;

    if (data.error) {
      return (
        <Alert type="danger">
          <span>{data.error.displayMessage}</span>
        </Alert>
      );
    }

    const availableRepos = this.sortedRepos(data.repositories).map(repo => (
      <RepositorySetRepository key={repo.arch + repo.releasever} type={type} {...repo} />
    ));

    const repoMessage = (data.repositories.length > 0 && availableRepos.length === 0 ?
      __('All available architectures for this repo are enabled.') : __('No repositories available.'));

    return (
      <Spinner loading={data.loading}>
        {availableRepos.length ? availableRepos : <div>{repoMessage}</div>}
      </Spinner>
    );
  }
}

RepositorySetRepositories.propTypes = {
  loadRepositorySetRepos: PropTypes.func.isRequired,
  contentId: PropTypes.number.isRequired,
  productId: PropTypes.number.isRequired,
  type: PropTypes.string,
  data: PropTypes.shape({
    loading: PropTypes.bool.isRequired,
    repositories: PropTypes.arrayOf(PropTypes.object),
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
  loadRepositorySetRepos,
})(RepositorySetRepositories);
