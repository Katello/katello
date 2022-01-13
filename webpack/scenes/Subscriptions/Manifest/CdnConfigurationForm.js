import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { useDispatch, useSelector } from 'react-redux';

import {
  ActionGroup,
  Alert,
  Button,
  Form,
  FormAlert,
  FormGroup,
  FormSelect,
  FormSelectOption,
  TextInput,
  Tooltip,
} from '@patternfly/react-core';

import { translate as __ } from 'foremanReact/common/I18n';

import EditableTextInput from '../../../components/EditableTextInput';

import {
  selectUpdatingCdnConfiguration,
} from '../../Organizations/OrganizationSelectors';

import { updateCdnConfiguration } from '../../Organizations/OrganizationActions';
import './CdnConfigurationForm.scss';

const CdnConfigurationForm = (props) => {
  const {
    contentCredentials,
    cdnConfiguration,
  } = props;

  const dispatch = useDispatch();

  const [url, setUrl] = useState(cdnConfiguration.url);
  const [username, setUsername] = useState(cdnConfiguration.username);
  const [password, setPassword] = useState(null);
  const [organizationLabel, setOrganizationLabel] =
    useState(cdnConfiguration.upstream_organization_label);
  const [sslCaCredentialId, setSslCaCredentialId] = useState(cdnConfiguration.ssl_ca_credential_id);
  const updatingCdnConfiguration = useSelector(state => selectUpdatingCdnConfiguration(state));

  const [contentViewLabel, setContentViewLabel] =
    useState(cdnConfiguration.upstream_content_view_label);

  const [lifecycleEnvironmentLabel, setLifecycleEnvironmentLabel] =
    useState(cdnConfiguration.upstream_lifecycle_environment_label);

  const editPassword = (value) => {
    if (value === null) {
      setPassword('');
    } else {
      setPassword(value);
    }
  };

  const hasPassword = (cdnConfiguration.password_exists && password === null)
    || password?.length > 0;

  const requiresValidation = username || password || organizationLabel || sslCaCredentialId;

  const requiredFields = [username, organizationLabel, sslCaCredentialId];

  if (!hasPassword) {
    requiredFields.push(password);
  }

  const validated = requiresValidation ?
    !requiredFields.some(field => !field) :
    true;

  const performUpdate = () => {
    dispatch(updateCdnConfiguration({
      url,
      username,
      password,
      upstream_organization_label: organizationLabel,
      ssl_ca_credential_id: sslCaCredentialId,
    }));
  };

  return (
    <div id="cdn-configuration">
      <Form isHorizontal>
        { !validated && (
          <FormAlert>
            <Alert
              variant="danger"
              title={__('Username, Password, Organization Label, and SSL CA Content Credential must be provided together.')}
              aria-live="polite"
              isInline
            />
          </FormAlert>
        )}
        <FormGroup
          label={__('URL')}
          isRequired
        >
          <TextInput
            isRequired
            aria-label="cdn-url"
            type="text"
            value={url || ''}
            onChange={value => setUrl(value)}
          />
        </FormGroup>
        <FormGroup
          label={__('Username')}
          isRequired={requiresValidation}
        >
          <TextInput
            aria-label="cdn-username"
            type="text"
            value={username || ''}
            onChange={value => setUsername(value)}
          />
        </FormGroup>
        <FormGroup
          label={__('Password')}
          isRequired={requiresValidation}
        >
          <EditableTextInput
            attribute="cdn-password"
            value={password}
            isPassword
            hasPassword={hasPassword}
            onEdit={editPassword}
          />
        </FormGroup>
        <FormGroup
          label={__('Organization Label')}
          isRequired={requiresValidation}
        >
          <TextInput
            aria-label="cdn-organization-label"
            type="text"
            value={organizationLabel || ''}
            onChange={setOrganizationLabel}
          />
        </FormGroup>
        <FormGroup
          label={__('Lifecycle Environment Label')}
        >
          <TextInput
            aria-label="cdn-lifecycle-environment-label"
            type="text"
            value={lifecycleEnvironmentLabel || ''}
            onChange={setLifecycleEnvironmentLabel}
          />
          <Tooltip>
            {__('Leave blank if consuming Red Hat Content from the Library lifecycle environment or CDN ')}
          </Tooltip>
        </FormGroup>
        <FormGroup
          label={__('Content View Label')}
        >
          <TextInput
            aria-label="cdn-content-view-label"
            type="text"
            value={contentViewLabel || ''}
            onChange={setContentViewLabel}
          />
          <Tooltip>
            {__('Leave blank if consuming Red Hat Content from the Default Content View or CDN ')}
          </Tooltip>

        </FormGroup>
        <FormGroup
          label={__('SSL CA Content Credential')}
          isRequired={requiresValidation}
        >
          <FormSelect
            aria-label="cdn-ssl-ca-content-credential"
            value={sslCaCredentialId || ''}
            onChange={value => setSslCaCredentialId(value)}
          >
            <FormSelectOption label={__('Select one')} isDisabled isPlaceholder />
            {contentCredentials.map(cred =>
              <FormSelectOption data-testid="ssl-ca-content-credential-option" key={cred.id} value={cred.id} label={cred.name} />)}
          </FormSelect>
        </FormGroup>
        <ActionGroup>
          <Button
            aria-label="update-cdn-configuration"
            variant="secondary"
            onClick={performUpdate}
            isDisabled={updatingCdnConfiguration || !validated}
            isLoading={updatingCdnConfiguration}
          >
            {__('Update')}
          </Button>
        </ActionGroup>
      </Form>
    </div>
  );
};

CdnConfigurationForm.propTypes = {
  contentCredentials: PropTypes.arrayOf(PropTypes.shape({
    id: PropTypes.number,
    name: PropTypes.string,
  })),
  cdnConfiguration: PropTypes.shape({
    url: PropTypes.string,
    username: PropTypes.string,
    upstream_organization_label: PropTypes.string,
    upstream_content_view_label: PropTypes.string,
    upstream_lifecycle_environment_label: PropTypes.string,
    ssl_ca_credential_id: PropTypes.number,
    password_exists: PropTypes.bool,
  }),
};

CdnConfigurationForm.defaultProps = {
  contentCredentials: [],
  cdnConfiguration: {},
};

export default CdnConfigurationForm;
