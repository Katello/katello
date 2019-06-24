import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { Col, Tabs, Tab, Form, FormGroup, FormControl, ControlLabel } from 'react-bootstrap';
import { Button, Icon, Modal, Spinner, OverlayTrigger, Tooltip, MessageDialog } from 'patternfly-react';
import { isEqual } from 'lodash';
import TooltipButton from '../../../move_to_pf/TooltipButton';
import { LoadingState } from '../../../move_to_pf/LoadingState';
import { Table } from '../../../move_to_foreman/components/common/table';
import { manifestExists } from '../SubscriptionHelpers';
import { columns } from './ManifestHistoryTableSchema';
import DeleteManifestModalText from './DeleteManifestModalText';

class ManageManifestModal extends Component {
  constructor(props) {
    super(props);

    this.state = {
      showModal: props.showModal,
      actionInProgress: props.taskInProgress,
      showDeleteManifestModalDialog: false,
    };
  }

  static getDerivedStateFromProps(newProps, prevState) {
    if (
      !isEqual(newProps.showModal, prevState.showModal) ||
      !isEqual(newProps.taskInProgress, prevState.actionInProgress)
    ) {
      return {
        showModal: newProps.showModal,
        actionInProgress: newProps.taskInProgress,
      };
    }
    return null;
  }

  componentDidMount() {
    this.loadData();
  }

  componentDidUpdate(prevProp, prevState) {
    const { actionInProgress } = this.state;

    if (prevState.actionInProgress && !actionInProgress) {
      this.props.loadOrganization();
    }
  }

  loadData() {
    this.props.loadManifestHistory();
  }

  hideModal = () => {
    this.setState({ showModal: false, showDeleteManifestModalDialog: false });
    this.props.onClose();
  };

  updateRepositoryUrl = (event) => {
    this.setState({ redhat_repository_url: event.target.value });
  };

  saveOrganization = () => {
    this.props.saveOrganization({ redhat_repository_url: this.state.redhat_repository_url });
  };

  uploadManifest = (fileList) => {
    this.hideModal();
    this.setState({ actionInProgress: true });
    if (fileList.length > 0) {
      this.props.upload(fileList[0]);
    }
  };

  refreshManifest = () => {
    this.hideModal();
    this.setState({ actionInProgress: true });
    this.props.refresh();
  };

  deleteManifest = () => {
    this.hideModal();
    this.setState({ actionInProgress: true });
    this.props.delete();
    this.showDeleteManifestModal(false);
  };

  showDeleteManifestModal = (show) => {
    this.setState({
      showDeleteManifestModalDialog: show,
    });
  };

