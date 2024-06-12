import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { Grid, Col, Row, Tabs, Tab, FormControl, ControlLabel } from 'react-bootstrap';
import { FormattedMessage } from 'react-intl';
import { Button, Spinner } from 'patternfly-react';
import { Alert } from '@patternfly/react-core';
import { propsToCamelCase } from 'foremanReact/common/helpers';
import ForemanModal from 'foremanReact/components/ForemanModal';
import Slot from 'foremanReact/components/common/Slot';
import { translate as __ } from 'foremanReact/common/I18n';
import TooltipButton from '../../../components/TooltipButton';
import { LoadingState } from '../../../components/LoadingState';
import { Table } from '../../../components/pf3Table';

import { columns } from './ManifestHistoryTableSchema';
import DeleteManifestModalText from './DeleteManifestModalText';
import { MANAGE_MANIFEST_MODAL_ID, DELETE_MANIFEST_MODAL_ID } from './ManifestConstants';
import { CONTENT_CREDENTIAL_CERT_TYPE } from '../../ContentCredentials/ContentCredentialConstants';
import CdnConfigurationForm from './CdnConfigurationTab';

import './ManageManifestModal.scss';

class ManageManifestModal extends Component {
  componentDidMount() {
    this.props.loadManifestHistory();
    this.props.getContentCredentials({ content_type: CONTENT_CREDENTIAL_CERT_TYPE });
  }

  componentDidUpdate(prevProps) {
    if (!prevProps.taskInProgress && this.props.taskInProgress) {
      this.hideModal();
    }

    if (prevProps.taskInProgress && !this.props.taskInProgress) {
      this.props.loadOrganization();
      this.props.loadManifestHistory();
    }

    if (!prevProps.manifestActionStarted && this.props.manifestActionStarted) {
      this.hideDeleteManifestModal();
    }
  }

  hideModal = () => {
    this.props.setModalClosed({ id: MANAGE_MANIFEST_MODAL_ID });
  };

  showDeleteManifestModal = () =>
    this.props.setModalOpen({ id: DELETE_MANIFEST_MODAL_ID });

  hideDeleteManifestModal = () => {
    if (this.props.deleteManifestModalExists) {
      this.props.setModalClosed({ id: DELETE_MANIFEST_MODAL_ID });
    }
  };

  reloadOrganization = () => {
    this.props.loadOrganization();
  }

  uploadManifest = (fileList) => {
    if (fileList.length > 0) {
      this.props.upload(fileList[0]);
    }
  };

  refreshManifest = () => {
    this.props.refresh();
  };

  deleteManifest = () => {
    this.props.delete();
  };

  disabledTooltipText = () => {
    if (this.props.taskInProgress) {
      return __('This is disabled because a manifest task is in progress');
    }
    return __('This is disabled because no manifest exists');
  };

