import React, { useContext } from 'react';
import { useSelector } from 'react-redux';
import { translate as __ } from 'foremanReact/common/I18n';
import {
  Form,
  FormGroup,
  FormSelect,
  FormSelectOption,
  TextInput,
  Radio,
  Switch,
} from '@patternfly/react-core';
import { STATUS } from 'foremanReact/constants';
import ACSCreateContext from '../ACSCreateContext';
import WizardHeader from '../../../ContentViews/components/WizardHeader';
import { selectContentCredentials, selectContentCredentialsStatus } from '../../../ContentCredentials/ContentCredentialSelectors';
import Loading from '../../../../components/Loading';

const ACSCredentials = () => {
  const {
    authentication, setAuthentication, username, setUsername, password, setPassword,
    sslCert, setSslCert, sslKey, setSslKey, caCert, setCACert,
    setSslCertName, setSslKeyName, setCACertName, verifySSL, setVerifySSL,
  } = useContext(ACSCreateContext);

  const contentCredentials = useSelector(selectContentCredentials);
  const contentCredentialsStatus = useSelector(selectContentCredentialsStatus);

  if (contentCredentialsStatus === STATUS.PENDING) {
    return <Loading loadingText={__('Fetching content credentials')} />;
  }

  const getCertName = id => contentCredentials?.filter(cc => Number(cc.id) === Number(id))[0]?.name;

  return (
    <>
      <WizardHeader
        title={__('Credentials')}
        description={__('Enter basic authentication information or choose content credentials if required for this source.')}
      />
      <Form>
        <Radio
          label={__('Manual authentication')}
          id="manual_auth"
          name="manual_auth"
          aria-label="manual_auth"
          isChecked={authentication === 'manual'}
          onChange={() => {
            setAuthentication('manual');
            setSslCert('');
            setSslKey('');
            setSslCertName('');
            setSslKeyName('');
          }}
        />
        {(authentication === 'manual') &&
          <>
            <FormGroup
              label={__('Username')}
              type="string"
              fieldId="acs_username"
              isRequired
            >
              <TextInput
                isRequired
                type="text"
                id="acs_username_field"
                name="acs_username_field"
                aria-label="acs_username_field"
                value={username}
                onChange={(value) => { setUsername(value); }}
              />

            </FormGroup>
            <FormGroup
              label={__('Password')}
              type="password"
              fieldId="acs_password"
            >
              <TextInput
                isRequired
                type="password"
                id="acs_password_field"
                name="acs_password_field"
                aria-label="acs_password_field"
                value={password}
                onChange={(value) => { setPassword(value); }}
              />
            </FormGroup>
          </>
        }
        <Radio
          label={__('Content credentials')}
          id="content_credentials"
          aria-label="content_credentials"
          name="content_cred_auth"
          isChecked={authentication === 'content_credentials'}
          onChange={() => {
            setAuthentication('content_credentials');
            setUsername('');
            setPassword('');
          }}
        />
        {(authentication === 'content_credentials') &&
        <>
          <FormGroup
            label={__('SSL client certificate')}
            type="string"
            fieldId="client_cert"
          >
            <FormSelect isRequired value={sslCert} onChange={(value) => { setSslCert(value); setSslCertName(getCertName(value)); }} aria-label="sslCert_select">
              {
                [
                  <FormSelectOption
                    key="placeholder"
                    value=""
                    label={__('Select a client certificate')}
                    isDisabled
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
            <FormSelect isRequired value={sslKey} onChange={(value) => { setSslKey(value); setSslKeyName(getCertName(value)); }} aria-label="sslKey_select">
              {
                [
                  <FormSelectOption
                    key="placeholder"
                    value=""
                    label={__('Select a client key')}
                    isDisabled
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
        </>
        }
        <Radio
          label={__('None')}
          id="none"
          name="none"
          aria-label="none"
          isChecked={authentication === ''}
          onChange={() => {
            setAuthentication('');
            setSslCert('');
            setSslKey('');
            setSslCertName('');
            setSslKeyName('');
            setUsername('');
            setPassword('');
          }}
        />
        <FormGroup label={__('Verify SSL')} fieldId="verify_ssl">
          <Switch
            id="verify-ssl-switch"
            aria-label="verify-ssl-switch"
            isChecked={verifySSL}
            onChange={checked => setVerifySSL(checked)}
          />
        </FormGroup>
        <FormGroup
          label={__('SSL CA certificate')}
          type="string"
          fieldId="ca_cert"
        >
          <FormSelect
            isDisabled={!verifySSL}
            isRequired
            value={caCert}
            onChange={(value) => { setCACert(value); setCACertName(getCertName(value)); }}
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
      </Form>
    </>
  );
};

export default ACSCredentials;
