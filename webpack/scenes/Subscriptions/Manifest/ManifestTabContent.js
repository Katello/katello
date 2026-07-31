import React, { useState } from 'react';
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
  Title,
} from '@patternfly/react-core';
import Slot from 'foremanReact/components/common/Slot';
import { translate as __ } from 'foremanReact/common/I18n';
import TooltipButton from '../../../components/TooltipButton';
import DeleteManifestModalText from './DeleteManifestModalText';
import { DELETE_MANIFEST_MODAL_ID } from './ManifestConstants';

const getManifestName = organization => {
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

const ManifestTabContent = ({
  showSubscriptionManifest,
  organization,
  manifestExpiringSoon,
  manifestExpired,
  manifestExpirationDate,
  manifestExpireDaysRemaining,
  isManifestImported,
  canImportManifest,
  canDeleteManifest,
  actionInProgress,
  disableManifestActions,
  disabledReason,
  taskInProgress,
  upload,
  refresh,
  delete: deleteManifestAction,
}) => {
  const [isDeleteManifestModalOpen, setIsDeleteManifestModalOpen] = useState(false);

  const disabledTooltipText = () => {
    if (taskInProgress) {
      return __('This is disabled because a manifest task is in progress');
    }
    return __('This is disabled because no manifest exists');
  };

  const uploadManifest = (fileList) => {
    if (fileList.length > 0) {
      upload(fileList[0]);
    }
  };

  const manifestExpiredMessage = manifestExpirationDate
    ? __('Your manifest expired on {expirationDate}. To continue using Red Hat content, import a new manifest.')
    : __('Your manifest has expired. To continue using Red Hat content, import a new manifest.');

  return (
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
            {getManifestName(organization)}
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
                onChange={e => uploadManifest(e.target.files)}
              />
            }
            <div id="manifest-actions-row">
              {canImportManifest &&
                <TooltipButton
                  onClick={refresh}
                  tooltipId="refresh-manifest-button-tooltip"
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
                  variant="danger"
                  disabled={!isManifestImported || actionInProgress}
                  onClick={() => setIsDeleteManifestModalOpen(true)}
                  title={__('Delete')}
                  tooltipId="delete-manifest-button-tooltip"
                  tooltipText={disabledTooltipText()}
                  tooltipPlacement="top"
                />
              }
            </div>
            <Modal
              isOpen={isDeleteManifestModalOpen}
              onClose={() => setIsDeleteManifestModalOpen(false)}
              title={__('Confirm delete manifest')}
              id={DELETE_MANIFEST_MODAL_ID}
              ouiaId={DELETE_MANIFEST_MODAL_ID}
              key={DELETE_MANIFEST_MODAL_ID}
              variant={ModalVariant.small}
              actions={[
                <Button
                  key="cancel-btn"
                  variant="link"
                  ouiaId="delete-manifest-cancel-button"
                  onClick={() => setIsDeleteManifestModalOpen(false)}
                >
                  {__('Cancel')}
                </Button>,
                <Button
                  key="delete-btn"
                  variant="danger"
                  ouiaId="delete-manifest-confirm-button"
                  onClick={deleteManifestAction}
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
};

ManifestTabContent.propTypes = {
  showSubscriptionManifest: PropTypes.bool.isRequired,
  organization: PropTypes.shape({
    owner_details: PropTypes.shape({
      upstreamConsumer: PropTypes.shape({
        uuid: PropTypes.string,
        name: PropTypes.string,
        webUrl: PropTypes.string,
      }),
    }),
  }).isRequired,
  manifestExpiringSoon: PropTypes.bool,
  manifestExpired: PropTypes.bool,
  manifestExpirationDate: PropTypes.string,
  manifestExpireDaysRemaining: PropTypes.number,
  isManifestImported: PropTypes.bool,
  canImportManifest: PropTypes.bool,
  canDeleteManifest: PropTypes.bool,
  actionInProgress: PropTypes.bool,
  disableManifestActions: PropTypes.bool,
  disabledReason: PropTypes.string,
  taskInProgress: PropTypes.bool.isRequired,
  upload: PropTypes.func.isRequired,
  refresh: PropTypes.func.isRequired,
  delete: PropTypes.func.isRequired,
};

ManifestTabContent.defaultProps = {
  manifestExpiringSoon: false,
  manifestExpired: false,
  manifestExpirationDate: null,
  manifestExpireDaysRemaining: null,
  isManifestImported: false,
  canImportManifest: false,
  canDeleteManifest: false,
  actionInProgress: false,
  disableManifestActions: false,
  disabledReason: '',
};

export default ManifestTabContent;
