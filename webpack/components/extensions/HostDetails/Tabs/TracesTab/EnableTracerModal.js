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
import { useSelector, useDispatch } from 'react-redux';
import { selectAPIResponse } from 'foremanReact/redux/API/APISelectors';
import { installTracerPackage } from './HostTracesActions';
import { katelloPackageInstallUrl } from '../customizedRexUrlHelpers';

const EnableTracerModal = ({ isOpen, setIsOpen }) => {
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
  const dispatch = useDispatch();
  const hostDetails = useSelector(state => selectAPIResponse(state, 'HOST_DETAILS'));
  const { name: hostname } = hostDetails;
  const handleSelect = () => {
    setIsDropdownOpen(false);
  };
  const enableTracer = () => {
    dispatch(installTracerPackage({ hostname }));
    setIsOpen(false);
  };

  const dropdownItems = dropdownOptions.map(text => (
    <DropdownItem key={`option_${text}`} onClick={() => setSelectedOption(text)}>{text}</DropdownItem>
  ));

  const customizedRexUrl = katelloPackageInstallUrl({ hostname });

  const getEnableTracerButton = () => {
    const [viaRex] = dropdownOptions;
    if (selectedOption === viaRex) {
      return (
        <Button
          key="enable_button"
          type="submit"
          variant="primary"
          onClick={enableTracer}
        >
          {title}
        </Button>
      );
    }
    return (
      <Button
        key="enable_button"
        component="a"
        isLoading={buttonLoading}
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
      width="28em"
      isOpen={isOpen}
      onClose={() => setIsOpen(false)}
      actions={[
        getEnableTracerButton(),
        <Button key="cancel_button" variant="link" onClick={() => setIsOpen(false)}>{__('Cancel')}</Button>,
      ]}
    >
      <Flex direction={{ default: 'column' }}>
        <FlexItem>{body}</FlexItem>
        <FlexItem><div>{__('Select a provider to install katello-host-tools-tracer')}</div></FlexItem>
        <FlexItem>
          <Dropdown
            toggle={
              <DropdownToggle
                id="toggle-enable-tracer-modal-dropdown"
                onToggle={toggleDropdownOpen}
                toggleIndicator={CaretDownIcon}
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
};

export default EnableTracerModal;
