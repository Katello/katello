import React, { Component } from '@theforeman/vendor/react';
import PropTypes from '@theforeman/vendor/prop-types';
import { BrowserRouter as Router } from '@theforeman/vendor/react-router-dom';
import { bindActionCreators } from '@theforeman/vendor/redux';
import { connect } from '@theforeman/vendor/react-redux';
import { orgId } from '../../services/api';
import * as actions from '../../scenes/Organizations/OrganizationActions';
import reducer from '../../scenes/Organizations/OrganizationReducer';
import Routes from './Routes';
import './overrides.scss';

const mapStateToProps = state => ({ organization: state.organization });
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
        <Routes />
      </Router>
    );
  }
}

Application.propTypes = {
  loadOrganization: PropTypes.func.isRequired,
};

export default connect(mapStateToProps, mapDispatchToProps)(Application);
