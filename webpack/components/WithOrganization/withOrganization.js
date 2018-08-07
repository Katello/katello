import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { get } from 'lodash';
import SetOrganization from '../SelectOrg/SetOrganization';
import titleWithCaret from '../../helpers/caret';
import Header from '../../containers/Application/Headers';

function withOrganization(WrappedComponent, redirectPath) {
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

      // TODO: use topbar react component
      const orgTitle = get(location, 'state.orgChanged');
      const prevOrgTitle = get(prevProps, 'location.state.orgChanged');

      if (orgTitle !== prevOrgTitle) {
        document.getElementById('organization-dropdown')
          .children[0].innerHTML = titleWithCaret(orgTitle);
      }
    }

    render() {
      const { location } = this.props;
      const newOrgSelected = get(location, 'state.orgChanged');

      if (newOrgSelected) {
        return <WrappedComponent {...this.props} />;
      } else if (this.state.orgId === '') {
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
  return CheckOrg;
}

export default withOrganization;
