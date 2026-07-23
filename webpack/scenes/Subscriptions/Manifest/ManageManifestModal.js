import React, { Component, createRef } from 'react';
import PropTypes from 'prop-types';
import { FormattedMessage } from 'react-intl';
import {
  Alert,
  Button,
  Divider,
  Grid,
  GridItem,
  Modal,
  ModalVariant,
  Spinner,
  Tab,
  Tabs,
  TabContent,
  TabTitleText,
  Title,
} from '@patternfly/react-core';
import { Table, Thead, Tbody, Tr, Th, Td } from '@patternfly/react-table';
import { propsToCamelCase, getDocsURL } from 'foremanReact/common/helpers';
import Slot from 'foremanReact/components/common/Slot';
import EmptyState from 'foremanReact/components/common/EmptyState';
import { translate as __ } from 'foremanReact/common/I18n';
import TooltipButton from '../../../components/TooltipButton';
import { LoadingState } from '../../../components/LoadingState';
import DeleteManifestModalText from './DeleteManifestModalText';
import { MANAGE_MANIFEST_MODAL_ID, DELETE_MANIFEST_MODAL_ID } from './ManifestConstants';
import { CONTENT_CREDENTIAL_CERT_TYPE } from '../../ContentCredentials/ContentCredentialConstants';
import CdnConfigurationForm from './CdnConfigurationTab';

import './ManageManifestModal.scss';

const MANIFEST_TAB = 1;
const HISTORY_TAB = 2;
const CDN_TAB = 3;

const getDefaultTabKey = ({
  canImportManifest,
  canDeleteManifest,
  canEditOrganizations,
}) => {
  const showSubscriptionManifest = canImportManifest || canDeleteManifest;
  const showManifestTab = canEditOrganizations || showSubscriptionManifest;
  return showManifestTab ? MANIFEST_TAB : HISTORY_TAB;
};

class ManageManifestModal extends Component {
  constructor(props) {
    super(props);
    this.state = {
      isDeleteManifestModalOpen: false,
      activeTabKey: getDefaultTabKey(props),
    };
    this.manifestTabRef = createRef();
    this.historyTabRef = createRef();
    this.cdnTabRef = createRef();
  }

  componentDidMount() {
    this.props.loadManifestHistory();
    this.props.getContentCredentials({ content_type: CONTENT_CREDENTIAL_CERT_TYPE });
  }

  componentDidUpdate(prevProps) {
    if (!prevProps.taskInProgress && this.props.taskInProgress) {
      this.props.closeModal();
    }

    if (prevProps.taskInProgress && !this.props.taskInProgress) {
      this.props.loadOrganization({ force_manifest_expire_cache: true });
      this.props.loadManifestHistory();
    }
  }

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

  renderManifestHistoryContent = () => {
    const { manifestHistory } = this.props;

    if (manifestHistory.results.length === 0) {
      return (
        <EmptyState
          header={__('There is no manifest history to display.')}
          description={__('Import a manifest using the Manifest tab above.')}
          documentation={{
            label: __('Learn more about adding subscription manifests in '),
            buttonLabel: __('the documentation.'),
            url: getDocsURL('Managing_Content', 'Managing_Red_Hat_Subscriptions_content-management'),
          }}
        />
      );
    }

    return (
      <Table
        ouiaId="manifest-history-table"
        aria-label={__('Manifest history table')}
      >
        <Thead>
          <Tr ouiaId="manifest-history-header-row">
            <Th>{__('Status')}</Th>
            <Th>{__('Message')}</Th>
            <Th>{__('Timestamp')}</Th>
          </Tr>
        </Thead>
        <Tbody>
          {manifestHistory.results.map(record => (
            <Tr
              key={`${record.created}-${record.statusMessage}`}
              ouiaId={`manifest-history-row-${record.created}`}
            >
              <Td>{record.status}</Td>
              <Td>{record.statusMessage}</Td>
              <Td>{record.created}</Td>
            </Tr>
          ))}
        </Tbody>
      </Table>
    );
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
      taskInProgress,
      manifestActionStarted,
      contentCredentials,
    } = this.props;

