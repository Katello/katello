import React, { useContext, useState } from 'react';
import { translate as __ } from 'foremanReact/common/I18n';
import { FormattedMessage } from 'react-intl';
import { TreeView, Button, Text, TextContent, TextVariants, Flex, FlexItem, Dropdown, DropdownItem, DropdownToggle } from '@patternfly/react-core';
import { useWizardContext } from '@patternfly/react-core/next';
import { CaretDownIcon } from '@patternfly/react-icons';
import { BulkErrataWizardContext } from './BulkErrataWizard';

export const dropdownOptions = [
  __('via remote execution'),
  __('via customized remote execution'),
];

export const BulkErrataReview = () => {
  const { goToStepById } = useWizardContext();
  const {
    finishButtonText,
    selectedRexOption,
    setSelectedRexOption,
    finishButtonLoading,
    errataBulkSelect: {
      selectedResults: selectedErrataResults,
      selectedCount: currentSelectedErrataCount,
      areAllRowsSelected: allErrataSelected,
      searchQuery: errataSearchQuery,
    },
    hostsBulkSelect: {
      selectedCount: currentSelectedHostsCount,
    },
  } = useContext(BulkErrataWizardContext);
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const toggleDropdownOpen = () => setIsDropdownOpen(prev => !prev);
  const handleSelect = () => {
    setIsDropdownOpen(false);
  };

  const dropdownItems = dropdownOptions.map(text => (
    <DropdownItem key={`option_${text}`} ouiaId={`option_${text}`} onClick={() => setSelectedRexOption(text)}>{text}</DropdownItem>
  ));

  const treeViewTitle = __('Errata to apply');
  const treeViewData = [
    {
      name: treeViewTitle,
      id: 'errata-treeview-title',
      customBadgeContent: allErrataSelected() && errataSearchQuery === '' ? 'All' : currentSelectedErrataCount,
      children: allErrataSelected() ? undefined :
        selectedErrataResults.map(({ id, name, errata_id: errataId }) => ({
          name: `${errataId}: ${name}`,
          id,
          key: id,
        })),
      action: (
        <Button
          ouiaId="link-to-errata-wizard-step-2"
          variant="link"
          type="button"
          aria-label="Edit errata list"
          onClick={() => goToStepById('mew-step-1')}
        >
          {__('Edit')}
        </Button>
      ),
      actionProps: {
        'aria-label': 'Edit errata list',
      },
    },
  ];

  const hostTreeViewData = [
    {
      name: __('Hosts'),
      id: 'errata-host-treeview-title',
      customBadgeContent: currentSelectedHostsCount,
      expandedIcon: null,
      action: (
        <Button
          ouiaId="link-to-errata-wizard-step-3"
          variant="link"
          type="button"
          aria-label="Edit host selection"
          onClick={() => goToStepById('mew-step-3')}
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
        <Text ouiaId="mew-step-3-header" component={TextVariants.h3}>
          {__('Review')}
        </Text>
        <Text ouiaId="mew-step-3-content" component={TextVariants.p}>
          <FormattedMessage
            id="bulkErrataReviewContent"
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
            <Text ouiaId="mew-step-3-content" component={TextVariants.p}>
              <FormattedMessage
                id="bulkErrataReviewContent"
                defaultMessage={__('Selected errata will be applied on {hostCount} hosts')}
                values={{
                  hostCount: currentSelectedHostsCount,
                }}
              />
            </Text>
          </TextContent>
        </FlexItem>
        <FlexItem>
          <Dropdown
            ouiaId="bulk-errata-wizard-dropdown"
            toggle={
              <DropdownToggle
                id="toggle-bulk-errata-wizard-dropdown"
                ouiaId="bulk-errata-wizard-dropdown-toggle"
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

export default BulkErrataReview;
