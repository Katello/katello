/* eslint-disable import/no-extraneous-dependencies */
/* eslint import/no-unresolved: [2, { ignore: [foremanReact/*] }] */
/* eslint-disable import/no-unresolved */

import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import { Grid, Row, Col, Form, FormGroup } from 'react-bootstrap';
import { Spinner } from 'patternfly-react';

import { loadEnabledRepos } from '../../redux/actions/RedHatRepositories/enabled';
import { loadRepositorySets } from '../../redux/actions/RedHatRepositories/sets';
import MultiSelect from './components/MultiSelect';
import Search from './components/Search';
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
      <Grid bsClass="container-fluid">
        <h1>{__('Red Hat Repositories')}</h1>

        <Row className="toolbar-pf">
          <Col sm={12}>
            <Form className="toolbar-pf-actions">
              <FormGroup className="toolbar-pf-filter">
                <Search />
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
            <Spinner loading={repositorySets.loading}>{getSetsComponent(repositorySets)}</Spinner>
          </Col>

          <Col sm={6} className="background-container-gray">
            <h2>{__('Enabled Repositories')}</h2>
            <Spinner loading={enabledRepositories.loading} className="small-spacer">
              {getEnabledComponent(enabledRepositories)}
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