  disabledTooltipText = () => {
    if (this.state.actionInProgress) {
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
    } = this.props;

    const { actionInProgress } = this.state;

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
      <Modal show={this.state.showModal} onHide={this.hideModal}>
        <Modal.Header>
          <button
            className="close"
            onClick={this.hideModal}
            aria-label={__('Close')}
          >
            <Icon type="pf" name="close" />
          </button>
          <Modal.Title>{__('Manage Manifest')}</Modal.Title>
        </Modal.Header>
        <Modal.Body>
          <Tabs id="manifest-history-tabs">
            <Tab eventKey={1} title={__('Manifest')}>
              <Form className="form-horizontal">
                <h5>{__('Red Hat Provider Details')}</h5>
                <hr />
                <FormGroup>
                  <Col sm={3}>
                    <ControlLabel htmlFor="cdnUrl">
                      {__('Red Hat CDN URL')}
                    </ControlLabel>
                  </Col>
                  <Col sm={9}>
                    <FormControl
                      id="cdnUrl"
                      type="text"
                      defaultValue={this.state.redhat_repository_url || organization.redhat_repository_url || ''}
                      onBlur={this.updateRepositoryUrl}
                    />
                  </Col>
                </FormGroup>
                <FormGroup>
                  <Col smOffset={3} sm={3}>
                    <Button onClick={this.saveOrganization} disabled={organization.loading}>
                      {organization.loading ? buttonLoading : __('Update')}
                    </Button>
                  </Col>
                </FormGroup>
                <br />

                <h5>{__('Subscription Manifest')}</h5>
                <hr />

                <FormGroup>
                  <ControlLabel
                    className="col-sm-3 control-label"
                    htmlFor="usmaFile"
                  >
                    <OverlayTrigger
                      overlay={
                        <Tooltip id="usma-tooltip">
                          {__('Upstream Subscription Management Application')}
                        </Tooltip>
                      }
                      placement="bottom"
                      trigger={['hover', 'focus']}
                      rootClose={false}
                    >
                      <span>{__('USMA')}</span>
                    </OverlayTrigger>
                  </ControlLabel>

                  <Col sm={9} className="manifest-actions">
                    <Spinner loading={actionInProgress} inline />

                    {getManifestName()}

                    <FormControl
                      id="usmaFile"
                      type="file"
                      accept=".zip"
                      disabled={actionInProgress}
                      onChange={e => this.uploadManifest(e.target.files)}
                    />

                    <TooltipButton
                      onClick={this.refreshManifest}
                      tooltipId="refresh-manifest-button-tooltip"
                      tooltipText={disabledReason}
                      tooltipPlacement="top"
                      title={__('Refresh')}
                      disabled={!manifestExists(organization) ||
                        actionInProgress || disableManifestActions}
                    />

                    <TooltipButton
                      renderedButton={(
                        <Button
                          disabled={!manifestExists(organization) || actionInProgress}
                          bsStyle="danger"
                          onClick={() => this.showDeleteManifestModal(true)}
                        >
                          {__('Delete')}
                        </Button>
                        )}

                      tooltipId="delete-manifest-button-tooltip"
                      tooltipText={this.disabledTooltipText()}
                      tooltipPlacement="top"

                    />

                    <MessageDialog
                      show={this.state.showDeleteManifestModalDialog}
                      title={__('Confirm delete manifest')}
                      secondaryContent={
                        // eslint-disable-next-line react/no-danger
                        <p dangerouslySetInnerHTML={{
                        __html: DeleteManifestModalText,
                        }}
                        />
                      }
                      primaryActionButtonContent={__('Delete')}
                      primaryActionButtonBsStyle="danger"
                      primaryAction={() => this.deleteManifest()}
                      secondaryActionButtonContent={__('Cancel')}
                      secondaryAction={() => this.showDeleteManifestModal(false)}
                      onHide={() => this.showDeleteManifestModal(false)}
                      accessibleName="deleteConfirmationDialog"
                      accessibleDescription="deleteConfirmationDialogContent"
                    />
                  </Col>
                </FormGroup>
              </Form>
            </Tab>

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
        </Modal.Body>
        <Modal.Footer>
          <Button bsStyle="primary" onClick={this.hideModal}>
            {__('Close')}
          </Button>
        </Modal.Footer>
      </Modal>
    );
  }
}

ManageManifestModal.propTypes = {
  upload: PropTypes.func.isRequired,
  refresh: PropTypes.func.isRequired,
  delete: PropTypes.func.isRequired,
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
  disableManifestActions: PropTypes.bool,
  disabledReason: PropTypes.string,
  loadOrganization: PropTypes.func.isRequired,
  saveOrganization: PropTypes.func.isRequired,
  taskInProgress: PropTypes.bool.isRequired,
  manifestHistory: PropTypes.shape({
    loading: PropTypes.bool,
    results: PropTypes.array,
  }).isRequired,
  showModal: PropTypes.bool.isRequired,
  onClose: PropTypes.func,
};

ManageManifestModal.defaultProps = {
  disableManifestActions: false,
  disabledReason: '',
  onClose() {},
};

export default ManageManifestModal;
