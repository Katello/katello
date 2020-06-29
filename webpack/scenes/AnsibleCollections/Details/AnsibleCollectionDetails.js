import React, { Component } from 'react';
import BreadcrumbsBar from 'foremanReact/components/BreadcrumbBar';
import { PropTypes } from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import api from '../../../services/api';
import ContentDetails from '../../../components/Content/Details/ContentDetails';
import ansibleCollectionsSchema from './AnsibleCollectionsSchema';

class AnsibleCollectionDetails extends Component {
  componentDidMount() {
    this.updateAnsibleCollection();
  }

  componentDidUpdate(prevProps) {
    const { match: { params: prevRouterParams } } = this.props;
    const { match: { params: currentRouterParams } } = prevProps;
    if (prevRouterParams.id && (prevRouterParams.id !== currentRouterParams.id)) {
      this.updateAnsibleCollection();
    }
  }

  updateAnsibleCollection = () => {
    const ansibleCollectionId = parseInt(this.props.match.params.id, 10);
    this.props.getAnsibleCollectionDetails(ansibleCollectionId);
  };

  handleBreadcrumbSwitcherItem = (e, url) => {
    this.props.history.push(url);
    e.preventDefault();
  };

  render() {
    const { ansibleCollectionDetails } = this.props;
    const {
      loading, name, namespace, version,
    } = ansibleCollectionDetails;

    const resource = {
      nameField: 'name',
      resourceUrl: api.getApiUrl('/ansible_collections'),
      switcherItemUrl: '/ansible_collections/:id',
    };

    return (
      <div>
        {!loading && <BreadcrumbsBar
          onSwitcherItemClick={(e, url) => this.handleBreadcrumbSwitcherItem(e, url)}
          data={{
            isSwitchable: true,
            breadcrumbItems: [
              {
                caption: __('Ansible Collection Details'),
                onClick: () =>
                  this.props.history.push('/ansible_collections'),
              },
              {
                caption: `${name}-${namespace}-${version}`,
              },
            ],
            resource,
          }}
        />}
        <ContentDetails
          contentDetails={ansibleCollectionDetails}
          schema={ansibleCollectionsSchema(ansibleCollectionDetails)}
        />
      </div>
    );
  }
}

AnsibleCollectionDetails.propTypes = {
  getAnsibleCollectionDetails: PropTypes.func.isRequired,
  history: PropTypes.shape({ push: PropTypes.func.isRequired }).isRequired,
  location: PropTypes.shape({}).isRequired,
  match: PropTypes.shape({
    params: PropTypes.shape({
      id: PropTypes.string.isRequired,
    }).isRequired,
  }).isRequired,
  ansibleCollectionDetails: PropTypes.shape({
    loading: PropTypes.bool,
    name: PropTypes.string,
    namespace: PropTypes.string,
    version: PropTypes.string,
    // Disabling rule as existing code failed due to an eslint-plugin-react update
    /* eslint-disable react/forbid-prop-types */
    repositories: PropTypes.array,
    tags: PropTypes.array,
    /* eslint-enable react/forbid-prop-types */
  }).isRequired,
};

export default AnsibleCollectionDetails;
