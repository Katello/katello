import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { Grid, Col, Row, Tabs, Tab, Form, FormGroup, FormControl, ControlLabel } from 'react-bootstrap';
import { Button, Spinner } from 'patternfly-react';
import ForemanModal from 'foremanReact/components/ForemanModal';
import { translate as __ } from 'foremanReact/common/I18n';
import TooltipButton from '../../../components/TooltipButton';
import { LoadingState } from '../../../components/LoadingState';
import { Table } from '../../../components/pf3Table';

import { columns } from './ManifestHistoryTableSchema';
import DeleteManifestModalText from './DeleteManifestModalText';
import { MANAGE_MANIFEST_MODAL_ID, DELETE_MANIFEST_MODAL_ID } from './ManifestConstants';
import SimpleContentAccess from './SimpleContentAccess';

import './ManageManifestModal.scss';

class ManageManifestModal extends Component {
  constructor(props) {
    super(props);

    this.state = {
      redhat_repository_url: null,
    };
  }

  componentDidMount() {
    this.props.loadManifestHistory();
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

  hideDeleteManifestModal = () =>
    this.props.setModalClosed({ id: DELETE_MANIFEST_MODAL_ID });

  updateRepositoryUrl = (event) => {
    this.setState({ redhat_repository_url: event.target.value });
  };

  saveOrganization = () => {
    this.props.saveOrganization({ redhat_repository_url: this.state.redhat_repository_url });
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
      enableSimpleContentAccess,
      disableSimpleContentAccess,
      taskInProgress,
      manifestActionStarted,
    } = this.props;

    const actionInProgress = (taskInProgress || manifestActionStarted);
    const showRedHatProviderDetails = canEditOrganizations;
    const showSubscriptionManifest = (canImportManifest || canDeleteManifest);
    const showManifestTab = (showRedHatProviderDetails || showSubscriptionManifest);
    const disableSCASwitch = (
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
                    <h3>{__('Red Hat Provider Details')}</h3>
                    <hr />
                    <FormGroup>
                      <Grid>
                        <Row>
                          <Col sm={5}>
                            <ControlLabel htmlFor="cdnUrl">
                              {__('Red Hat CDN URL')}
                            </ControlLabel>
                          </Col>
                          <Col sm={7}>
                            <FormControl
                              id="cdnUrl"
                              type="text"
                              defaultValue={this.state.redhat_repository_url || organization.redhat_repository_url || ''}
                              onBlur={this.updateRepositoryUrl}
                            />
                          </Col>
                        </Row>
                      </Grid>
                    </FormGroup>
                    <FormGroup>
                      <Grid>
                        <Row>
                          <Col smOffset={5} sm={7}>
                            <Button onClick={this.saveOrganization} disabled={organization.loading}>
                              {organization.loading ? buttonLoading : __('Update')}
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
                        <Row>
                          <SimpleContentAccess
                            enableSimpleContentAccess={enableSimpleContentAccess}
                            disableSimpleContentAccess={disableSimpleContentAccess}
                            isSimpleContentAccessEnabled={simpleContentAccess}
                            canToggleSimpleContentAccess={!disableSCASwitch}
                          />
                        </Row>
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
  organization: PropTypes.shape({
    loading: PropTypes.bool,
    redhat_repository_url: PropTypes.string,
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
  canEditOrganizations: PropTypes.bool,
  disableManifestActions: PropTypes.bool,
  disabledReason: PropTypes.string,
  loadOrganization: PropTypes.func.isRequired,
  saveOrganization: PropTypes.func.isRequired,
  taskInProgress: PropTypes.bool.isRequired,
  simpleContentAccess: PropTypes.bool,
  manifestHistory: PropTypes.shape({
    loading: PropTypes.bool,
    // Disabling rule as existing code failed due to an eslint-plugin-react update
    // eslint-disable-next-line react/forbid-prop-types
    results: PropTypes.array,
  }).isRequired,
  setModalClosed: PropTypes.func.isRequired,
  setModalOpen: PropTypes.func.isRequired,
  manifestActionStarted: PropTypes.bool,
};

ManageManifestModal.defaultProps = {
  disableManifestActions: false,
  disabledReason: '',
  canImportManifest: false,
  canDeleteManifest: false,
  isManifestImported: false,
  canEditOrganizations: false,
  simpleContentAccess: false,
  manifestActionStarted: false,
};

export default ManageManifestModal;
