import React, { useState } from 'react';
import PropTypes from 'prop-types';
import {
  Button,
  Flex,
  FlexItem,
  Modal,
  ModalVariant,
  Text,
  TextContent,
} from '@patternfly/react-core';
import {
  Dropdown,
  DropdownItem,
  DropdownToggle,
} from '@patternfly/react-core/deprecated';
import { CaretDownIcon } from '@patternfly/react-icons';
import { translate as __ } from 'foremanReact/common/I18n';
import { useSelector } from 'react-redux';
import { selectAPIResponse } from 'foremanReact/redux/API/APISelectors';
import { katelloPackageInstallUrl } from '../customizedRexUrlHelpers';
import { KATELLO_TRACER_PACKAGE } from './HostTracesConstants';
import TracerPrerequisites from './TracerPrerequisites';
import './EnableTracerModal.scss';

const EnableTracerModal = ({
  isOpen, setIsOpen, triggerJobStart, tracerAvailable, isDebHost,
}) => {
  const title = __('Enable Tracer');
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const [buttonLoading, setButtonLoading] = useState(false);
  const toggleDropdownOpen = () => setIsDropdownOpen(prev => !prev);
  const dropdownOptions = [
    __('via remote execution'),
    __('via customized remote execution'),
  ];
  const [selectedOption, setSelectedOption] = useState(dropdownOptions[0]);
  const hostDetails = useSelector(state => selectAPIResponse(state, 'HOST_DETAILS'));
  const { name: hostname } = hostDetails;
  const handleSelect = () => {
    setIsDropdownOpen(false);
  };
  const handleClose = () => {
    setIsOpen(false);
  };
  const enableTracer = () => {
    setButtonLoading(true);
    triggerJobStart();
    handleClose();
  };

  const debPrereqItems = [
    {
      text: __('The Foreman Client DEB repository is enabled and synced. '),
      href: '/products',
      linkText: __('View products'),
      id: 'enable-tracer-deb-products-link',
    },
    {
      text: __("The Foreman Client DEB repository is available in the host's content view environment(s). "),
      href: '/content_views',
      linkText: __('View content views'),
      id: 'enable-tracer-deb-cv-link',
    },
    {
      text: __('The Foreman Client DEB repository set is enabled for the host. '),
      href: '#/Content/Repository%20sets',
      linkText: __('Enable repository sets'),
      id: 'enable-tracer-deb-reposets-link',
      itemId: 'enable-repo-deb-sets-p',
    },
    { text: __('Remote execution is enabled.') },
  ];

  const rpmPrereqItems = [
    {
      text: __('The Foreman Client repository is enabled. '),
      href: '/redhat_repositories',
      linkText: __('Enable Red Hat repositories'),
      id: 'enable-tracer-enable-red-hat-repos-link',
    },
    {
      text: __('The Foreman Client repository is synced. '),
      href: '/katello/sync_management',
      linkText: __('View sync status'),
      id: 'enable-tracer-sync-status-link',
    },
    {
      text: __("The Foreman Client repository is available in the host's content view environment(s). "),
      href: '/content_views',
      linkText: __('View content views'),
      id: 'enable-tracer-cv-link',
    },
    {
      text: __('The Foreman Client repository set is enabled for the host. '),
      href: '#/Content/Repository%20sets',
      linkText: __('Enable repository sets'),
      id: 'enable-tracer-reposets-link',
      itemId: 'enable-repo-sets-p',
    },
    { text: __('Remote execution is enabled.') },
  ];

  const body = (
    <TextContent>
      <Text ouiaId="enable-tracer-modal-text" id="enable-tracer-modal-p">
        {__('Enabling Tracer requires installing the katello-host-tools-tracer package on the host.')}
      </Text>
      {!tracerAvailable && (
        <TracerPrerequisites
          items={isDebHost ? debPrereqItems : rpmPrereqItems}
          onLinkClick={() => setButtonLoading(true)}
        />
      )}
    </TextContent>
  );

  const dropdownItems = dropdownOptions.map(text => (
    <DropdownItem key={`option_${text}`} ouiaId={`option_${text}`} onClick={() => setSelectedOption(text)}>{text}</DropdownItem>
  ));

  const customizedRexUrl = katelloPackageInstallUrl({ hostname, packages: KATELLO_TRACER_PACKAGE });

  const getEnableTracerButton = () => {
    const [viaRex] = dropdownOptions;
    if (selectedOption === viaRex) {
      return (
        <Button
          key="enable_button"
          ouiaId="enable-button-via-rex"
          type="submit"
          variant="primary"
          isLoading={buttonLoading}
          isDisabled={buttonLoading}
          onClick={enableTracer}
        >
          {title}
        </Button>
      );
    }
    return (
      <Button
        key="enable_button"
        ouiaId="enable-button-via-customized-rex"
        component="a"
        isLoading={buttonLoading}
        isDisabled={buttonLoading}
        onClick={() => setButtonLoading(true)}
        variant="primary"
        href={customizedRexUrl}
      >
        {title}
      </Button>
    );
  };

  return (
    <Modal
      variant={ModalVariant.small}
      title={title}
      ouiaId="enable-tracer-modal"
      width="46em"
      isOpen={isOpen}
      onClose={handleClose}
      actions={[
        getEnableTracerButton(),
        <Button key="cancel_button" ouiaId="cancel-button" variant="link" onClick={() => setIsOpen(false)}>{__('Cancel')}</Button>,
      ]}
    >
      <Flex direction={{ default: 'column' }}>
        <FlexItem>{body}</FlexItem>
        <FlexItem>
          <TextContent>
            <Text ouiaId="enable-tracer-modal-provider-text">
              {tracerAvailable
                ? __('Select a provider to install katello-host-tools-tracer')
                : __('Once the prerequisites are met, select a provider to install katello-host-tools-tracer')}
            </Text>
          </TextContent>
        </FlexItem>
        <FlexItem>
          <Dropdown
            ouiaId="enable-tracer-modal-dropdown"
            toggle={
              <DropdownToggle
                id="toggle-enable-tracer-modal-dropdown"
                ouiaId="enable-tracer-modal-dropdown-toggle"
                onToggle={toggleDropdownOpen}
                toggleIndicator={CaretDownIcon}
                isDisabled={buttonLoading}
              >
                {selectedOption}
              </DropdownToggle>
            }
            onSelect={handleSelect}
            isOpen={isDropdownOpen}
            dropdownItems={dropdownItems}
            menuAppendTo="parent"
          />
        </FlexItem>
      </Flex>
    </Modal>
  );
};

EnableTracerModal.propTypes = {
  isOpen: PropTypes.bool.isRequired,
  setIsOpen: PropTypes.func.isRequired,
  triggerJobStart: PropTypes.func.isRequired,
  tracerAvailable: PropTypes.bool,
  isDebHost: PropTypes.bool,
};

EnableTracerModal.defaultProps = {
  tracerAvailable: false,
  isDebHost: false,
};

export default EnableTracerModal;
