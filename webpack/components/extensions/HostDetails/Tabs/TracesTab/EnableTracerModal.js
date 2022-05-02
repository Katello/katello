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
import { KATELLO_TRACER_PACKAGE } from './HostTracesConstants';

const EnableTracerModal = ({ isOpen, setIsOpen, startRexJobPolling }) => {
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
    setButtonLoading(true);
    dispatch(installTracerPackage({
      hostname,
      handleSuccess: (resp) => {
        const jobId = resp?.data?.id;
        if (!jobId) return;
        startRexJobPolling({ jobId });
      },
    }));
  };
  const handleClose = () => {
    setIsOpen(false);
    setButtonLoading(false);
  };

  const dropdownItems = dropdownOptions.map(text => (
    <DropdownItem key={`option_${text}`} onClick={() => setSelectedOption(text)}>{text}</DropdownItem>
  ));

  const customizedRexUrl = katelloPackageInstallUrl({ hostname, packages: KATELLO_TRACER_PACKAGE });

  const getEnableTracerButton = () => {
    const [viaRex] = dropdownOptions;
    if (selectedOption === viaRex) {
      return (
        <Button
          key="enable_button"
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
      width="28em"
      isOpen={isOpen}
      onClose={handleClose}
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
  startRexJobPolling: PropTypes.func.isRequired,
};

export default EnableTracerModal;
