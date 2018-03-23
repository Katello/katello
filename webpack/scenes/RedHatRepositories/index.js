/* eslint-disable import/no-extraneous-dependencies */
/* eslint import/no-unresolved: [2, { ignore: [foremanReact/*] }] */
/* eslint-disable import/no-unresolved */

import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import { Grid, Row, Col } from 'react-bootstrap';
import { Spinner } from 'patternfly-react';

import { loadEnabledRepos } from '../../redux/actions/RedHatRepositories/enabled';
import { loadRepositorySets } from '../../redux/actions/RedHatRepositories/sets';
import SearchBar from './components/SearchBar';
import { getSetsComponent, getEnabledComponent } from './helpers';

class RedHatRepositoriesPage extends Component {
  componentDidMount() {
    this.loadData();
  }

  loadData() {
    this.props.loadEnabledRepos();
    this.props.loadRepositorySets();
  }

  render() {
    const { enabledRepositories, repositorySets } = this.props;

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
            <h2>{__('Available Repositories')}</h2>
            <Spinner loading={repositorySets.loading}>
              {getSetsComponent(
                repositorySets,
                (pagination) => {
                  this.props.loadRepositorySets({
                    ...pagination,
                    search: repositorySets.search,
                  });
                },
              )}
            </Spinner>
          </Col>

          <Col sm={6} className="enabled-repositories-container">
            <h2>{__('Enabled Repositories')}</h2>
            <Spinner loading={enabledRepositories.loading} className="small-spacer">
              {getEnabledComponent(
                enabledRepositories,
                (pagination) => {
                  this.props.loadEnabledRepos({
                    ...pagination,
                    search: enabledRepositories.search,
                  });
                },
              )}
            </Spinner>
          </Col>
        </Row>
      </Grid>
    );
  }
}

RedHatRepositoriesPage.propTypes = {
  loadEnabledRepos: PropTypes.func.isRequired,
  loadRepositorySets: PropTypes.func.isRequired,
  enabledRepositories: PropTypes.shape({}).isRequired,
  repositorySets: PropTypes.shape({}).isRequired,
};

const mapStateToProps = ({ katello: { redHatRepositories: { enabled, sets } } }) => ({
  enabledRepositories: enabled,
  repositorySets: sets,
});

export default connect(mapStateToProps, {
  loadEnabledRepos,
  loadRepositorySets,
})(RedHatRepositoriesPage);
