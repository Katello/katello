/* eslint-disable import/no-extraneous-dependencies */
/* eslint import/no-unresolved: [2, { ignore: [foremanReact/*] }] */
/* eslint-disable import/no-unresolved */

import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import { Grid, Row, Col } from 'react-bootstrap';
import { Button } from 'patternfly-react';
import { translate as __ } from 'foremanReact/common/I18n';
import { LoadingState } from '../../move_to_pf/LoadingState';
import { createEnabledRepoParams, loadEnabledRepos } from '../../redux/actions/RedHatRepositories/enabled';
import { loadRepositorySets, updateRecommendedRepositorySets } from '../../redux/actions/RedHatRepositories/sets';
import SearchBar from './components/SearchBar';
import RecommendedRepositorySetsToggler from './components/RecommendedRepositorySetsToggler';
import { getSetsComponent, getEnabledComponent } from './helpers';
import api from '../../services/api';

class RedHatRepositoriesPage extends Component {
  componentDidMount() {
    this.loadData();
  }

  loadData() {
    this.props.loadEnabledRepos();
    this.props.loadRepositorySets({ search: { filters: ['rpm'] } });
  }

  render() {
    const { enabledRepositories, repositorySets } = this.props;
    const { repoParams } = createEnabledRepoParams(enabledRepositories);

    return (
      <Grid id="redhatRepositoriesPage" bsClass="container-fluid">
        <h1>{__('Red Hat Repositories')}</h1>
        <Row className="toolbar-pf">
          <Col sm={12}>
            <SearchBar />
          </Col>
        </Row>

        <Row className="row-eq-height">
          <Col sm={6} className="available-repositories-container">
            <div className="available-repositories-header">
              <h2>{__('Available Repositories')}</h2>
              <RecommendedRepositorySetsToggler
                enabled={repositorySets.recommended}
                onChange={value => this.props.updateRecommendedRepositorySets(value)}
                className="recommended-repositories-toggler"
              />
            </div>
            <LoadingState loading={repositorySets.loading} loadingText={__('Loading')}>
              {getSetsComponent(
                repositorySets,
                (pagination) => {
                  this.props.loadRepositorySets({
                    ...pagination,
                    search: repositorySets.search,
                  });
                },
              )}
            </LoadingState>
          </Col>

          <Col sm={6} className="enabled-repositories-container">
            <h2>
              {__('Enabled Repositories')}
              <Button
                className="pull-right"
                onClick={() => { api.open('/repositories.csv', repoParams); }}
              >
                {__('Export as CSV')}
              </Button>
            </h2>

            <LoadingState loading={enabledRepositories.loading} loadingText={__('Loading')}>
              {getEnabledComponent(
                enabledRepositories,
                (pagination) => {
                  this.props.loadEnabledRepos({
                    ...pagination,
                    search: enabledRepositories.search,
                  });
                },
              )}
            </LoadingState>
          </Col>
        </Row>
      </Grid>
    );
  }
}

RedHatRepositoriesPage.propTypes = {
  loadEnabledRepos: PropTypes.func.isRequired,
  loadRepositorySets: PropTypes.func.isRequired,
  updateRecommendedRepositorySets: PropTypes.func.isRequired,
  enabledRepositories: PropTypes.shape({
    loading: PropTypes.bool,
    search: PropTypes.shape({}),
  }).isRequired,
  repositorySets: PropTypes.shape({
    recommended: PropTypes.bool,
    loading: PropTypes.bool,
    search: PropTypes.shape({}),
  }).isRequired,
};

const mapStateToProps = ({
  katello: {
    redHatRepositories: { enabled, sets },
  },
}) => ({
  enabledRepositories: enabled,
  repositorySets: sets,
});

export default connect(mapStateToProps, {
  loadEnabledRepos,
  loadRepositorySets,
  updateRecommendedRepositorySets,
})(RedHatRepositoriesPage);
