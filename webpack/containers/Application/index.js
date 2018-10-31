import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { BrowserRouter as Router } from 'react-router-dom';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import { orgId } from '../../services/api';
import * as actions from '../../scenes/Organizations/OrganizationActions';
import reducer from '../../scenes/Organizations/OrganizationReducer';
import Routes from './Routes';
import './overrides.scss';

const mapStateToProps = state => ({
  organization: state.organization,
  currOrg: state.layout.currentOrganization,
});
const mapDispatchToProps = dispatch => bindActionCreators(actions, dispatch);

export const organization = reducer;

class Application extends Component {
  componentDidMount() {
    this.loadData();
  }

  loadData() {
    if (orgId()) {
      this.props.loadOrganization();
    }
  }

  render() {
    return (
      <Router>
        <Routes org={this.props.currOrg} />
      </Router>
    );
  }
}

Application.propTypes = {
  loadOrganization: PropTypes.func.isRequired,
  currOrg: PropTypes.string.isRequired,
};

export default connect(mapStateToProps, mapDispatchToProps)(Application);
