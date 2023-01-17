import React, { useContext } from 'react';
import { translate as __ } from 'foremanReact/common/I18n';
import {
  Form,
  FormGroup,
  TextInput,
  TextArea,
} from '@patternfly/react-core';
import ACSCreateContext from '../ACSCreateContext';
import WizardHeader from '../../../ContentViews/components/WizardHeader';

const NameACS = () => {
  const {
    name, setName, description, setDescription,
  } = useContext(ACSCreateContext);

  return (
    <>
      <WizardHeader
        title={__('Name source')}
        description={__('Enter a name for your source.')}
      />
      <Form>
        <FormGroup
          label={__('Name')}
          type="string"
          fieldId="acs_name"
          isRequired
        >
          <TextInput
            isRequired
            type="text"
            id="acs_name_field"
            ouiaId="acs_name_field"
            name="acs_name_field"
            aria-label="acs_name_field"
            value={name}
            onChange={(value) => { setName(value); }}
          />
        </FormGroup>
        <FormGroup
          label={__('Description')}
          type="string"
          fieldId="acs_description"
        >
          <TextArea
            value={description}
            onChange={(value) => { setDescription(value); }}
            name="acs_description_field"
            id="acs_description_field"
          />
        </FormGroup>
      </Form>
    </>
  );
};

export default NameACS;
