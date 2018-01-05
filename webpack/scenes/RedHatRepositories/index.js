/* eslint-disable import/no-extraneous-dependencies */
/* eslint import/no-unresolved: [2, { ignore: [foremanReact/*] }] */
/* eslint-disable import/no-unresolved */

import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import { Grid, Row, Col, Form, FormGroup } from 'react-bootstrap';
import { ListView, Spinner } from 'patternfly-react';

import { loadEnabledRepos } from '../../redux/actions/RedHatRepositories/enabled';
import { loadRepositorySets } from '../../redux/actions/RedHatRepositories/sets';
import MultiSelect from './components/MultiSelect';
import RepositorySet from './components/RepositorySet';
import EnabledRepository from './components/EnabledRepository';
import SearchInput from '../../components/SearchInput/index';

import './index.scss';

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
      <Grid bsClass="container-fluid">
        <h1>{__('Red Hat Repositories')}</h1>

        <Row className="toolbar-pf">
          <Col sm={12}>
            <Form className="toolbar-pf-actions">
              <FormGroup className="toolbar-pf-filter">
                <SearchInput />
              </FormGroup>

              <FormGroup className="toolbar-pf-filter">
                <MultiSelect />
              </FormGroup>
            </Form>
          </Col>
        </Row>

        <Row>
          <Col sm={6}>
            <h2>{__('Available Repositories')}</h2>

            <Spinner loading={repositorySets.loading}>
              <ListView>
                {repositorySets.results.map(set => <RepositorySet key={set.id} {...set} />)}
              </ListView>
            </Spinner>
          </Col>

          <Col sm={6} className="background-container-gray">
            <h2>{__('Enabled Repositories')}</h2>
            <Spinner loading={enabledRepositories.loading}>
              <ListView>
                {enabledRepositories.repositories.length ? null : <p>No repositories enabled.</p>}
                {enabledRepositories.repositories.map(repo => (
                  <EnabledRepository key={repo.id} {...repo} />
                ))}
              </ListView>
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
