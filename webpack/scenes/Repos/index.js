import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import { Grid, Row, Col, Form, FormGroup } from 'react-bootstrap';
import { ListView } from 'patternfly-react';

import LoadingSpinner from '../../components/LoadingSpinner/index';
import { loadRedHatRepositories } from '../../actions/RedHatRepositories/index';
import MultiSelect from '../../components/MultiSelect/index';
import RedHatRepository from '../../components/RedHatRepository/index';
import SearchInput from '../../components/SearchInput/index';

class RedHatRepositoriesPage extends Component {
  componentDidMount() {
    this.loadData();
  }

  loadData() {
    this.props.loadRedHatRepositories();
  }

  render() {
    const { rhRepos, rhRepoSetsResponse } = this.props;

    const options = [
      { value: 'rpm', label: __('RPM') },
      { value: 'source-rpm', label: __('Source RPM') },
      { value: 'debug-rpm', label: __('Debug RPM') },
      { value: 'kickstarter', label: __('Kickstarter') },
      { value: 'ostree', label: __('OSTree') },
      { value: 'beta', label: __('Beta') },
      { value: 'other', label: __('Other') },
    ];

    let enabledRedHatRepositories = [];
    const availableRedHatRepositories = [];

    if (rhRepos.results) {
      enabledRedHatRepositories = rhRepos.results.map(redHatRepository => (
        <RedHatRepository key={redHatRepository.id} redHatRepository={redHatRepository} />
      ));
    }

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
                <MultiSelect options={options} />
              </FormGroup>
            </Form>
          </Col>
        </Row>

        <Row>
          <Col sm={12}>{/* <SearchFilter></SearchFilter> */}</Col>
        </Row>

        <Row>
          <Col sm={6}>
            <h2>{__('Available Repositories')}</h2>
            <LoadingSpinner isLoading={rhRepoSetsResponse.isLoading}>
              <ListView>{availableRedHatRepositories}</ListView>
            </LoadingSpinner>
          </Col>

          <Col sm={6}>
            <h2>{__('Enabled Repositories')}</h2>
            <LoadingSpinner isLoading={rhRepos.isLoading}>
              <ListView>{enabledRedHatRepositories}</ListView>
            </LoadingSpinner>
          </Col>
        </Row>
      </Grid>
    );
  }
}

RedHatRepositoriesPage.defaultProps = {
  rhRepos: {},
  rhRepoSetsResponse: {},
};

RedHatRepositoriesPage.propTypes = {
  loadRedHatRepositories: PropTypes.func.isRequired,
  rhRepos: PropTypes.shape({}),
  rhRepoSetsResponse: PropTypes.shape({}),
};

const mapStateToProps = (state) => {
  const props = {
    rhRepos: state.redHatRepositories,
    rhRepoSetsResponse: state.redHatRepositorySets,
  };
  return props;
};

export default connect(mapStateToProps, {
  loadRedHatRepositories,
})(RedHatRepositoriesPage);