    const { activeTabKey } = this.state;

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

    const manifestTabContent = (
      <>
        {showSubscriptionManifest &&
          <Grid hasGutter>
            <GridItem span={12}>
              <Title headingLevel="h3" size="lg" ouiaId="subscription-manifest-title">
                {__('Subscription Manifest')}
              </Title>
            </GridItem>
            {manifestExpiringSoon &&
              <GridItem span={12}>
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
              </GridItem>
            }
            {manifestExpired && isManifestImported &&
              <GridItem span={12}>
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
              </GridItem>
            }
            <GridItem span={12}>
              <Divider />
            </GridItem>
            <GridItem span={5}>
              <strong>{__('Manifest')}</strong>
            </GridItem>
            <GridItem span={7}>
              {getManifestName()}
            </GridItem>
            {isManifestImported && Boolean(manifestExpirationDate) &&
              <>
                <GridItem span={5} />
                <GridItem span={7} ouiaId="manifest-expiration-date">
                  {manifestExpired ? __('Expired ') : __('Expires ')}
                  {new Date(manifestExpirationDate).toDateString()}
                </GridItem>
              </>
            }
            <GridItem span={5}>
              {canImportManifest &&
                <label htmlFor="usmaFile">{__('Import new manifest')}</label>
              }
            </GridItem>
            <GridItem span={7} className="manifest-actions">
              {actionInProgress &&
                <Spinner size="md" aria-label={__('Loading')} ouiaId="manifest-action-spinner" />
              }
              {canImportManifest &&
                <input
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
                    key="refresh-manifest-button-tooltip"
                    tooltipText={disabledReason}
                    tooltipPlacement="top"
                    title={__('Refresh')}
                    variant="tertiary"
                    disabled={!isManifestImported ||
                          actionInProgress || disableManifestActions}
                  />
                }
                {canDeleteManifest &&
                  <TooltipButton
                    disabled={!isManifestImported || actionInProgress}
                    variant="danger"
                    onClick={() => this.setState({ isDeleteManifestModalOpen: true })}
                    title={__('Delete')}
                    tooltipId="delete-manifest-button-tooltip"
                    key="delete-manifest-button-tooltip"
                    tooltipText={this.disabledTooltipText()}
                    tooltipPlacement="top"
                  />
                }
              </div>
              <Modal
                isOpen={this.state.isDeleteManifestModalOpen}
                onClose={() => this.setState({ isDeleteManifestModalOpen: false })}
                title={__('Confirm delete manifest')}
                id={DELETE_MANIFEST_MODAL_ID}
                ouiaId={DELETE_MANIFEST_MODAL_ID}
                key={DELETE_MANIFEST_MODAL_ID}
                variant={ModalVariant.small}
                actions={[
                  <Button ouiaId="delete-manifest-cancel-button" variant="link" key="cancel-btn" onClick={() => this.setState({ isDeleteManifestModalOpen: false })}>
                    {__('Cancel')}
                  </Button>,
                  <Button
                    ouiaId="delete-manifest-confirm-button"
                    key="delete-btn"
                    variant="danger"
                    onClick={this.deleteManifest}
                  >
                    {__('Delete')}
                  </Button>,
                ]}
              >
                <DeleteManifestModalText />
              </Modal>
            </GridItem>
          </Grid>
        }
        <Slot id="katello-manage-manifest-form" multi />
      </>
    );

    const cdnTabContent = (
      <Grid hasGutter>
        <GridItem span={12}>
          <Title headingLevel="h3" size="lg" ouiaId="cdn-configuration-title">
            {__('CDN Configuration for Red Hat Content')}
          </Title>
        </GridItem>
        <GridItem span={12}>
          <Divider />
        </GridItem>
        <GridItem span={12}>
          <CdnConfigurationForm
            cdnConfiguration={organization.cdn_configuration}
            contentCredentials={contentCredentials}
            onUpdate={this.reloadOrganization}
          />
        </GridItem>
      </Grid>
    );

