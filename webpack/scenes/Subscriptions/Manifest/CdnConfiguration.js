import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { useDispatch, useSelector } from 'react-redux';

import {
  ActionGroup,
  Button,
  Form,
  FormGroup,
  FormSelect,
  FormSelectOption,
  Spinner,
  TextInput,
} from '@patternfly/react-core';

import { translate as __ } from 'foremanReact/common/I18n';

import EditableTextInput from '../../../components/EditableTextInput';

import {
  selectUpdatingCdnConfiguration,
} from '../../Organizations/OrganizationSelectors';

import { updateCdnConfiguration } from '../../Organizations/OrganizationActions';
import './CdnConfiguration.scss';

const CdnConfiguration = (props) => {
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

  const editPassword = (value) => {
    setPassword(value);
  };

  const performUpdate = () => {
    dispatch(updateCdnConfiguration({
      url,
      username,
      password,
      upstream_organization_label: organizationLabel,
      ssl_ca_credential_id: sslCaCredentialId,
    }));
  };

  const updateButtonContent = (
    updatingCdnConfiguration ? (
      <React.Fragment>
        <Spinner size="md" />
        {__('Updating')}
      </React.Fragment>) :
      __('Update')
  );

  return (
    <div id="cdn-configuration">
      <Form isHorizontal>
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
        >
          <EditableTextInput
            attribute="cdn-password"
            isPassword
            hasPassword={cdnConfiguration.password_exists}
            onEdit={editPassword}
          />
        </FormGroup>
        <FormGroup
          label={__('Organization Label')}
        >
          <TextInput
            aria-label="cdn-organization-label"
            type="text"
            value={organizationLabel || ''}
            onChange={value => setOrganizationLabel(value)}
          />
        </FormGroup>
        <FormGroup
          label={__('SSL CA Content Credential')}
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
            isDisabled={updatingCdnConfiguration}
          >
            {updateButtonContent}
          </Button>
        </ActionGroup>
      </Form>
    </div>
  );
};

CdnConfiguration.propTypes = {
  contentCredentials: PropTypes.arrayOf(PropTypes.shape({
    id: PropTypes.number,
    name: PropTypes.string,
  })),
  cdnConfiguration: PropTypes.shape({
    url: PropTypes.string,
    username: PropTypes.string,
    upstream_organization_label: PropTypes.string,
    ssl_ca_credential_id: PropTypes.number,
    password_exists: PropTypes.bool,
  }).isRequired,
};

CdnConfiguration.defaultProps = {
  contentCredentials: [],
};

export default CdnConfiguration;
