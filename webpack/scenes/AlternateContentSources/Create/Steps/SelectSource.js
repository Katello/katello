import React, { useContext } from 'react';
import { translate as __ } from 'foremanReact/common/I18n';
import { Flex, FlexItem, Form, FormGroup, FormSelect, FormSelectOption, Tile } from '@patternfly/react-core';
import ACSCreateContext from '../ACSCreateContext';
import WizardHeader from '../../../ContentViews/components/WizardHeader';

const SelectSource = () => {
  const {
    acsType, setAcsType, contentType, setContentType,
  } = useContext(ACSCreateContext);

  const onSelect = (event) => {
    setAcsType(event.currentTarget.id);
  };
  const onKeyDown = (event) => {
    if (event.key === ' ' || event.key === 'Enter') {
      event.preventDefault();
      setAcsType(event.currentTarget.id);
    }
  };

  const typeOptions = [
    { value: 'yum', label: __('Yum') },
    { value: 'file', label: __('File') },
  ];

  return (
    <>
      <WizardHeader
        title={__('Select source type')}
        description={__('Indicate the source type.')}
      />
      <Form>
        <FormGroup
          label={__('Source type')}
          type="string"
          fieldId="source_type"
          isRequired
        >
          <Flex>
            <FlexItem>
              <Tile
                title={__('Custom')}
                isStacked
                id="custom"
                onClick={onSelect}
                onKeyDown={onKeyDown}
                isSelected={acsType === 'custom'}
              />{' '}
            </FlexItem>
            <FlexItem>
              <Tile
                title={__('Simplified')}
                isStacked
                id="simplified"
                onClick={onSelect}
                onKeyDown={onKeyDown}
                isSelected={acsType === 'simplified'}
              />{' '}
            </FlexItem>
          </Flex>
        </FormGroup>
        <FormGroup
          label={__('Content type')}
          type="string"
          fieldId="content_type"
          isRequired
        >
          <FormSelect
            isRequired
            value={contentType}
            onChange={(value) => {
              setContentType(value);
            }}
            aria-label="FormSelect Input"
          >
            {
                            typeOptions.map(option => (
                              <FormSelectOption
                                key={option.value}
                                value={option.value}
                                label={option.label}
                              />
                            ))
                        }
          </FormSelect>
        </FormGroup>
      </Form>
    </>
  );
};

export default SelectSource;
