import React, { useState, useEffect, useRef } from 'react';
import PropTypes from 'prop-types';
import { useDispatch, useSelector } from 'react-redux';
import { FormattedMessage } from 'react-intl';
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
  Text,
} from '@patternfly/react-core';

import { translate as __ } from 'foremanReact/common/I18n';
import { noop } from 'foremanReact/common/helpers';

import { UPSTREAM_SERVER, DEFAULT_CONTENT_VIEW_LABEL, DEFAULT_LIFECYCLE_ENVIRONMENT_LABEL } from './CdnConfigurationConstants';
import EditableTextInput from '../../../../components/EditableTextInput';

import {
  selectUpdatingCdnConfiguration,
} from '../../../Organizations/OrganizationSelectors';

import { updateCdnConfiguration } from '../../../Organizations/OrganizationActions';
import './CdnConfigurationForm.scss';

const UpstreamServerTypeForm = ({
  showUpdate, contentCredentials, cdnConfiguration, onUpdate,
}) => {
  const dispatch = useDispatch();
  const urlValue = cdnConfiguration.type === UPSTREAM_SERVER ? cdnConfiguration.url : '';
  const [url, setUrl] = useState(urlValue);
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

  const [updateEnabled, setUpdateEnabled] = useState(false);

  const firstUpdate = useRef(true);
  useEffect(() => {
    if (firstUpdate.current) {
      firstUpdate.current = false;
      return;
    }
    setUpdateEnabled(true);
  }, [url, username, password, organizationLabel,
    contentViewLabel, lifecycleEnvironmentLabel,
    sslCaCredentialId, cdnConfiguration]);

  const editPassword = (value) => {
    if (value === null) {
      setPassword('');
    } else {
      setPassword(value);
    }
  };
  const hasPassword = (cdnConfiguration.password_exists && !password)
      || password?.length > 0;

  const requiredFields = [username, organizationLabel, sslCaCredentialId];

  if (!hasPassword) {
    requiredFields.push(password);
  }

  const validated = !requiredFields.some(field => !field);
  const onError = () => setUpdateEnabled(true);

  const performUpdate = () => {
    setUpdateEnabled(false);
    dispatch(updateCdnConfiguration({
      url,
      username,
      password,
      upstream_organization_label: organizationLabel,
      ssl_ca_credential_id: sslCaCredentialId,
      upstream_content_view_label: contentViewLabel,
      upstream_lifecycle_environment_label: lifecycleEnvironmentLabel,
      type: UPSTREAM_SERVER,
    }, onUpdate, onError));
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

        <div id="update-hint-upstream-server" className="margin-top-16">
          <Text>
            <FormattedMessage
              id="cdn-configuration-type"
              defaultMessage={__('Red Hat content will be consumed from an {type}.')}
              values={{
                type: <strong>{__('upstream Foreman server')}</strong>,
              }}
            />
            <br />
            {showUpdate &&
            <FormattedMessage
              id="cdn-configuration-type-upstream-server"
              defaultMessage={__('Provide the required information and click {update} below to save changes.')}
              values={{
                update: <strong>{__('Update')}</strong>,
              }}
            />
            }
          </Text>
        </div>
        <FormGroup
          label={__('URL')}
          isRequired
        >
          <TextInput
            aria-label="cdn-url"
            type="text"
            value={url || ''}
            onChange={value => setUrl(value)}
            isDisabled={updatingCdnConfiguration}
          />
        </FormGroup>
        <FormGroup
          label={__('Username')}
          isRequired
        >
          <TextInput
            aria-label="cdn-username"
            type="text"
            value={username || ''}
            onChange={value => setUsername(value)}
            isDisabled={updatingCdnConfiguration}
          />
        </FormGroup>
        <FormGroup
          label={__('Password')}
          isRequired
        >
          <EditableTextInput
            attribute="cdn-password"
            value={password}
            isPassword
            hasPassword={hasPassword}
            onEdit={editPassword}
            isDisabled={updatingCdnConfiguration}
          />
        </FormGroup>
        <FormGroup
          label={__('Organization label')}
          isRequired
        >
          <TextInput
            aria-label="cdn-organization-label"
            type="text"
            value={organizationLabel || ''}
            isDisabled={updatingCdnConfiguration}
            onChange={setOrganizationLabel}
          />
        </FormGroup>
        <FormGroup
          label={__('Lifecycle Environment Label')}
        >
          <TextInput
            aria-label="cdn-lifecycle-environment-label"
            type="text"
            value={lifecycleEnvironmentLabel || DEFAULT_LIFECYCLE_ENVIRONMENT_LABEL}
            isDisabled={updatingCdnConfiguration}
            onChange={setLifecycleEnvironmentLabel}
          />
        </FormGroup>
        <FormGroup
          label={__('Content view label')}
        >
          <TextInput
            aria-label="cdn-content-view-label"
            type="text"
            value={contentViewLabel || DEFAULT_CONTENT_VIEW_LABEL}
            isDisabled={updatingCdnConfiguration}
            onChange={setContentViewLabel}
          />
        </FormGroup>
        <FormGroup
          label={__('SSL CA Content Credential')}
          isRequired
        >
          <FormSelect
            aria-label="cdn-ssl-ca-content-credential"
            value={sslCaCredentialId || ''}
            isDisabled={updatingCdnConfiguration}
            onChange={value => setSslCaCredentialId(value)}
          >
            <FormSelectOption label={__('Select one')} isDisabled isPlaceholder />
            {contentCredentials.map(cred =>
              <FormSelectOption data-testid="ssl-ca-content-credential-option" key={cred.id} value={cred.id} label={cred.name} />)}
          </FormSelect>
        </FormGroup>

        <ActionGroup>
          <Button
            aria-label="update-upstream-configuration"
            variant="secondary"
            onClick={performUpdate}
            isDisabled={updatingCdnConfiguration || !validated || !updateEnabled}
            isLoading={updatingCdnConfiguration}
          >
            {__('Update')}
          </Button>
        </ActionGroup>
      </Form>
    </div>
  );
};

UpstreamServerTypeForm.propTypes = {
  showUpdate: PropTypes.bool.isRequired,
  contentCredentials: PropTypes.arrayOf(PropTypes.shape({
    id: PropTypes.number,
    name: PropTypes.string,
  })),
  cdnConfiguration: PropTypes.shape({
    type: PropTypes.string.isRequired,
    url: PropTypes.string,
    username: PropTypes.string,
    upstream_organization_label: PropTypes.string,
    upstream_content_view_label: PropTypes.string,
    upstream_lifecycle_environment_label: PropTypes.string,
    ssl_ca_credential_id: PropTypes.number,
    password_exists: PropTypes.bool,
  }),
  onUpdate: PropTypes.func,
};

UpstreamServerTypeForm.defaultProps = {
  contentCredentials: [],
  cdnConfiguration: {},
  onUpdate: noop,
};

export default UpstreamServerTypeForm;
