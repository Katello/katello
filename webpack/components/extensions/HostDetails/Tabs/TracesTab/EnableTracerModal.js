import React, { useState } from 'react';
import PropTypes from 'prop-types';
import {
  Button,
  Flex,
  FlexItem,
  Modal,
  ModalVariant,
  Dropdown,
  DropdownItem,
  DropdownToggle,
} from '@patternfly/react-core';
import { CaretDownIcon } from '@patternfly/react-icons';
import { translate as __ } from 'foremanReact/common/I18n';
import { useSelector } from 'react-redux';
import { selectAPIResponse } from 'foremanReact/redux/API/APISelectors';
import { katelloPackageInstallUrl } from '../customizedRexUrlHelpers';
import { KATELLO_TRACER_PACKAGE } from './HostTracesConstants';

const EnableTracerModal = ({ isOpen, setIsOpen, triggerJobStart }) => {
  const title = __('Enable Tracer');
  const body = __('Enabling will install the katello-host-tools-tracer package on the host.');
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
      width="28em"
      isOpen={isOpen}
      onClose={handleClose}
      actions={[
        getEnableTracerButton(),
        <Button key="cancel_button" ouiaId="cancel-button" variant="link" onClick={() => setIsOpen(false)}>{__('Cancel')}</Button>,
      ]}
    >
      <Flex direction={{ default: 'column' }}>
        <FlexItem>{body}</FlexItem>
        <FlexItem><div>{__('Select a provider to install katello-host-tools-tracer')}</div></FlexItem>
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
};

export default EnableTracerModal;
