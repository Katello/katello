import React, { Component } from 'react';
import BreadcrumbsBar from 'foremanReact/components/BreadcrumbBar';
import { translate as __ } from 'foremanReact/common/I18n';
import { PropTypes } from 'prop-types';
import api from '../../../services/api';
import ContentDetails from '../../../components/Content/Details/ContentDetails';
import moduleDetailsSchema from './ModuleDetailsSchema';

class ModuleStreamDetails extends Component {
  componentDidMount() {
    this.updateModuleStream();
  }

  componentDidUpdate(prevProps) {
    const { match: { params: prevRouterParams } } = this.props;
    const { match: { params: currentRouterParams } } = prevProps;
    if (prevRouterParams.id && (prevRouterParams.id !== currentRouterParams.id)) {
      this.updateModuleStream();
    }
  }

  updateModuleStream = () => {
    const moduleStreamId = parseInt(this.props.match.params.id, 10);
    this.props.loadModuleStreamDetails(moduleStreamId);
  };

  handleBreadcrumbSwitcherItem = (e, url) => {
    this.props.history.push(url);
    e.preventDefault();
  };

  render() {
    const { moduleStreamDetails } = this.props;
    const {
      loading, name, stream,
    } = moduleStreamDetails;

    const resource = {
      nameField: 'name_stream_version_context',
      resourceUrl: api.getApiUrl('/module_streams'),
      switcherItemUrl: '/module_streams/:id',
    };

    return (
      <div style={{ margin: '24px' }}>
        {!loading && <BreadcrumbsBar
          isLoadingResources={loading}
          onSwitcherItemClick={(e, url) => this.handleBreadcrumbSwitcherItem(e, url)}
          isSwitchable
          breadcrumbItems={[
            {
              caption: __('Module Streams'),
              url: '/module_streams/',
            },
            {
              caption: `${name} ${stream}`,
            },
          ]}
          resource={resource}
        />}
        <ContentDetails
          contentDetails={moduleStreamDetails}
          schema={moduleDetailsSchema(moduleStreamDetails)}
        />
      </div>
    );
  }
}

ModuleStreamDetails.propTypes = {
  loadModuleStreamDetails: PropTypes.func.isRequired,
  history: PropTypes.shape({ push: PropTypes.func.isRequired }).isRequired,
  location: PropTypes.shape({}).isRequired,
  match: PropTypes.shape({
    params: PropTypes.shape({
      id: PropTypes.string.isRequired,
    }).isRequired,
  }).isRequired,
  moduleStreamDetails: PropTypes.shape({
    loading: PropTypes.bool,
    name: PropTypes.string,
    // Disabling rule as existing code failed due to an eslint-plugin-react update
    /* eslint-disable react/forbid-prop-types */
    profiles: PropTypes.array,
    repositories: PropTypes.array,
    artifacts: PropTypes.array,
    /* eslint-enable react/forbid-prop-types */
    stream: PropTypes.string,
  }).isRequired,
};

export default ModuleStreamDetails;
