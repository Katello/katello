import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import { translate as __ } from 'foremanReact/common/I18n';

import { LoadingState } from '../../move_to_pf/LoadingState';
import { orgId } from '../../services/api';
import SetOrganization from '../SelectOrg/SetOrganization';
import Header from '../../containers/Application/Headers';
import * as organizationActions from '../../scenes/Organizations/OrganizationActions';

const mapStateToProps = state => ({
  // the current organization showing in the layout bar, tracked by Foreman
  layoutOrganization: state.layout.currentOrganization,
  // the organization as tracked in Katello
  organization: state.katello.organization,
});

const mapDispatchToProps = dispatch => bindActionCreators({ ...organizationActions }, dispatch);

function withOrganization(WrappedComponent, redirectPath, requiresOrg = true) {
  class CheckOrg extends Component {
    constructor(props) {
      super(props);
      this.state = { orgIsChanging: false };
    }

    componentDidMount() {
      this.synchronizeKatelloOrg();
    }

    static getDerivedStateFromProps(props, state) {
      const { layoutOrganization: currentForemanOrg } = props;
      if (!state.prevForemanOrgId) return { prevForemanOrgId: currentForemanOrg.id };

      // This state change is necessary to catch when the org is changing before the component
      // renders. This prevents trying to render the wrapped component with the previous
      // organization after the org has been switched. Right after the change in the org switcher,
      // the organization in katello's state will still be the previous organization and the
      // loading flag will still be false. this is changed when `componentDidUpdate` is run and
      // the organization in Katello is updated. Until then, the `orgIsChanging` state can be used
      // in the render method
      if (currentForemanOrg.id !== state.prevForemanOrgId) {
        return {
          prevForemanOrgId: currentForemanOrg.id,
          orgIsChanging: true,
        };
      }

      return null;
    }

    componentDidUpdate() {
      const {
        location,
        history,
        layoutOrganization: currentForemanOrg,
        organization: currentKatelloOrg,
      } = this.props;

      this.synchronizeKatelloOrg();

      if (currentForemanOrg.id === currentKatelloOrg.id) {
        // Here we turn off the state setting that is set in getDerivedStateFromProps.
        // The matching IDs means katello has updated from the org updating in Foreman,
        // and we can safely assume the org is no longer changing.
        // eslint-disable-next-line react/no-did-update-set-state
        if (this.state.orgIsChanging) this.setState({ orgIsChanging: false });
      }

      const splitPath = location.pathname.split('/');

      // Navigate back to the redirect page when the org changes if on subpage
      if (this.state.orgIsChanging &&
          splitPath.length > 1 &&
          location.pathname !== redirectPath &&
          !this.anyOrgSelected()) {
        history.push(redirectPath);
      }
    }

    anyOrgSelected = () => {
      const { layoutOrganization } = this.props;
      return layoutOrganization && layoutOrganization.title === 'Any Organization';
    };

    // Check if Katello's org and Foreman's org are matching
    orgsDontMatch = () => {
      const { organization } = this.props;
      return organization && orgId() !== organization.id;
    };

    synchronizeKatelloOrg = () => {
      const { organization, loadOrganization } = this.props;
      if (!this.anyOrgSelected() && !organization.loading && this.orgsDontMatch()) {
        loadOrganization();
      }
    };

    katelloOrgIsLoaded = () => {
      const { orgIsChanging } = this.state;
      const { organization } = this.props;

      return (!orgIsChanging && !organization.loading && !!organization.id);
    };

    render() {
      if (this.anyOrgSelected() && requiresOrg) {
        return (
          <React.Fragment>
            <Header title={__('Select Organization')} />
            <SetOrganization redirectPath={redirectPath} />
          </React.Fragment>
        );
      }
      return (
        <LoadingState loading={requiresOrg && !this.katelloOrgIsLoaded()}>
          <WrappedComponent {...this.props} />
        </LoadingState>
      );
    }
  }

  CheckOrg.propTypes = {
    location: PropTypes.shape({}).isRequired,
    history: PropTypes.shape({}).isRequired,
    loadOrganization: PropTypes.func.isRequired,
    organization: PropTypes.shape({}).isRequired,
    layoutOrganization: PropTypes.shape({}).isRequired,
  };

  return connect(mapStateToProps, mapDispatchToProps)(CheckOrg);
}

export default withOrganization;
