import React, { useEffect, useRef, useState } from 'react';
import PropTypes from 'prop-types';
import {
  Button,
  Modal,
  ModalVariant,
  Tab,
  Tabs,
  TabContent,
  TabTitleText,
} from '@patternfly/react-core';
import { propsToCamelCase } from 'foremanReact/common/helpers';
import { translate as __ } from 'foremanReact/common/I18n';
import Loading from 'foremanReact/components/Loading';
import { MANAGE_MANIFEST_MODAL_ID } from './ManifestConstants';
import {
  MANIFEST_TAB,
  HISTORY_TAB,
  CDN_TAB,
  getDefaultTabKey,
} from './ManageManifestModalConstants';
import { CONTENT_CREDENTIAL_CERT_TYPE } from '../../ContentCredentials/ContentCredentialConstants';
import ManifestHistoryContent from './ManifestHistoryContent';
import ManifestTabContent from './ManifestTabContent';
import CdnTabContent from './CdnTabContent';

const ManageManifestModal = ({
  isOpen,
  closeModal,
  upload,
  refresh,
  delete: deleteManifestAction,
  loadManifestHistory,
  getContentCredentials,
  loadOrganization,
  organization,
  disableManifestActions,
  disabledReason,
  canImportManifest,
  canDeleteManifest,
  isManifestImported,
  canEditOrganizations,
  taskInProgress,
  manifestActionStarted,
  manifestHistory,
  contentCredentials,
}) => {
  const showSubscriptionManifest = canImportManifest || canDeleteManifest;
  const showManifestTab = canEditOrganizations || showSubscriptionManifest;

  const [activeTabKey, setActiveTabKey] = useState(() => getDefaultTabKey(showManifestTab));

  useEffect(() => {
    if (isOpen) {
      setActiveTabKey(getDefaultTabKey(showManifestTab));
    }
  }, [isOpen, showManifestTab, organization.id]);

  const manifestTabRef = useRef(null);
  const historyTabRef = useRef(null);
  const cdnTabRef = useRef(null);
  const prevTaskInProgress = useRef(taskInProgress);

  useEffect(() => {
    loadManifestHistory();
    getContentCredentials({ content_type: CONTENT_CREDENTIAL_CERT_TYPE });
  }, [loadManifestHistory, getContentCredentials]);

  useEffect(() => {
    if (!prevTaskInProgress.current && taskInProgress) {
      closeModal();
    }

    if (prevTaskInProgress.current && !taskInProgress) {
      loadOrganization({ force_manifest_expire_cache: true });
      loadManifestHistory();
    }

    prevTaskInProgress.current = taskInProgress;
  }, [taskInProgress, closeModal, loadOrganization, loadManifestHistory]);

  const {
    manifestExpiringSoon,
    manifestExpired,
    manifestExpirationDate,
    manifestExpireDaysRemaining,
  } = propsToCamelCase(organization);

  const actionInProgress = (taskInProgress || manifestActionStarted);
  const showCdnConfigurationTab = canEditOrganizations;

  return (
    <Modal
      isOpen={isOpen}
      onClose={closeModal}
      id={MANAGE_MANIFEST_MODAL_ID}
      ouiaId={MANAGE_MANIFEST_MODAL_ID}
      key={MANAGE_MANIFEST_MODAL_ID}
      title={__('Manage Manifest')}
      variant={ModalVariant.large}
      actions={[
        <Button
          key="close-modal"
          variant="primary"
          ouiaId="manage-manifest-close-button"
          onClick={closeModal}
        >
          {__('Close')}
        </Button>,
      ]}
    >
      <div id="manifest-history-tabs">
        <Tabs
          activeKey={activeTabKey}
          onSelect={(_event, tabKey) => setActiveTabKey(tabKey)}
          ouiaId="manifest-history-tabs"
        >
          {showManifestTab &&
            <Tab
              eventKey={MANIFEST_TAB}
              id="manifest-history-tabs-tab-1"
              ouiaId="manifest-history-tabs-tab-manifest"
              title={<TabTitleText>{__('Manifest')}</TabTitleText>}
              tabContentId="manifest-history-tabs-pane-1"
              tabContentRef={manifestTabRef}
            />
          }
          <Tab
            eventKey={HISTORY_TAB}
            id="manifest-history-tabs-tab-2"
            ouiaId="manifest-history-tabs-tab-history"
            title={<TabTitleText>{__('Manifest History')}</TabTitleText>}
            tabContentId="manifest-history-tabs-pane-2"
            tabContentRef={historyTabRef}
          />
          {showCdnConfigurationTab &&
            <Tab
              eventKey={CDN_TAB}
              id="manifest-history-tabs-tab-3"
              ouiaId="manifest-history-tabs-tab-cdn"
              title={<TabTitleText>{__('CDN Configuration')}</TabTitleText>}
              tabContentId="manifest-history-tabs-pane-3"
              tabContentRef={cdnTabRef}
            />
          }
        </Tabs>
        {showManifestTab &&
          <TabContent
            eventKey={MANIFEST_TAB}
            id="manifest-history-tabs-pane-1"
            ref={manifestTabRef}
            ouiaId="manifest-history-tabs-pane-manifest"
            hidden={activeTabKey !== MANIFEST_TAB}
          >
            <ManifestTabContent
              showSubscriptionManifest={showSubscriptionManifest}
              organization={organization}
              manifestExpiringSoon={manifestExpiringSoon}
              manifestExpired={manifestExpired}
              manifestExpirationDate={manifestExpirationDate}
              manifestExpireDaysRemaining={manifestExpireDaysRemaining}
              isManifestImported={isManifestImported}
              canImportManifest={canImportManifest}
              canDeleteManifest={canDeleteManifest}
              actionInProgress={actionInProgress}
              disableManifestActions={disableManifestActions}
              disabledReason={disabledReason}
              upload={upload}
              refresh={refresh}
              delete={deleteManifestAction}
            />
          </TabContent>
        }
        <TabContent
          eventKey={HISTORY_TAB}
          id="manifest-history-tabs-pane-2"
          ref={historyTabRef}
          ouiaId="manifest-history-tabs-pane-history"
          hidden={activeTabKey !== HISTORY_TAB}
        >
          {manifestHistory.loading ?
            <Loading showText /> :
            <ManifestHistoryContent manifestHistory={manifestHistory} />
          }
        </TabContent>
        {showCdnConfigurationTab &&
          <TabContent
            eventKey={CDN_TAB}
            id="manifest-history-tabs-pane-3"
            ref={cdnTabRef}
            ouiaId="manifest-history-tabs-pane-cdn"
            hidden={activeTabKey !== CDN_TAB}
          >
            <CdnTabContent
              cdnConfiguration={organization.cdn_configuration}
              contentCredentials={contentCredentials}
              onUpdate={() => loadOrganization()}
            />
          </TabContent>
        }
      </div>
    </Modal>
  );
};

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
