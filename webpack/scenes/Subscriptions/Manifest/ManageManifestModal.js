import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { Col, Tabs, Tab, Form, FormGroup, FormControl, ControlLabel } from 'react-bootstrap';
import { bindMethods, Alert, Button, Icon, Modal, ProgressBar, Spinner, OverlayTrigger, Tooltip } from 'patternfly-react';
import TooltipButton from 'react-bootstrap-tooltip-button';
import { Table } from '../../../move_to_foreman/components/common/table';
import { columns } from './ManifestHistoryTableSchema';

class ManageManifestModal extends Component {
  constructor(props) {
    super(props);

    this.state = {
      showModal: props.showModal,
    };

    bindMethods(this, [
      'hideModal',
      'saveOrganization',
      'uploadManifest',
      'refreshManifest',
      'deleteManifest',
    ]);
  }

  componentDidMount() {
    this.loadData();
  }

  componentWillReceiveProps(props) {
    this.setState({ showModal: props.showModal });
  }

  loadData() {
    this.props.loadManifestHistory();
  }

  hideModal() {
    this.setState({ showModal: false });
    this.props.onClose();
  }

  saveOrganization(event) {
    this.props.saveOrganization({ redhat_repository_url: event.target.value });
  }

  uploadManifest(fileList) {
    if (fileList.length > 0) {
      this.props.uploadManifest(fileList[0]).then(this.props.loadOrganization);
    }
  }

  refreshManifest() {
    this.props.refreshManifest();
  }

  deleteManifest() {
    this.props.deleteManifest().then(this.props.loadOrganization);
  }

  render() {
    const {
      manifestHistory, organization, disableManifestActions, disabledReason, task,
    } = this.props;


    const emptyStateData = () => ({
      header: __('There is no Manifest History to display.'),
      description: __('Import a Manifest using the manifest tab above.'),
      documentation: {
        title: __('Learn more about adding Subscription Manifests'),
        url: 'http://redhat.com',
      },
    });

    const getManifestName = () => {
      let name = __('No Manifest Uploaded');

      if (organization.owner_details && organization.owner_details.upstreamConsumer) {
        const link = ['https://', organization.owner_details.upstreamConsumer.webUrl,
          organization.owner_details.upstreamConsumer.uuid].join('/');

        name = (
          <a href={link}>{organization.owner_details.upstreamConsumer.name}</a>
        );
      }

      return name;
    };

    const getAlerts = () => {
      const alerts = [];
      let type = 'success';
      let messages = [];

      if (task && !task.pending) {
        if (task.humanized) {
          messages = task.humanized.errors;
          type = task.result;

          if (task.result === 'success') {
            messages = [task.humanized.action +
            __(' Completed Successfully.')];
          }
        } else if (task && task.error) {
          messages = task.error.errors;
          type = 'error';
        }
      }

      for (let i = 0; i < messages.length; i += 1) {
        alerts.push(<Alert type={type} key={i}>{messages[i]}</Alert>);
      }

      return alerts;
    };

    const taskInProgress = task && task.pending;
    const getTaskProgress = () => Math.round(task.progress * 100);

    return (
      <Modal show={this.state.showModal} onHide={this.hideModal}>
        <Modal.Header>
          <button className="close" onClick={this.hideModal} aria-label={__('Close')}>
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
                  <ControlLabel className="col-sm-3" htmlFor="cdnUrl">
                    {__('Red Hat CDN URL')}
                  </ControlLabel>
                  <Col sm={9}>
                    <FormControl
                      id="cdnUrl"
                      type="text"
                      value={organization.redhat_repository_url}
                      onChange={this.saveOrganization}
                    />
                  </Col>
                </FormGroup>
                <br />

                <h5>{__('Subscription Manifest')}</h5>
                <hr />

                {getAlerts()}

                <FormGroup>
                  <ControlLabel className="col-sm-3 control-label" htmlFor="usmaFile">
                    <OverlayTrigger
                      overlay={
                        <Tooltip id="usma-tooltip">{__('Upstream Subscription Management Application')}</Tooltip>
                        }
                      placement="bottom"
                      trigger={['hover', 'focus']}
                      rootClose={false}
                    >
                      <span>{__('USMA')}</span>
                    </OverlayTrigger>
                  </ControlLabel>

                  <Col sm={9} className="manifest-actions">
                    {getManifestName()}

                    <FormControl
                      id="usmaFile"
                      type="file"
                      accept=".zip"
                      disabled={taskInProgress}
                      onChange={e => this.uploadManifest(e.target.files)}
                    />

                    <TooltipButton
                      onClick={this.refreshManifest}
                      tooltipId="refresh-manifest-button-tooltip"
                      tooltipText={disabledReason}
                      tooltipPlacement="top"
                      title={__('Refresh')}
                      disabled={taskInProgress || disableManifestActions}
                    />

                    <TooltipButton
                      onClick={this.deleteManifest}
                      tooltipId="delete-manifest-button-tooltip"
                      tooltipText={__('This is disabled because a manifest task is in progress.')}
                      tooltipPlacement="top"
                      title={__('Delete')}
                      disabled={taskInProgress}
                    />

                    {taskInProgress ?
                      <ProgressBar
                        active
                        now={getTaskProgress()}
                        label={getTaskProgress() + __('% Complete')}
                      />
                    : ''}
                  </Col>
                </FormGroup>
              </Form>
            </Tab>

            <Tab eventKey={2} title={__('Manifest History')}>
              <Spinner loading={manifestHistory.loading} className="small-spacer">
                <Table
                  rows={manifestHistory.results}
                  columns={columns}
                  emptyState={emptyStateData()}
                />
              </Spinner>
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
  uploadManifest: PropTypes.func.isRequired,
  refreshManifest: PropTypes.func.isRequired,
  deleteManifest: PropTypes.func.isRequired,
  loadManifestHistory: PropTypes.func.isRequired,
  organization: PropTypes.shape({}).isRequired,
  disableManifestActions: PropTypes.bool,
  disabledReason: PropTypes.string,
  loadOrganization: PropTypes.func.isRequired,
  saveOrganization: PropTypes.func.isRequired,
  task: PropTypes.shape({}),
  manifestHistory: PropTypes.shape({}).isRequired,
  showModal: PropTypes.bool.isRequired,
  onClose: PropTypes.func,
};

ManageManifestModal.defaultProps = {
  disableManifestActions: false,
  disabledReason: '',
  onClose() {},
  task: {},
};

export default ManageManifestModal;
