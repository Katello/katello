import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { BrowserRouter as Router } from 'react-router-dom';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';

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
    this.props.loadOrganization();
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
