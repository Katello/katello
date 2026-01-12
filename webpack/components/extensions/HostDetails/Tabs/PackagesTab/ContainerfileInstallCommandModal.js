import React, { useEffect, useState } from 'react';
import { Modal, Button, ClipboardCopy, ClipboardCopyVariant, TextContent, Text, TextVariants, Spinner, Popover, Switch } from '@patternfly/react-core';
import { InfoCircleIcon, QuestionCircleIcon } from '@patternfly/react-icons';
import PropTypes from 'prop-types';
import { translate as __, sprintf, ngettext as n__ } from 'foremanReact/common/I18n';
import { useAPI } from 'foremanReact/common/hooks/API/APIHooks';

const ContainerfileInstallCommandModal = ({
  isOpen, closeModal, hostId, searchParams, selectedCount,
}) => {
  const [command, setCommand] = useState('');
  const [packageCount, setPackageCount] = useState(null);
  const [paramsReady, setParamsReady] = useState(false);
  const [includeUnknownPersistence, setIncludeUnknownPersistence] = useState(false);

  const apiUrl = `/api/hosts/${hostId}/transient_packages/containerfile_install_command`;

  // Empty string "" is a valid search query (means "match all")
  const hasValidParams = isOpen && searchParams != null;
  const shouldActivateAPI = hasValidParams && paramsReady;

  const { response, status, setAPIOptions } = useAPI(
    shouldActivateAPI ? 'get' : null,
    apiUrl,
  );

  // Set params BEFORE activating API
  useEffect(() => {
    if (hasValidParams) {
      setAPIOptions({
        params: {
          search: searchParams,
          include_unknown_persistence: includeUnknownPersistence,
        },
      });
      if (!paramsReady) {
        setParamsReady(true);
      }
    } else if (!hasValidParams && paramsReady) {
      // Reset when modal closes
      setParamsReady(false);
    }
  }, [hasValidParams, paramsReady, searchParams, includeUnknownPersistence, setAPIOptions]);

  useEffect(() => {
    if (status === 'RESOLVED' && response) {
      setCommand(response.command || '');
      setPackageCount(response.packageCount ?? 0);
    } else if (status === 'ERROR') {
      setPackageCount(0);
      setCommand('');
      window.tfm.toastNotifications.notify({
        message: __('Failed to generate Containerfile install command'),
        type: 'error',
      });
    }
  }, [status, response]);

  useEffect(() => {
    if (!isOpen) {
      setCommand('');
      setPackageCount(null);
      setIncludeUnknownPersistence(false);
    }
  }, [isOpen]);

  const handleCopy = async () => {
    if (!navigator.clipboard || !navigator.clipboard.writeText) {
      window.tfm.toastNotifications.notify({
        message: __('Clipboard API not available. Please copy manually.'),
        type: 'warning',
      });
      return;
    }

    try {
      await navigator.clipboard.writeText(command);
      closeModal();
    } catch {
      window.tfm.toastNotifications.notify({
        message: __('Failed to copy to clipboard. Please copy manually.'),
        type: 'error',
      });
    }
  };

  const isLoading = status === 'PENDING';
  const hasCompletedLoading = !isLoading && packageCount !== null;
  const isCopyDisabled = isLoading || !command;
  const hasNoPackages = packageCount === 0;

  const switchComponent = (
    <div style={{ marginBottom: 'var(--pf-v5-global--spacer--md)' }}>
      <Switch
        id="include-unknown-persistence-switch"
        label={__('Include packages with unknown persistence')}
        isChecked={includeUnknownPersistence}
        onChange={(_event, checked) => setIncludeUnknownPersistence(checked)}
        isReversed
        ouiaId="include-unknown-persistence-switch"
      />
    </div>
  );

  const renderModalBody = () => (
    <>
      {switchComponent}
      {(isLoading || packageCount === null) && <Spinner size="lg" />}
      {hasCompletedLoading && hasNoPackages && (
        <TextContent>
          <Text component={TextVariants.p} ouiaId="no-packages-text">
            <InfoCircleIcon /> {__('No transient packages found in selection')}
          </Text>
        </TextContent>
      )}
      {hasCompletedLoading && !hasNoPackages && (
        <>
          <ClipboardCopy isReadOnly hoverTip={__('Copy')} clickTip={__('Copied')} variant={ClipboardCopyVariant.expansion}>
            {command}
          </ClipboardCopy>
          <TextContent>
            <Text component={TextVariants.p} ouiaId="command-description-text">
              {sprintf(
                __('Command contains %(packageCount)s of %(selectedCount)s selected %(selectedWord)s'),
                {
                  packageCount,
                  selectedCount,
                  selectedWord: n__('package', 'packages', selectedCount),
                },
              )}
            </Text>
          </TextContent>
        </>
      )}
    </>
  );

  const modalActions = [
    <Button
      key="copy"
      variant="primary"
      onClick={handleCopy}
      isDisabled={isCopyDisabled}
      ouiaId="copy-button"
    >
      {__('Copy')}
    </Button>,
    <Button key="cancel" variant="link" onClick={closeModal} ouiaId="cancel-button">
      {__('Cancel')}
    </Button>,
  ];

  const helpPopover = (
    <Popover
      bodyContent={__('Add the command below to your Containerfile to incorporate the selected transient packages. When building your bootable container image, this will ensure these packages are installed permanently (as persistent packages).')}
    >
      <Button variant="plain" aria-label="Help" ouiaId="help-button">
        <QuestionCircleIcon />
      </Button>
    </Popover>
  );

  return (
    <Modal
      isOpen={isOpen}
      onClose={closeModal}
      title={__('Containerfile Install Command')}
      help={helpPopover}
      width="50%"
      actions={modalActions}
      id="containerfile-install-modal"
      ouiaId="containerfile-install-modal"
    >
      {renderModalBody()}
    </Modal>
  );
};

ContainerfileInstallCommandModal.propTypes = {
  isOpen: PropTypes.bool.isRequired,
  closeModal: PropTypes.func.isRequired,
  hostId: PropTypes.number.isRequired,
  searchParams: PropTypes.string,
  selectedCount: PropTypes.number,
};

ContainerfileInstallCommandModal.defaultProps = {
  searchParams: null,
  selectedCount: 0,
};

export default ContainerfileInstallCommandModal;
