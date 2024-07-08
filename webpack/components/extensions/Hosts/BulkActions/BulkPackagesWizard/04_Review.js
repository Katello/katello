import React, { useContext, useState } from 'react';
import { translate as __ } from 'foremanReact/common/I18n';
import { FormattedMessage } from 'react-intl';
import { TreeView, Button, Text, TextContent, TextVariants, Flex, FlexItem, Dropdown, DropdownItem, DropdownToggle } from '@patternfly/react-core';
import { useWizardContext } from '@patternfly/react-core/next';
import { CaretDownIcon } from '@patternfly/react-icons';
import { BulkPackagesWizardContext, UPGRADE_ALL, INSTALL, REMOVE, UPGRADE } from './BulkPackagesWizard';

export const dropdownOptions = [
  __('via remote execution'),
  __('via customized remote execution'),
];

export const BulkPackagesReview = () => {
  const { goToStepById } = useWizardContext();
  const {
    selectedAction,
    finishButtonText,
    selectedRexOption,
    setSelectedRexOption,
    finishButtonLoading,
    packagesBulkSelect: {
      selectedResults: selectedPackageResults,
      selectedCount: currentSelectedPackagesCount,
    },
    hostsBulkSelect: {
      selectedCount: currentSelectedHostsCount,
    },
  } = useContext(BulkPackagesWizardContext);

  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const toggleDropdownOpen = () => setIsDropdownOpen(prev => !prev);
  const handleSelect = () => {
    setIsDropdownOpen(false);
  };

  const dropdownItems = dropdownOptions.map(text => (
    <DropdownItem key={`option_${text}`} ouiaId={`option_${text}`} onClick={() => setSelectedRexOption(text)}>{text}</DropdownItem>
  ));

  const packageActionsDescriptions = {
    [INSTALL]: __('Packages to install'),
    [REMOVE]: __('Packages to be removed'),
    [UPGRADE]: __('Packages to be updated'),
  };

  const treeViewTitle = packageActionsDescriptions[selectedAction];
  const treeViewData = [
    {
      name: treeViewTitle,
      id: 'packages-treeview-title',
      customBadgeContent: selectedAction === UPGRADE_ALL ? 'All' : currentSelectedPackagesCount,
      children: selectedAction === UPGRADE_ALL ? undefined :
        selectedPackageResults.map(({ id, name }) => ({
          name,
          id,
          key: id,
        })),
      action: (
        <Button
          ouiaId="link-to-packages-wizard-step-2"
          variant="link"
          type="button"
          aria-label="Edit packages list"
          onClick={() => goToStepById(selectedAction === UPGRADE_ALL ? 'mpw-step-1' : 'mpw-step-2')}
        >
          {__('Edit')}
        </Button>
      ),
      actionProps: {
        'aria-label': 'Edit packages list',
      },
    },
  ];

  const hostTreeViewData = [
    {
      name: __('Hosts'),
      id: 'packages-host-treeview-title',
      customBadgeContent: currentSelectedHostsCount,
      expandedIcon: null,
      action: (
        <Button
          ouiaId="link-to-packages-wizard-step-3"
          variant="link"
          type="button"
          aria-label="Edit host selection"
          onClick={() => goToStepById('mpw-step-3')}
        >
          {__('Edit')}
        </Button>
      ),
      actionProps: {
        'aria-label': 'Edit host selection',
      },
    },
  ];

  return (
    <>
      <TextContent>
        <Text ouiaId="mpw-step-3-header" component={TextVariants.h3}>
          {__('Review')}
        </Text>
        <Text ouiaId="mpw-step-3-content" component={TextVariants.p}>
          <FormattedMessage
            id="bulkPackagesReviewContent"
            defaultMessage={__('Review and then click {submitBtnText}.')}
            values={{
              submitBtnText: <strong>{finishButtonText}</strong>,
            }}
          />
        </Text>
      </TextContent>
      <div style={{ width: '70%', maxHeight: '50%', marginBottom: '2rem' }}>
        <TreeView
          data={treeViewData}
          aria-label={treeViewTitle}
          hasBadges
        />
        <TreeView
          data={hostTreeViewData}
          aria-label={__('Hosts')}
          hasBadges
        />
      </div>
      <Flex direction={{ default: 'row' }}>
        <FlexItem>
          <TextContent>
            <Text ouiaId="mpw-step-3-content" component={TextVariants.p}>
              <FormattedMessage
                id="bulkPackagesReviewContent"
                defaultMessage={__('Selected packages will be {submitAction} on {hostCount} hosts')}
                values={{
                  submitAction: selectedAction === 'install' ? __('installed') : __('updated'),
                  hostCount: currentSelectedHostsCount,
                }}
              />
            </Text>
          </TextContent>
        </FlexItem>
        <FlexItem>
          <Dropdown
            ouiaId="bulk-packages-wizard-dropdown"
            toggle={
              <DropdownToggle
                id="toggle-bulk-packages-wizard-dropdown"
                ouiaId="bulk-packages-wizard-dropdown-toggle"
                onToggle={toggleDropdownOpen}
                toggleIndicator={CaretDownIcon}
                isDisabled={finishButtonLoading}
              >
                {selectedRexOption}
              </DropdownToggle>
            }
            onSelect={handleSelect}
            isOpen={isDropdownOpen}
            dropdownItems={dropdownItems}
            menuAppendTo="parent"
          />
        </FlexItem>
      </Flex>
    </>
  );
};

export default BulkPackagesReview;