    return (
      <Modal
        isOpen={this.props.isOpen}
        onClose={this.props.closeModal}
        id={MANAGE_MANIFEST_MODAL_ID}
        ouiaId={MANAGE_MANIFEST_MODAL_ID}
        key={MANAGE_MANIFEST_MODAL_ID}
        title={__('Manage Manifest')}
        variant={ModalVariant.large}
        actions={[
          <Button
            ouiaId="manage-manifest-close-button"
            variant="primary"
            key="close-modal"
            onClick={this.props.closeModal}
          >
            {__('Close')}
          </Button>,
        ]}
      >
        <div id="manifest-history-tabs">
          <Tabs
            activeKey={activeTabKey}
            onSelect={(_event, tabKey) => this.setState({ activeTabKey: tabKey })}
            ouiaId="manifest-history-tabs"
          >
            {showManifestTab &&
              <Tab
                eventKey={MANIFEST_TAB}
                id="manifest-history-tabs-tab-1"
                ouiaId="manifest-history-tabs-tab-manifest"
                title={<TabTitleText>{__('Manifest')}</TabTitleText>}
                tabContentId="manifest-history-tabs-pane-1"
                tabContentRef={this.manifestTabRef}
              />
            }
            <Tab
              eventKey={HISTORY_TAB}
              id="manifest-history-tabs-tab-2"
              ouiaId="manifest-history-tabs-tab-history"
              title={<TabTitleText>{__('Manifest History')}</TabTitleText>}
              tabContentId="manifest-history-tabs-pane-2"
              tabContentRef={this.historyTabRef}
            />
            {showCdnConfigurationTab &&
              <Tab
                eventKey={CDN_TAB}
                id="manifest-history-tabs-tab-3"
                ouiaId="manifest-history-tabs-tab-cdn"
                title={<TabTitleText>{__('CDN Configuration')}</TabTitleText>}
                tabContentId="manifest-history-tabs-pane-3"
                tabContentRef={this.cdnTabRef}
              />
            }
          </Tabs>
          {showManifestTab &&
            <TabContent
              eventKey={MANIFEST_TAB}
              id="manifest-history-tabs-pane-1"
              ref={this.manifestTabRef}
              ouiaId="manifest-history-tabs-pane-manifest"
              hidden={activeTabKey !== MANIFEST_TAB}
            >
              {manifestTabContent}
            </TabContent>
          }
          <TabContent
            eventKey={HISTORY_TAB}
            id="manifest-history-tabs-pane-2"
            ref={this.historyTabRef}
            ouiaId="manifest-history-tabs-pane-history"
            hidden={activeTabKey !== HISTORY_TAB}
          >
            <LoadingState loading={manifestHistory.loading} loadingText={__('Loading')}>
              {this.renderManifestHistoryContent()}
            </LoadingState>
          </TabContent>
          {showCdnConfigurationTab &&
            <TabContent
              eventKey={CDN_TAB}
              id="manifest-history-tabs-pane-3"
              ref={this.cdnTabRef}
              ouiaId="manifest-history-tabs-pane-cdn"
              hidden={activeTabKey !== CDN_TAB}
            >
              {cdnTabContent}
            </TabContent>
          }
        </div>
      </Modal>
    );
  }
}

ManageManifestModal.propTypes = {
  isOpen: PropTypes.bool.isRequired,
  closeModal: PropTypes.func.isRequired,
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
  isManifestImported: PropTypes.bool,
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
  isManifestImported: false,
  canEditOrganizations: false,
  manifestActionStarted: false,
  contentCredentials: [],
};

export default ManageManifestModal;
