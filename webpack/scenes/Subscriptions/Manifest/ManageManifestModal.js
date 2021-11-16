import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { Grid, Col, Row, Tabs, Tab, Form, FormGroup, FormControl, ControlLabel } from 'react-bootstrap';
import { Button, Spinner } from 'patternfly-react';
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
import SimpleContentAccess from './SimpleContentAccess';

import './ManageManifestModal.scss';

const PASSWORD_PLACEHOLDER = '******';

class ManageManifestModal extends Component {
  constructor(props) {
    super(props);
    this.state = {
      cdn_url: null,
      cdn_username: null,
      cdn_password: null,
      cdn_organization_label: null,
      cdn_ssl_ca_credential_id: null,
    };
  }

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

  updateCdnUrl = (event) => {
    this.setState({ cdn_url: event.target.value });
  };

  updateCdnUsername = (event) => {
    this.setState({ cdn_username: event.target.value });
  };

  hidePasswordPlaceholder = (event) => {
    const { target } = event;
    target.value = this.state.cdn_password;
  };

  showPasswordPlaceholder = (event) => {
    if (this.state.cdn_password || this.props.organization.cdn_configuration.password_exists) {
      const { target } = event;
      target.value = PASSWORD_PLACEHOLDER;
    }
  };

  updateCdnPassword = (event) => {
    this.setState({ cdn_password: event.target.value });
  };

  updateCdnOrganizationLabel = (event) => {
    this.setState({ cdn_organization_label: event.target.value });
  };

  updateCdnSSLCaCredentialId = (event) => {
    this.setState({ cdn_ssl_ca_credential_id: event.target.value });
  };

