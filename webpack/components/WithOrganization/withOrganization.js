import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { get } from 'lodash';
import { withRouter } from 'react-router';
import SetOrganization from '../SelectOrg/SetOrganization';
import Header from '../../containers/Application/Headers';

function withOrganization(WrappedComponent, redirectPath) {
  class CheckOrg extends Component {
    componentDidUpdate(prevProps) {
      const { org, history } = this.props;
      const orgHasBeenSwitched = prevProps.org.id !== org.id;

      if (org.id &&
          orgHasBeenSwitched &&
          history.location.pathname !== redirectPath) {
        history.push({
          pathname: redirectPath,
        });
      }
    }

    render() {
      const { org } = this.props;
      // const newOrgSelected = get(location, 'state.orgChanged');

      // if (newOrgSelected) {
      //   return <WrappedComponent {...this.props} />;
      if (!org.id) {
        return (
          <React.Fragment>
            <Header title={__('Select Organization')} />
            <SetOrganization redirectPath={redirectPath} />
          </React.Fragment>);
      }
      return <WrappedComponent {...this.props} />;
    }
  }

  CheckOrg.propTypes = {
    location: PropTypes.shape({}),
  };

  CheckOrg.defaultProps = {
    location: undefined,
  };
  return withRouter(CheckOrg);
}

export default withOrganization;
