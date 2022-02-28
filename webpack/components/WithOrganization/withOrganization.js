/* eslint-disable react/jsx-indent */
import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';

import { translate as __ } from 'foremanReact/common/I18n';
import { get } from 'lodash';
import SetOrganization from '../SelectOrg/SetOrganization';
import Header from '../../containers/Application/Headers';
import * as organizationActions from '../../scenes/Organizations/OrganizationActions';

const mapStateToProps = state => ({
  organization: state.katello.organization,
});

const mapDispatchToProps = dispatch => bindActionCreators({ ...organizationActions }, dispatch);

function withOrganization(WrappedComponent) {
  class CheckOrg extends Component {
    constructor(props) {
      super(props);
      this.state = { orgId: null };
    }
    static getDerivedStateFromProps(newProps, state) {
      const orgNodeId = document.getElementById('organization-id').dataset.id;

      if (state.orgId !== orgNodeId) {
        return { orgId: orgNodeId };
      }
      return null;
    }

    componentDidUpdate(prevProps) {
      const { location } = this.props;
      const orgTitle = get(location, 'state.orgChanged');
      const prevOrgTitle = get(prevProps, 'location.state.orgChanged');

      if (orgTitle !== prevOrgTitle) {
        window.tfm.nav.changeOrganization(orgTitle);
      }
    }

    render() {
      const { organization, location } = this.props;
      const newOrgSelected = get(location, 'state.orgChanged');

      if (newOrgSelected) {
        if (!organization.label && !organization.loading) { this.props.loadOrganization(); }
        return <WrappedComponent {...this.props} />;
      } else if (this.state.orgId === '') {
        return (
          <>
            <Header title={__('Select Organization')} />
            <SetOrganization />
          </>);
      }
      return <WrappedComponent {...this.props} />;
    }
  }

  CheckOrg.propTypes = {
    location: PropTypes.shape({}),
    loadOrganization: PropTypes.func.isRequired,
    organization: PropTypes.shape({
      label: PropTypes.string,
      loading: PropTypes.bool,
    }).isRequired,
  };

  CheckOrg.defaultProps = {
    location: undefined,
  };

  return connect(mapStateToProps, mapDispatchToProps)(CheckOrg);
}

export default withOrganization;