  updateCdnConfiguration = () => {
    this.props.updateCdnConfiguration({
      url: this.state.cdn_url,
      username: this.state.cdn_username,
      password: this.state.cdn_password,
      upstream_organization_label: this.state.cdn_organization_label,
      ssl_ca_credential_id: this.state.cdn_ssl_ca_credential_id,
    });
  };

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
      isManifestImported,
      canEditOrganizations,
      simpleContentAccess,
      simpleContentAccessEligible,
      enableSimpleContentAccess,
      disableSimpleContentAccess,
      taskInProgress,
      manifestActionStarted,
      updatingCdnConfiguration,
      contentCredentials,
    } = this.props;

    const contentCredentialOptions = contentCredentials.map(({ name, id }) => (
      <option key={id} value={id}>
        {name}
      </option>
    ));

    const cdnPasswordDefaultValue = organization?.cdn_configuration?.password_exists ?
      PASSWORD_PLACEHOLDER : this.state.cdn_password;

    const actionInProgress = (taskInProgress || manifestActionStarted);
    const showRedHatProviderDetails = canEditOrganizations;
    const showSubscriptionManifest = (canImportManifest || canDeleteManifest);
    const showManifestTab = (showRedHatProviderDetails || showSubscriptionManifest);
    const disableSCASwitch = (
      // allow users to turn SCA off even if they are not eligible to turn it back on
      (!simpleContentAccessEligible && !simpleContentAccess) ||
      disableManifestActions ||
      !isManifestImported ||
      actionInProgress ||
      organization.loading
    );

    const emptyStateData = () => ({
      header: __('There is no Manifest History to display.'),
      description: __('Import a Manifest using the manifest tab above.'),
      documentation: {
        label: __('Learn more about adding Subscription Manifests'),
        url: 'http://redhat.com',
      },
    });
    const buttonLoading = (
      <span>
        {__('Updating...')}
        <span className="fa fa-spinner fa-spin" />
      </span>);
    const getManifestName = () => {
      let name = __('No Manifest Uploaded');

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

    return (
      <ForemanModal id={MANAGE_MANIFEST_MODAL_ID} title={__('Manage Manifest')}>
        <Tabs id="manifest-history-tabs">
          {showManifestTab &&
            <Tab eventKey={1} title={__('Manifest')}>
              <Form className="form-horizontal">
                {showRedHatProviderDetails &&
                  <React.Fragment>
                    <h3>{__('CDN Configuration for Red Hat content')}</h3>
                    <hr />
                    <FormGroup>
                      <Grid>
                        <Row>
                          <Col sm={5}>
                            <ControlLabel htmlFor="cdnUrl">
                              {__('URL')}
                            </ControlLabel>
                          </Col>
                          <Col sm={7}>
                            <FormControl
                              id="cdnUrl"
                              type="text"
                              defaultValue={this.state.cdn_url || organization.cdn_configuration.url || ''}
                              onChange={this.updateCdnUrl}
                            />
                          </Col>
                        </Row>
                        <Row style={{ paddingTop: '10px' }} >
                          <Col sm={5}>
                            <ControlLabel htmlFor="cdnUsername">
                              {__('Username')}
                            </ControlLabel>
                          </Col>
                          <Col sm={7}>
                            <FormControl
                              id="cdnUsername"
                              type="text"
                              defaultValue={this.state.cdn_username || organization.cdn_configuration.username || ''}
                              onChange={this.updateCdnUsername}
                            />
                          </Col>
                        </Row>
                        <Row style={{ paddingTop: '10px' }} >
                          <Col sm={5}>
                            <ControlLabel htmlFor="cdnPassword">
                              {__('Password')}
                            </ControlLabel>
                          </Col>
                          <Col sm={7}>
                            <FormControl
                              id="cdnPassword"
                              type="text"
                              defaultValue={cdnPasswordDefaultValue}
                              onFocus={this.hidePasswordPlaceholder}
                              onBlur={this.showPasswordPlaceholder}
                              onChange={this.updateCdnPassword}
                            />
                          </Col>
                        </Row>
                        <Row style={{ paddingTop: '10px' }} >
                          <Col sm={5}>
                            <ControlLabel htmlFor="cdnSSLCaCredential">
                              {__('SSL CA Content Credential')}
                            </ControlLabel>
                          </Col>
                          <Col sm={7}>
                            <FormControl
                              componentClass="select"
                              placeholder="select"
                              defaultValue={organization.cdn_configuration.ssl_ca_credential_id}
                              onChange={this.updateCdnSSLCaCredentialId}
                            >
                              <option value="" />
                              {contentCredentialOptions}
                            </FormControl>
                          </Col>
                        </Row>
                        <Row style={{ paddingTop: '10px' }} >
                          <Col sm={5}>
                            <ControlLabel htmlFor="cdnOrganizationLabel">
                              {__('Organization Label')}
                            </ControlLabel>
                          </Col>
                          <Col sm={7}>
                            <FormControl
                              id="cdnOrganizationLabel"
                              type="text"
                              defaultValue={this.state.cdn_organization_label || organization.cdn_configuration.upstream_organization_label || ''}
                              onChange={this.updateCdnOrganizationLabel}
                            />
                          </Col>
                        </Row>
                      </Grid>
                    </FormGroup>
                    <FormGroup>
                      <Grid>
                        <Row>
                          <Col smOffset={5} sm={7}>
                            <Button
                              id="updateCdnConfiguration"
                              data-testid="updateCdnConfiguration"
                              onClick={this.updateCdnConfiguration}
                              disabled={updatingCdnConfiguration}
                            >
                              {updatingCdnConfiguration ? buttonLoading : __('Update')}
                            </Button>
                          </Col>
                        </Row>
                      </Grid>
                    </FormGroup>
                    <br />
                  </React.Fragment>
                }
                {showSubscriptionManifest &&
                  <React.Fragment>

                    <FormGroup>
                      <Grid>
                        <h3>{__('Subscription Manifest')}</h3>
                        <hr />
                        { isManifestImported &&
                          <Row>
                            <SimpleContentAccess
                              enableSimpleContentAccess={enableSimpleContentAccess}
                              disableSimpleContentAccess={disableSimpleContentAccess}
                              isSimpleContentAccessEnabled={simpleContentAccess}
                              canToggleSimpleContentAccess={!disableSCASwitch}
                              simpleContentAccessEligible={simpleContentAccessEligible}
                            />
                          </Row>
                        }
                        <Row>
                          <Col sm={5}>
                            <strong>{__('Subscription Allocation')}</strong>
                          </Col>
                          <Col sm={7}>
                            {getManifestName()}
                          </Col>
                        </Row>
                        <Row>
                          <Col sm={5}>
                            {canImportManifest &&
                              <ControlLabel
                                style={{ paddingTop: '10px' }}
                              >
                                <div>{__('Import New Manifest')}</div>
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
                              <DeleteManifestModalText />
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
                    </FormGroup>
                  </React.Fragment>
                }
                <Slot id="katello-manage-manifest-form" multi />
              </Form>
            </Tab>
          }
          <Tab eventKey={2} title={__('Manifest History')}>
            <LoadingState loading={manifestHistory.loading} loadingText={__('Loading')}>
              <Table
                rows={manifestHistory.results}
                columns={columns}
                emptyState={emptyStateData()}
              />
            </LoadingState>
          </Tab>
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
  enableSimpleContentAccess: PropTypes.func.isRequired,
  disableSimpleContentAccess: PropTypes.func.isRequired,
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
  isManifestImported: PropTypes.bool,
  deleteManifestModalExists: PropTypes.bool,
  canEditOrganizations: PropTypes.bool,
  disableManifestActions: PropTypes.bool,
  disabledReason: PropTypes.string,
  loadOrganization: PropTypes.func.isRequired,
  updateCdnConfiguration: PropTypes.func.isRequired,
  taskInProgress: PropTypes.bool.isRequired,
  simpleContentAccess: PropTypes.bool,
  simpleContentAccessEligible: PropTypes.bool,
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
  updatingCdnConfiguration: PropTypes.bool,
};

ManageManifestModal.defaultProps = {
  disableManifestActions: false,
  disabledReason: '',
  canImportManifest: false,
  canDeleteManifest: false,
  isManifestImported: false,
  deleteManifestModalExists: false,
  canEditOrganizations: false,
  simpleContentAccess: false,
  simpleContentAccessEligible: undefined,
  manifestActionStarted: false,
  updatingCdnConfiguration: false,
  contentCredentials: [],
};

export default ManageManifestModal;
