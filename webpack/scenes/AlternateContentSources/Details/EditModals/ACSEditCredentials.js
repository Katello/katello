import React, { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { STATUS } from 'foremanReact/constants';
import {
  ActionGroup,
  Button,
  Form,
  FormGroup,
  FormSelect,
  FormSelectOption,
  Modal,
  ModalVariant,
  Radio,
  TextInput,
  Switch,
} from '@patternfly/react-core';
import { editACS, getACSDetails } from '../../ACSActions';
import {
  selectContentCredentials,
  selectContentCredentialsStatus,
} from '../../../ContentCredentials/ContentCredentialSelectors';
import Loading from '../../../../components/Loading';
import { getContentCredentials } from '../../../ContentCredentials/ContentCredentialActions';
import { CONTENT_CREDENTIAL_CERT_TYPE } from '../../../ContentCredentials/ContentCredentialConstants';

const ACSEditCredentials = ({ onClose, acsId, acsDetails }) => {
  const {
    ssl_ca_cert: sslCACert,
    ssl_client_cert: sslClientCert,
    ssl_client_key: sslClientKey,
    upstream_username: username,
    upstream_password_exists: passwordExists,
    verify_ssl: verifySsl,
  } = acsDetails;
  const dispatch = useDispatch();
  const contentCredentials = useSelector(selectContentCredentials);
  const contentCredentialsStatus = useSelector(selectContentCredentialsStatus);
  const [acsUsername, setAcsUsername] = useState(username);
  const [acsPassword, setAcsPassword] = useState(passwordExists ? '*****' : '');
  const [acsCAcert, setAcsCAcert] = useState(sslCACert?.id);
  const [acsSslClientCert, setAcsSslClientCert] = useState(sslClientCert?.id);
  const [acsSslClientKey, setAcsSslClientKey] = useState(sslClientKey?.id);
  const [acsVerifySSL, setAcsVerifySSL] = useState(verifySsl);
  const getAuthenticationState = () => {
    if (username) {
      return 'manual';
    } else if (acsSslClientCert || acsSslClientKey) {
      return 'credentials';
    }
    return 'none';
  };
  const [authentication, setAuthentication] = useState(getAuthenticationState());
  const [saving, setSaving] = useState(false);

  useEffect(
    () => {
      dispatch(getContentCredentials({ content_type: CONTENT_CREDENTIAL_CERT_TYPE }));
    },
    [dispatch],
  );

  const onSubmit = () => {
    setSaving(true);
    let params = {
      ssl_ca_cert_id: acsCAcert,
      verify_ssl: acsVerifySSL,
    };

    if (authentication === 'credentials') {
      params = {
        ssl_client_cert_id: acsSslClientCert,
        ssl_client_key_id: acsSslClientKey,
        upstream_username: null,
        upstream_password: null,
        ...params,
      };
    }
    if (authentication === 'manual') {
      params = {
        upstream_username: acsUsername,
        upstream_password: acsPassword === '*****' ? '*****' : acsPassword,
        ssl_client_cert_id: null,
        ssl_client_key_id: null,
        ...params,
      };
      if (params.upstream_password === '*****') {
        delete params.upstream_password;
      }
    }
    if (authentication === 'none') {
      params = {
        upstream_username: null,
        upstream_password: null,
        ssl_client_cert_id: null,
        ssl_client_key_id: null,
        ...params,
      };
    }
    dispatch(editACS(
      acsId,
      params,
      () => {
        dispatch(getACSDetails(acsId));
        onClose();
      },
      () => {
        setSaving(false);
      },
    ));
  };

  if (contentCredentialsStatus === STATUS.PENDING) {
    return <Loading loadingText={__('Fetching content credentials')} />;
  }

  return (
    <Modal
      title={__('Edit credentials')}
      variant={ModalVariant.large}
      isOpen
      onClose={onClose}
      appendTo={document.body}
      ouiaId="acs-edit-credentials-modal"
    >
      <Form onSubmit={(e) => {
        e.preventDefault();
        onSubmit();
      }}
      >
        <FormGroup label={__('Verify SSL')} fieldId="verify_ssl">
          <Switch
            ouiaId="verify-ssl-switch"
            id="verify-ssl-switch"
            aria-label="verify-ssl-switch"
            isChecked={acsVerifySSL}
            onChange={(_event, checked) => setAcsVerifySSL(checked)}
          />
        </FormGroup>
        <FormGroup
          label={__('SSL CA certificate')}
          type="string"
          fieldId="ca_cert"
        >
          <FormSelect
            ouiaId="sslCAcert-select"
            isRequired
            isDisabled={!acsVerifySSL}
            value={acsCAcert}
            onChange={(_event, value) => setAcsCAcert(value)}
            aria-label="sslCAcert_select"
          >
            {
                [
                  <FormSelectOption
                    key="placeholder"
                    value=""
                    label={__('Select a CA certificate')}
                  />,
                ].concat(contentCredentials?.map(cc => (
                  <FormSelectOption
                    key={cc.id}
                    value={cc.id}
                    label={cc.name}
                  />
                )))
            }
          </FormSelect>
        </FormGroup>
        <Radio
          ouiaId="manual-auth-radio"
          label={__('Manual authentication')}
          id="manual_auth"
          name="manual_auth"
          aria-label="manual_auth"
          isChecked={authentication === 'manual'}
          onChange={() => {
            setAuthentication('manual');
            setAcsSslClientCert('');
            setAcsSslClientKey('');
          }}
        />
        {authentication === 'manual' &&
        <>
          <FormGroup
            label={__('Username')}
            type="string"
            fieldId="acs_username"
            isRequired
          >
            <TextInput
              ouiaId="acs-username-field"
              isRequired
              type="text"
              id="acs_username_field"
              name="acs_username_field"
              aria-label="acs_username_field"
              value={acsUsername}
              onChange={(_event, value) => {
                setAcsUsername(value);
              }}
            />

          </FormGroup>
          <FormGroup
            label={__('Password')}
            type="password"
            fieldId="acs_password"
          >
            <TextInput
              ouiaId="acs-password-field"
              isRequired
              type="password"
              id="acs_password_field"
              name="acs_password_field"
              aria-label="acs_password_field"
              value={acsPassword}
              onChange={(_event, value) => {
                setAcsPassword(value);
              }}
            />
          </FormGroup>
        </>
                }
        <Radio
          ouiaId="content-credentials-radio"
          label={__('Content credentials')}
          id="content_credentials"
          aria-label="content_credentials"
          name="content_cred_auth"
          isChecked={authentication === 'credentials'}
          onChange={() => {
            setAuthentication('credentials');
            setAcsUsername('');
            setAcsPassword('');
          }}
        />
        {authentication === 'credentials' &&
        <>
          <FormGroup
            label={__('SSL client certificate')}
            type="string"
            fieldId="ssl_client_cert"
          >
            <FormSelect
              ouiaId="ssl-client-cert-select"
              isRequired
              value={acsSslClientCert}
              onChange={(_event, value) => setAcsSslClientCert(value)}
              aria-label="ssl_client_cert_select"
            >
              {
                [
                  <FormSelectOption
                    key="placeholder"
                    value=""
                    label={__('Select a client certificate')}
                  />,
                ].concat(contentCredentials?.map(cc => (
                  <FormSelectOption
                    key={cc.id}
                    value={cc.id}
                    label={cc.name}
                  />
                )))
              }
            </FormSelect>
          </FormGroup>
          <FormGroup
            label={__('SSL client key')}
            type="string"
            fieldId="client_key"
          >
            <FormSelect
              ouiaId="ssl_client_key_select"
              isRequired
              value={acsSslClientKey}
              onChange={(_event, value) => setAcsSslClientKey(value)}
              aria-label="ssl_client_key_select"
            >
              {
                [
                  <FormSelectOption
                    key="placeholder"
                    value=""
                    label={__('Select a client key')}
                  />,
                ].concat(contentCredentials?.map(cc => (
                  <FormSelectOption
                    key={cc.id}
                    value={cc.id}
                    label={cc.name}
                  />
                )))
              }
            </FormSelect>
          </FormGroup>
        </>}
        <Radio
          ouiaId="none-radio"
          label={__('None')}
          id="none"
          name="none"
          aria-label="none"
          isChecked={authentication === 'none'}
          onChange={() => {
            setAuthentication('none');
            setAcsSslClientCert('');
            setAcsSslClientKey('');
            setAcsUsername('');
            setAcsPassword('');
          }}
        />
        <ActionGroup>
          <Button
            ouiaId="edit-acs-credentials-submit"
            aria-label="edit_acs_credentials"
            variant="primary"
            isDisabled={saving}
            isLoading={saving}
            type="submit"
          >
            {__('Edit')}
          </Button>
          <Button
            ouiaId="edit-acs-credentials-cancel"
            aria-label="edit-acs-credentials-cancel"
            variant="link"
            onClick={onClose}
          >
            {__('Cancel')}
          </Button>
        </ActionGroup>
      </Form>
    </Modal>
  );
};

ACSEditCredentials.propTypes = {
  acsId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
  onClose: PropTypes.func.isRequired,
  acsDetails: PropTypes.shape({
    name: PropTypes.string,
    description: PropTypes.string,
    id: PropTypes.number,
    ssl_ca_cert: PropTypes.shape({ id: PropTypes.number }),
    ssl_client_cert: PropTypes.shape({ id: PropTypes.number }),
    ssl_client_key: PropTypes.shape({ id: PropTypes.number }),
    upstream_username: PropTypes.string,
    upstream_password_exists: PropTypes.bool,
    verify_ssl: PropTypes.bool,
  }),
};

ACSEditCredentials.defaultProps = {
  acsDetails: {
    name: '',
    description: '',
    id: undefined,
    ssl_ca_cert: { id: undefined },
    ssl_client_cert: { id: undefined },
    ssl_client_key: { id: undefined },
    upstream_username: undefined,
    upstream_password_exists: false,
    verify_ssl: false,
  },
};

export default ACSEditCredentials;
