import React, { useState, useEffect, useRef } from 'react';
import PropTypes from 'prop-types';
import { useDispatch, useSelector } from 'react-redux';
import { FormattedMessage } from 'react-intl';
import {
  ActionGroup,
  Button,
  Form,
  FormGroup,
  FormSelect,
  FormSelectOption,
  TextInput,
  Text,
} from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import { noop } from 'foremanReact/common/helpers';

import { CUSTOM_CDN } from './CdnConfigurationConstants';
import { updateCdnConfiguration } from '../../../Organizations/OrganizationActions';
import {
  selectUpdatingCdnConfiguration,
} from '../../../Organizations/OrganizationSelectors';
import './CdnConfigurationForm.scss';

const CustomCdnTypeForm = ({
  showUpdate, onUpdate, contentCredentials, cdnConfiguration,
}) => {
  const dispatch = useDispatch();
  const urlValue = cdnConfiguration.type === CUSTOM_CDN ? cdnConfiguration.url : '';
  const [url, setUrl] = useState(urlValue);
  const [updateEnabled, setUpdateEnabled] = useState(showUpdate);
  const updatingCdnConfiguration = useSelector(state => selectUpdatingCdnConfiguration(state));
  const firstUpdate = useRef(true);
  const [sslCaCredentialId, setSslCaCredentialId] = useState(cdnConfiguration.ssl_ca_credential_id);

  useEffect(() => {
    if (firstUpdate.current) {
      firstUpdate.current = false;
      return;
    }
    setUpdateEnabled(true);
  }, [sslCaCredentialId, cdnConfiguration]);

  const onError = () => setUpdateEnabled(true);

  const performUpdate = () => {
    setUpdateEnabled(false);
    dispatch(updateCdnConfiguration({
      url,
      ssl_ca_credential_id: sslCaCredentialId,
      type: CUSTOM_CDN,
    }, onUpdate, onError));
  };


  return (
    <Form isHorizontal>
      <div id="update-hint-cdn" className="margin-top-16">
        <Text>
          <FormattedMessage
            id="cdn-configuration-type"
            defaultMessage={__('Red Hat content will be consumed from the {type}.')}
            values={{
              type: <strong>{__('Custom CDN Url')}</strong>,
            }}
          />
          <br />
          {showUpdate &&
          <FormattedMessage
            id="cdn-configuration-type-cdn"
            defaultMessage={__('Click {update} below to save changes.')}
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
          ouiaId="custom-cdn-url-input"
          aria-label="cdn-url"
          type="text"
          value={url || ''}
          onChange={value => setUrl(value)}
          isDisabled={updatingCdnConfiguration}
        />
      </FormGroup>

      <FormGroup
        label={__('SSL CA Content Credential')}
      >
        <FormSelect
          ouiaId="custom-cdn-ca-content-credential-input"
          aria-label="cdn-ssl-ca-content-credential"
          value={sslCaCredentialId || ''}
          isDisabled={updatingCdnConfiguration}
          onChange={value => setSslCaCredentialId(value)}
        >
          <FormSelectOption label={__('N/A')} />
          {contentCredentials.map(cred =>
            <FormSelectOption data-testid="ssl-ca-content-credential-option" key={cred.id} value={cred.id} label={cred.name} />)}
        </FormSelect>
      </FormGroup>

      <ActionGroup>
        <Button
          ouiaId="custom-cdn-type-configuration-update-button"
          aria-label="update-custom-cdn-configuration"
          variant="secondary"
          onClick={performUpdate}
          isDisabled={updatingCdnConfiguration || !updateEnabled || !url}
          isLoading={updatingCdnConfiguration}
        >
          {__('Update')}
        </Button>
      </ActionGroup>
    </Form>

  );
};

CustomCdnTypeForm.propTypes = {
  showUpdate: PropTypes.bool.isRequired,
  onUpdate: PropTypes.func,
  contentCredentials: PropTypes.arrayOf(PropTypes.shape({
    id: PropTypes.number,
    name: PropTypes.string,
  })),
  cdnConfiguration: PropTypes.shape({
    type: PropTypes.string.isRequired,
    url: PropTypes.string,
    ssl_ca_credential_id: PropTypes.number,
  }),

};

CustomCdnTypeForm.defaultProps = {
  onUpdate: noop,
  contentCredentials: [],
  cdnConfiguration: {},
};

export default CustomCdnTypeForm;