  render() {
    const {
      manifestHistory,
      organization,
      disableManifestActions,
      disabledReason,
      canImportManifest,
      canDeleteManifest,
      simpleContentAccess,
      isManifestImported,
      canEditOrganizations,
      taskInProgress,
      manifestActionStarted,
      contentCredentials,
    } = this.props;

    const {
      manifestExpiringSoon,
      manifestExpired,
      manifestExpirationDate,
      manifestExpireDaysRemaining,
    } = propsToCamelCase(organization);

    const actionInProgress = (taskInProgress || manifestActionStarted);
    const showCdnConfigurationTab = canEditOrganizations;
    const showSubscriptionManifest = (canImportManifest || canDeleteManifest);
    const showManifestTab = (canEditOrganizations || showSubscriptionManifest);

    const emptyStateData = () => ({
      header: __('There is no manifest history to display.'),
      description: __('Import a manifest using the Manifest tab above.'),
      documentation: {
        label: __('Learn more about adding subscription manifests '),
        url: 'https://access.redhat.com/solutions/3410771',
      },
    });

    const getManifestName = () => {
      let name = __('No manifest imported');

      if (
        organization.owner_details &&
        organization.owner_details.upstreamConsumer
      ) {
        const link = [
          'https://',
          organization.owner_details.upstreamConsumer.webUrl,
          organization.owner_details.upstreamConsumer.uuid,
        ].join('/');

        name = (
          <a href={link}>{organization.owner_details.upstreamConsumer.name}</a>
        );
      }

      return name;
    };

    const manifestExpiredMessage = manifestExpirationDate ? __('Your manifest expired on {expirationDate}. To continue using Red Hat content, import a new manifest.') : __('Your manifest has expired. To continue using Red Hat content, import a new manifest.');

    return (
      <ForemanModal id={MANAGE_MANIFEST_MODAL_ID} title={__('Manage Manifest')}>
        <Tabs id="manifest-history-tabs">
          {showManifestTab &&
            <Tab
              eventKey={1}
              title={__('Manifest')}
            >
                {showSubscriptionManifest &&
                  <React.Fragment>
                    <Grid>
                      <h3>{__('Subscription Manifest')}</h3>
                      {manifestExpiringSoon &&
                        <Alert
                          ouiaId="manifest-expiring-soon-alert"
                          variant="warning"
                          title={__('Manifest expiring soon')}
                        >
                          <FormattedMessage
                            defaultMessage={__('Your manifest will expire in {daysMessage}. To extend the expiration date, refresh your manifest. Or, if your Foreman is disconnected, import a new manifest.')}
                            values={{
                              daysMessage: (
                                <FormattedMessage
                                  defaultMessage="{daysRemaining, plural, one {{singular}} other {# {plural}}}"
                                  values={{
                                    daysRemaining: manifestExpireDaysRemaining,
                                    singular: __('day'),
                                    plural: __('days'),
                                  }}
                                  id="manage-manifest-expire-days-i18n"
                                />
                              ),
                            }}
                            id="manage-manifest-expire-i18n"
                          />
                        </Alert>
                      }
                      {manifestExpired && isManifestImported &&
                        <Alert
                          ouiaId="manifest-expired-alert"
                          variant="danger"
                          title={__('Manifest expired')}
                        >
                          <FormattedMessage
                            defaultMessage={manifestExpiredMessage}
                            values={{
                              expirationDate: new Date(manifestExpirationDate).toDateString(),
                            }}
                            id="manage-manifest-expired-i18n"
                          />
                        </Alert>
                      }
                      <hr />
                      <Row>
                        <Col sm={5}>
                          <strong>{__('Manifest')}</strong>
                        </Col>
                        <Col sm={7}>
                          {getManifestName()}
                        </Col>
                      </Row>
                      {isManifestImported && Boolean(manifestExpirationDate) &&
                        <Row>
                          <Col sm={5} />
                          <Col sm={7}>
                            {manifestExpired ? __('Expired ') : __('Expires ')}
                            {new Date(manifestExpirationDate).toDateString()}
                          </Col>
                        </Row>
                      }
                      <Row>
                        <Col sm={5}>
                          {canImportManifest &&
                          <ControlLabel
                            style={{ paddingTop: '10px' }}
                          >
                            <div>{__('Import new manifest')}</div>
                          </ControlLabel>
                          }
                        </Col>
                        <Col sm={7} className="manifest-actions">
                          <Spinner loading={actionInProgress} />
                          {canImportManifest &&
                          <FormControl
                            id="usmaFile"
                            type="file"
                            accept=".zip"
                            disabled={actionInProgress}
                            onChange={e => this.uploadManifest(e.target.files)}
                          />
                          }
                          <div id="manifest-actions-row">
                            {canImportManifest &&
                            <TooltipButton
                              onClick={this.refreshManifest}
                              tooltipId="refresh-manifest-button-tooltip"
                              tooltipText={disabledReason}
                              tooltipPlacement="top"
                              title={__('Refresh')}
                              disabled={!isManifestImported ||
                                    actionInProgress || disableManifestActions}
                            />
                            }
                            {canDeleteManifest &&
                            <React.Fragment>
                              <TooltipButton
                                disabled={!isManifestImported || actionInProgress}
                                bsStyle="danger"
                                onClick={this.showDeleteManifestModal}
                                title={__('Delete')}
                                tooltipId="delete-manifest-button-tooltip"
                                tooltipText={this.disabledTooltipText()}
                                tooltipPlacement="top"
                              />
                            </React.Fragment>
                            }
                          </div>
                          <ForemanModal title={__('Confirm delete manifest')} id={DELETE_MANIFEST_MODAL_ID}>
                            <DeleteManifestModalText simpleContentAccess={simpleContentAccess} />
                            <ForemanModal.Footer>
                              <Button bsStyle="default" onClick={this.hideDeleteManifestModal}>
                                {__('Cancel')}
                              </Button>
                              <Button bsStyle="danger" onClick={this.deleteManifest}>
                                {__('Delete')}
                              </Button>
                            </ForemanModal.Footer>
                          </ForemanModal>
                        </Col>
                      </Row>
                    </Grid>
                  </React.Fragment>
                }
              <Slot id="katello-manage-manifest-form" multi />
            </Tab>
          }
          <Tab
            eventKey={2}
            title={__('Manifest History')}
          >
            <LoadingState loading={manifestHistory.loading} loadingText={__('Loading')}>
              <Table
                rows={manifestHistory.results}
                columns={columns}
                emptyState={emptyStateData()}
              />
            </LoadingState>
          </Tab>
          {showCdnConfigurationTab &&
            <Tab
              eventKey={3}
              title={__('CDN Configuration')}
            >
              <Grid>
                <h3>{__('CDN Configuration for Red Hat Content')}</h3>
                <hr />
                <CdnConfigurationForm
                  cdnConfiguration={organization.cdn_configuration}
                  contentCredentials={contentCredentials}
                  onUpdate={this.reloadOrganization}
                />
              </Grid>
            </Tab>
          }
        </Tabs>
        <ForemanModal.Footer>
          <Button bsStyle="primary" onClick={this.hideModal}>
            {__('Close')}
          </Button>
        </ForemanModal.Footer>
      </ForemanModal>
    );
  }
}

