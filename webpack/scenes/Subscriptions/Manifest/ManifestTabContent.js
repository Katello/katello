import React, { useEffect, useRef, useState } from 'react';
import PropTypes from 'prop-types';
import { FormattedMessage } from 'react-intl';
import {
  Alert,
  Button,
  FileUpload,
  Grid,
  GridItem,
  Modal,
  ModalVariant,
  Spinner,
  Title,
  Flex,
  FlexItem,
  Stack,
  StackItem,
} from '@patternfly/react-core';
import Slot from 'foremanReact/components/common/Slot';
import { translate as __ } from 'foremanReact/common/I18n';
import TooltipButton from '../../../components/TooltipButton';
import DeleteManifestModalText from './DeleteManifestModalText';
import { DELETE_MANIFEST_MODAL_ID } from './ManifestConstants';

const MANIFEST_UPLOAD_ACCEPT = {
  'application/zip': ['.zip'],
  'application/x-zip-compressed': ['.zip'],
};

const getManifestName = (organization) => {
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
  upload,
  refresh,
  delete: deleteManifestAction,
}) => {
  const [isDeleteManifestModalOpen, setIsDeleteManifestModalOpen] = useState(false);
  const [isDeleteManifestPending, setIsDeleteManifestPending] = useState(false);
  const [manifestUploadValidated, setManifestUploadValidated] = useState('default');
  const [manifestFilename, setManifestFilename] = useState('');
  const [manifestFile, setManifestFile] = useState(null);
  const skipDuplicateUploadRef = useRef(false);

  useEffect(() => {
    if (!actionInProgress) {
      setIsDeleteManifestPending(false);
    }
  }, [actionInProgress]);

  const closeDeleteManifestModal = () => {
    if (!actionInProgress && !isDeleteManifestPending) {
      setIsDeleteManifestModalOpen(false);
    }
  };

  const confirmDeleteManifest = () => {
    setIsDeleteManifestPending(true);
    deleteManifestAction();
  };

  const isDeleteModalBusy = isDeleteManifestPending || actionInProgress;

  const disabledTooltipText = () => {
    if (actionInProgress) {
      return __('This is disabled because a manifest task is in progress');
    }
    return __('This is disabled because no manifest exists');
  };

  const isRefreshDisabled =
    !isManifestImported || actionInProgress || disableManifestActions;

  const handleManifestFileChange = (_event, file) => {
    if (!file) return;
    if (skipDuplicateUploadRef.current) {
      skipDuplicateUploadRef.current = false;
      return;
    }
    skipDuplicateUploadRef.current = true;
    setManifestUploadValidated('default');
    setManifestFilename(file.name);
    setManifestFile(file);
    upload(file);
  };

  const handleManifestFileClear = () => {
    setManifestUploadValidated('default');
    setManifestFilename('');
    setManifestFile(null);
    skipDuplicateUploadRef.current = false;
  };

  const handleManifestFileRejected = () => {
    setManifestUploadValidated('error');
  };

  const manifestExpiredMessage = manifestExpirationDate
    ? __('Your manifest expired on {expirationDate}. To continue using Red Hat content, import a new manifest.')
    : __('Your manifest has expired. To continue using Red Hat content, import a new manifest.');

  return (
    <>
      {showSubscriptionManifest && (
        <Grid hasGutter>
          <GridItem span={12}>
            <Title
              headingLevel="h3"
              size="lg"
              ouiaId="subscription-manifest-title"
            >
              {__('Subscription Manifest')}
            </Title>
          </GridItem>
          {manifestExpiringSoon && (
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
          )}
          {manifestExpired && isManifestImported && (
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
          )}
          <GridItem span={5}>
            <strong>{__('Manifest')}</strong>
          </GridItem>
          <GridItem span={7}>{getManifestName(organization)}</GridItem>
          {isManifestImported && Boolean(manifestExpirationDate) && (
            <>
              <GridItem span={5} />
              <GridItem span={7}>
                {manifestExpired ? __('Expired ') : __('Expires ')}
                {new Date(manifestExpirationDate).toDateString()}
              </GridItem>
            </>
          )}
          <GridItem span={5}>
            {canImportManifest && <strong>{__('Import new manifest')}</strong>}
          </GridItem>
          <GridItem span={7}>
            <Stack hasGutter>
              <StackItem>
                {canImportManifest && (
                  <Grid>
                    <GridItem span={8}>
                      <FileUpload
                        id="manifest-file-upload"
                        value={manifestFile}
                        filename={manifestFilename}
                        hideDefaultPreview
                        browseButtonText={__('Upload')}
                        clearButtonText={__('Clear')}
                        filenamePlaceholder={__('Drag here')}
                        validated={manifestUploadValidated}
                        isDisabled={actionInProgress}
                        onFileInputChange={handleManifestFileChange}
                        onClearClick={handleManifestFileClear}
                        dropzoneProps={{
                          accept: MANIFEST_UPLOAD_ACCEPT,
                          onReadFinished: () =>
                            setManifestUploadValidated('default'),
                          onDropRejected: handleManifestFileRejected,
                        }}
                      >
                        {manifestUploadValidated === 'error'
                          ? __('Only .zip manifest files are accepted')
                          : __('Upload a zip file')}
                      </FileUpload>
                    </GridItem>
                  </Grid>
                )}
              </StackItem>
              <StackItem>
                <Flex
                  alignItems={{ default: 'alignItemsCenter' }}
                  spaceItems={{ default: 'spaceItemsSm' }}
                >
                  {canImportManifest && (
                    <FlexItem>
                      <TooltipButton
                        onClick={() => refresh()}
                        tooltipId="refresh-manifest-button-tooltip"
                        tooltipText={disabledReason}
                        tooltipPlacement="top"
                        title={__('Refresh')}
                        variant="tertiary"
                        disabled={isRefreshDisabled}
                      />
                    </FlexItem>
                  )}
                  {canDeleteManifest && (
                    <FlexItem>
                      <TooltipButton
                        variant="danger"
                        disabled={!isManifestImported || actionInProgress}
                        onClick={() => setIsDeleteManifestModalOpen(true)}
                        title={__('Delete')}
                        tooltipId="delete-manifest-button-tooltip"
                        tooltipText={disabledTooltipText()}
                        tooltipPlacement="top"
                      />
                    </FlexItem>
                  )}
                  {actionInProgress && (
                    <FlexItem>
                      <Spinner size="md" aria-label={__('Loading')} />
                    </FlexItem>
                  )}
                </Flex>
              </StackItem>
            </Stack>
            <Modal
              isOpen={isDeleteManifestModalOpen}
              onClose={closeDeleteManifestModal}
              showClose={!isDeleteModalBusy}
              title={__('Confirm delete manifest')}
              titleIconVariant="danger"
              id={DELETE_MANIFEST_MODAL_ID}
              ouiaId={DELETE_MANIFEST_MODAL_ID}
              key={DELETE_MANIFEST_MODAL_ID}
              variant={ModalVariant.small}
              actions={[
                <Button
                  key="delete-btn"
                  variant="danger"
                  ouiaId="delete-manifest-confirm-button"
                  isDisabled={isDeleteModalBusy}
                  onClick={confirmDeleteManifest}
                >
                  {__('Delete')}
                </Button>,
                <Button
                  key="cancel-btn"
                  variant="link"
                  ouiaId="delete-manifest-cancel-button"
                  isDisabled={isDeleteModalBusy}
                  onClick={closeDeleteManifestModal}
                >
                  {__('Cancel')}
                </Button>,
              ]}
            >
              <DeleteManifestModalText />
            </Modal>
          </GridItem>
        </Grid>
      )}
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
