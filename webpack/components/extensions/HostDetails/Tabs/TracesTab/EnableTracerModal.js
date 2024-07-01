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
  Text,
  TextContent,
  TextList,
  TextListItem,
  Alert,
} from '@patternfly/react-core';
import { CaretDownIcon, ArrowRightIcon } from '@patternfly/react-icons';
import { translate as __ } from 'foremanReact/common/I18n';
import { useSelector } from 'react-redux';
import { selectAPIResponse } from 'foremanReact/redux/API/APISelectors';
import { katelloPackageInstallUrl } from '../customizedRexUrlHelpers';
import { KATELLO_TRACER_PACKAGE } from './HostTracesConstants';
import './EnableTracerModal.scss';

const EnableTracerModal = ({
  isOpen, setIsOpen, triggerJobStart, tracerRpmAvailable,
}) => {
  const title = __('Enable Tracer');
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const [buttonLoading, setButtonLoading] = useState(false);
  const toggleDropdownOpen = () => setIsDropdownOpen(prev => !prev);
  const dropdownOptions = [
    __('immediately'),
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

  const body = (
    <TextContent>
      <Text ouiaId="enable-tracer-modal-text" id="enable-tracer-modal-p">
        {__('Enabling Tracer requires installing the katello-host-tools-tracer package on the host.')}
      </Text>
      {!tracerRpmAvailable && (
        <>
          <Alert
            ouiaId="enable-tracer-modal-prereq-text"
            variant="warning"
            isInline
            title={__('Before continuing, ensure that all of the following prerequisites are met:')}
          />
          <TextList className="enable-tracer-modal-prereq-list">
            <TextListItem>
              {__('The Foreman Client repository is enabled. ')}
              <a onClick={() => setButtonLoading(true)} href="/redhat_repositories" id="enable-tracer-enable-red-hat-repos-link">
                {__('Enable Red Hat repositories')}
              </a>
              <ArrowRightIcon />
            </TextListItem>
            <TextListItem>
              {__('The Foreman Client repository is synced. ')}
              <a onClick={() => setButtonLoading(true)} href="/katello/sync_management" id="enable-tracer-sync-status-link">
                {__('View sync status')}
              </a>
              <ArrowRightIcon />
            </TextListItem>
            <TextListItem>
              {__('The Foreman Client repository is available in the host\'s content view environment(s). ')}
              <a onClick={() => setButtonLoading(true)} href="/content_views" id="enable-tracer-cv-link">
                {__('View content views')}
              </a>
              <ArrowRightIcon />
            </TextListItem>
            <TextListItem id="enable-repo-sets-p">
              {__('The Foreman Client repository set is enabled for the host. ')}
              <a onClick={() => setButtonLoading(true)} href="#/Content/Repository%20sets" id="enable-tracer-reposets-link">
                {__('Enable repository sets')}
              </a>
              <ArrowRightIcon />
            </TextListItem>
            <TextListItem>
              {__('Remote execution is enabled.')}
            </TextListItem>
          </TextList>
        </>
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
              {tracerRpmAvailable ? __('Select a provider to install katello-host-tools-tracer') :
                __('Once the prerequisites are met, select a provider to install katello-host-tools-tracer')}
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
  tracerRpmAvailable: PropTypes.bool.isRequired,
};

export default EnableTracerModal;
