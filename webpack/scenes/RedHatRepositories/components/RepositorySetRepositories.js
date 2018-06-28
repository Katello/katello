import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import { Alert, Spinner } from 'patternfly-react';

import loadRepositorySetRepos from '../../../redux/actions/RedHatRepositories/repositorySetRepositories';
import RepositorySetRepository from './RepositorySetRepository';

class RepositorySetRepositories extends Component {
  componentDidMount() {
    const { contentId, productId } = this.props;

    if (this.props.data.loading) {
      this.props.loadRepositorySetRepos(contentId, productId);
    }
  }

  render() {
    const { data } = this.props;

    if (data.error) {
      return (
        <Alert type="danger">
          <span>{data.error.displayMessage}</span>
        </Alert>
      );
    }
    const availableRepos = data.repositories
      .filter(({ enabled }) => !enabled)
      .map(repo => <RepositorySetRepository key={repo.arch + repo.releasever} {...repo} />);

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
  data: PropTypes.shape({
    loading: PropTypes.bool.isRequired,
    repositories: PropTypes.arrayOf(PropTypes.object),
  }).isRequired,
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
