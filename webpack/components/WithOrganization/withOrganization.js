import React, { Component } from 'react';
import { orgId } from '../../services/api';
import SetOrganization from '../SelectOrg/SetOrganization';
import titleWithCaret from '../../helpers/caret';

function withOrganization(WrappedComponent, redirectPath) {
  return class CheckOrg extends Component {
    componentDidUpdate(prevProps) {
      const { location } = this.props;

      // TODO: use topbar react component
      const orgTitle = location.state && location.state.orgChanged;
      const prevOrgTitle = prevProps.location.state && prevProps.location.state.orgChanged;

      if (orgTitle !== prevOrgTitle) {
        document.getElementById('organization-dropdown').children[0].innerHTML = titleWithCaret(orgTitle);
      }
    }
    render() {
      if (!orgId()) {
        return <SetOrganization redirectPath={redirectPath} />;
      }
      return <WrappedComponent {...this.props} />;
    }
  };
}

export default withOrganization;