ManageManifestModal.propTypes = {
  upload: PropTypes.func.isRequired,
  refresh: PropTypes.func.isRequired,
  delete: PropTypes.func.isRequired,
  loadManifestHistory: PropTypes.func.isRequired,
  getContentCredentials: PropTypes.func.isRequired,
  organization: PropTypes.shape({
    id: PropTypes.number,
    loading: PropTypes.bool,
    cdn_configuration: PropTypes.shape({
      url: PropTypes.string,
      username: PropTypes.string,
      upstream_organization_label: PropTypes.string,
      ssl_ca_credential_id: PropTypes.number,
      password_exists: PropTypes.bool,
    }),
    owner_details: PropTypes.shape({
      upstreamConsumer: PropTypes.shape({
        uuid: PropTypes.string,
        name: PropTypes.string,
        webUrl: PropTypes.string,
      }),
    }),
  }).isRequired,
  canImportManifest: PropTypes.bool,
  canDeleteManifest: PropTypes.bool,
  simpleContentAccess: PropTypes.bool,
  isManifestImported: PropTypes.bool,
  deleteManifestModalExists: PropTypes.bool,
  canEditOrganizations: PropTypes.bool,
  disableManifestActions: PropTypes.bool,
  disabledReason: PropTypes.string,
  loadOrganization: PropTypes.func.isRequired,
  taskInProgress: PropTypes.bool.isRequired,
  manifestHistory: PropTypes.shape({
    loading: PropTypes.bool,
    // Disabling rule as existing code failed due to an eslint-plugin-react update
    // eslint-disable-next-line react/forbid-prop-types
    results: PropTypes.array,
  }).isRequired,
  setModalClosed: PropTypes.func.isRequired,
  setModalOpen: PropTypes.func.isRequired,
  manifestActionStarted: PropTypes.bool,
  contentCredentials: PropTypes.arrayOf(PropTypes.shape({
    id: PropTypes.number,
    name: PropTypes.string,
  })),
};

ManageManifestModal.defaultProps = {
  disableManifestActions: false,
  disabledReason: '',
  canImportManifest: false,
  canDeleteManifest: false,
  simpleContentAccess: true,
  isManifestImported: false,
  deleteManifestModalExists: false,
  canEditOrganizations: false,
  manifestActionStarted: false,
  contentCredentials: [],
};

export default ManageManifestModal;
