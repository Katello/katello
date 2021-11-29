import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import {
  Alert, Switch, TextContent, Text,
  TextVariants, Form, FormGroup, TextArea, AlertActionCloseButton,
} from '@patternfly/react-core';
import { EnterpriseIcon, RegistryIcon } from '@patternfly/react-icons';
import EnvironmentPaths from '../components/EnvironmentPaths/EnvironmentPaths';
import ComponentEnvironments from '../Details/ComponentContentViews/ComponentEnvironments';
import './cvPublishForm.scss';
import WizardHeader from '../components/WizardHeader';

const CVPublishForm = ({
  description,
  setDescription,
  details: {
    name, composite, next_version: nextVersion,
  },
  userCheckedItems,
  setUserCheckedItems,
  promote,
  setPromote,
  forcePromote,
}) => {
  const [alertDismissed, setAlertDismissed] = useState(false);

  const checkPromote = (checked) => {
    if (!checked) {
      setUserCheckedItems([]);
    }
    setPromote(checked);
  };
  return (
    <>
      <WizardHeader
        title={__('Publish')}
        description={
          <>{__('A new version of ')}<b>{composite ? <RegistryIcon /> : <EnterpriseIcon />} {name}</b>
            {__(' will be created and automatically promoted to the ' +
              'Library environment. You can promote to other environments as well. ')
            }
          </>}
      />
      <TextContent>
        <Text component={TextVariants.h3}>{__('Publish new version - ')}{nextVersion || '1.0'}</Text>
      </TextContent>
      <Form>
        <FormGroup label="Description" fieldId="description">
          <TextArea
            isRequired
            type="text"
            id="description"
            aria-label="input_description"
            name="description"
            value={description}
            onChange={setDescription}
          />
        </FormGroup>
        <FormGroup label="Promote" fieldId="promote">
          <Switch
            id="promote-switch"
            aria-label="promote-switch"
            isChecked={promote}
            onChange={checkPromote}
          />
        </FormGroup>
      </Form>
      {!alertDismissed && promote && forcePromote.length > 0 && (
        <Alert
          variant="info"
          isInline
          title={__('Force promotion')}
          actionClose={<AlertActionCloseButton onClose={() => setAlertDismissed(true)} />}
        >
          <TextContent>
            {forcePromote.length > 1 ? __('Selected environments ') : __('Selected environment ')}
            <ComponentEnvironments environments={forcePromote} />
            {forcePromote.length > 1 ?
              __(' are out of the environment path order. The recommended practice is to promote the next environment in the path.') :
              __(' is out of the environment path order. The recommended practice is to promote the next environment in the path.')
            }
          </TextContent>
        </Alert>)}
      {promote &&
        <EnvironmentPaths
          userCheckedItems={userCheckedItems}
          setUserCheckedItems={setUserCheckedItems}
        />
      }
    </>
  );
};

CVPublishForm.propTypes = {
  description: PropTypes.string.isRequired,
  setDescription: PropTypes.func.isRequired,
  userCheckedItems: PropTypes.arrayOf(PropTypes.shape({})).isRequired,
  setUserCheckedItems: PropTypes.func.isRequired,
  promote: PropTypes.bool.isRequired,
  setPromote: PropTypes.func.isRequired,
  forcePromote: PropTypes.arrayOf(PropTypes.shape({})).isRequired,
  details: PropTypes.shape({
    id: PropTypes.oneOfType([
      PropTypes.number,
      PropTypes.string,
    ]),
    name: PropTypes.string.isRequired,
    composite: PropTypes.bool.isRequired,
    next_version: PropTypes.oneOfType([
      PropTypes.number,
      PropTypes.string,
    ]).isRequired,
  }).isRequired,
};

export default CVPublishForm;
