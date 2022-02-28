import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { LoadingState } from 'patternfly-react';

class SystemStatuses extends Component {
  componentDidMount() {
    this.props.getSystemStatuses('/katello/api/ping');
  }

  render() {
    const { services, status } = this.props;
    const isLoading = status === 'PENDING';

    return (
      <div className="col-md-7">
        <div className="stats-well">
          <h4>{__('Backend System Status')}</h4>
          <LoadingState loading={isLoading} loadingText="">
            <table className="table table-striped">
              <tbody>
                <tr>
                  <th>{__('Component')}</th>
                  <th>{__('Status')}</th>
                  <th>{__('Message')}</th>
                </tr>

                {Object.entries(services).map(([key, value]) => (
                  <tr key={key}>
                    <td> {key} </td>
                    <td>{value.status.toUpperCase()}</td>
                    <td> {value.message}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </LoadingState>
        </div>
      </div>
    );
  }
}

SystemStatuses.propTypes = {
  getSystemStatuses: PropTypes.func.isRequired,
  services: PropTypes.shape({}),
  status: PropTypes.string,
};

SystemStatuses.defaultProps = {
  services: {},
  status: '',
};

export default SystemStatuses;
