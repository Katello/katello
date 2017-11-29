/* eslint-disable import/no-extraneous-dependencies */
/* eslint import/no-unresolved: [2, { ignore: [foremanReact/*] }] */
/* eslint-disable import/no-unresolved */

import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import { Grid, Row, Col, Form, FormGroup } from 'react-bootstrap';
import { ListView } from 'patternfly-react';
import Loader from 'foremanReact/components/common/Loader';

import { loadEnabledRepos } from '../../redux/actions/RedHatRepositories/enabled';
import { loadRepositorySets } from '../../redux/actions/RedHatRepositories/sets';
import MultiSelect from './components/MultiSelect';
import RepositorySetsList from './components/RepositorySetsList';
import EnabledRepositoriesList from './components/EnabledRepositoriesList';
import SearchInput from '../../components/SearchInput/index';

class RedHatRepositoriesPage extends Component {
  componentDidMount() {
    this.loadData();
  }

  loadData() {
    this.props.loadEnabledRepos();
    this.props.loadRepositorySets();
  }

  render() {
    const { enabledRepositoriesResponse, repositorySetsResponse } = this.props;

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
            <Loader status={repositorySetsResponse.isLoading ? 'PENDING' : 'RESOLVED'}>
              {[
                <ListView key="sets_list">
                  <RepositorySetsList repositorySets={repositorySetsResponse.results} />
                </ListView>,
              ]}
            </Loader>
          </Col>

          <Col sm={6}>
            <h2>{__('Enabled Repositories')}</h2>
            <Loader status={enabledRepositoriesResponse.isLoading ? 'PENDING' : 'RESOLVED'}>
              {[
                <ListView key="enabled_list">
                  <EnabledRepositoriesList repositorySets={enabledRepositoriesResponse.results} />
                </ListView>,
              ]}
            </Loader>
          </Col>
        </Row>
      </Grid>
    );
  }
}

RedHatRepositoriesPage.propTypes = {
  loadEnabledRepos: PropTypes.func.isRequired,
  loadRepositorySets: PropTypes.func.isRequired,
  enabledRepositoriesResponse: PropTypes.shape({}).isRequired,
  repositorySetsResponse: PropTypes.shape({}).isRequired,
};

const mapStateToProps = ({ katello: { redHatRepositories: { enabled, sets } } }) => {
  const props = {
    enabledRepositoriesResponse: enabled,
    repositorySetsResponse: sets,
  };
  return props;
};

export default connect(mapStateToProps, {
  loadEnabledRepos,
  loadRepositorySets,
})(RedHatRepositoriesPage);
