import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { Alert, Switch, Flex, FlexItem, TextContent, Text, TextVariants, Form, FormGroup, TextArea } from '@patternfly/react-core';
import { EnterpriseIcon, RegistryIcon } from '@patternfly/react-icons';
import EnvironmentPaths from '../components/EnvironmentPaths/EnvironmentPaths';
import ComponentEnvironments from '../Details/ComponentContentViews/ComponentEnvironments';
import './cvPublishForm.scss';

const CVPublishForm = ({
  description,
  setDescription,
  details,
  userCheckedItems,
  setUserCheckedItems,
  promote,
  setPromote,
  forcePromote,
}) => {
  const {
    name, composite, next_version: nextVersion,
  } = details;

  return (
    <>
      <>
        <TextContent>
          <Text style={{ marginBottom: '1em' }} component={TextVariants.h1}>{__('Publish')}</Text>
        </TextContent>
        <Flex flex={{ default: 'inlineFlex' }}>
          <FlexItem>{__('A new version of ')}<b>{composite ? <RegistryIcon /> : <EnterpriseIcon />} {name}</b>
            {__(' will be created and automatically promoted to the ' +
          'Library environment. You can promote to other environments as well. ')}
          </FlexItem>
        </Flex>
        <TextContent>
          <Text style={{ marginTop: '1em', marginBottom: '1em' }} component={TextVariants.h3}>{__('Publish new version - ')}{nextVersion || '1.0'}</Text>
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
              onChange={value => setDescription(value)}
            />
          </FormGroup>
          <FormGroup label="Promote" fieldId="promote" style={{ marginBottom: '2em', outlineStyle: 'none' }}>
            <Switch
              id="promote-switch"
              aria-label="promote-switch"
              isChecked={promote}
              onChange={checked => setPromote(checked)}
            />
          </FormGroup>
        </Form>
      </>
      <>
        {forcePromote.length > 0 && (
        <Alert variant="info" isInline title="Force Promotion">
          <p>{__('Selected environments are out of the environment order. ' +
            'The recommended practice is to promote to the next environment in the path.')}
          </p>
          <ComponentEnvironments environments={forcePromote} />
        </Alert>
        )
        }
        {promote &&
        <EnvironmentPaths
          userCheckedItems={userCheckedItems}
          setUserCheckedItems={setUserCheckedItems}
        />
        }
      </>
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
