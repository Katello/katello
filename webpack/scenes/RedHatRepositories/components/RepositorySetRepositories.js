import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import { Spinner } from 'patternfly-react';

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

    const repos = data.repositories.map(repo => (
      <RepositorySetRepository key={repo.arch + repo.releasever} {...repo} />
    ));

    return (
      <Spinner loading={data.loading}>
        {data.repositories.length ? repos : <div>No repositories found.</div>}
      </Spinner>
    );
  }
}

RepositorySetRepositories.propTypes = {
  loadRepositorySetRepos: PropTypes.func.isRequired,
  contentId: PropTypes.string.isRequired,
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
