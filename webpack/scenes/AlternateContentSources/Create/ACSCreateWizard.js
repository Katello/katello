import React, { useEffect, useState } from 'react';
import { useDispatch } from 'react-redux';
import PropTypes from 'prop-types';
import { Wizard } from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import ACSCreateContext from './ACSCreateContext';
import SelectSource from './Steps/SelectSource';
import NameACS from './Steps/NameACS';
import AcsUrlPaths from './Steps/AcsUrlPaths';
import ACSCredentials from './Steps/ACSCredentials';
import ACSSmartProxies from './Steps/ACSSmartProxies';
import ACSReview from './Steps/ACSReview';
import ACSCreateFinish from './Steps/ACSCreateFinish';
import { getContentCredentials } from '../../ContentCredentials/ContentCredentialActions';
import { getSmartProxies } from '../../SmartProxy/SmartProxyContentActions';
import { CONTENT_CREDENTIAL_CERT_TYPE } from '../../ContentCredentials/ContentCredentialConstants';

const ACSCreateWizard = ({ show, setIsOpen }) => {
  const [acsType, setAcsType] = useState(null);
  const [contentType, setContentType] = useState('yum');
  const [name, setName] = useState('');
  const [description, setDescription] = useState('');
  const [smartProxies, setSmartProxies] = useState([]);
  const [url, setUrl] = useState('');
  const [subpaths, setSubpaths] = useState('');
  const [verifySSL, setVerifySSL] = useState(false);
  const [authentication, setAuthentication] = useState('');
  const [sslCert, setSslCert] = useState('');
  const [sslKey, setSslKey] = useState('');
  const [sslCertName, setSslCertName] = useState('');
  const [sslKeyName, setSslKeyName] = useState('');
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [caCert, setCACert] = useState('');
  const [caCertName, setCACertName] = useState('');
  const [currentStep, setCurrentStep] = useState(1);
  const dispatch = useDispatch();

  useEffect(
    () => {
      dispatch(getContentCredentials({ content_type: CONTENT_CREDENTIAL_CERT_TYPE }));
      dispatch(getSmartProxies());
    },
    [dispatch],
  );

  const steps = [
    {
      id: 1,
      name: __('Select source type'),
      component: <SelectSource />,
      enableNext: acsType && contentType,
    },
    {
      id: 2,
      name: __('Name source'),
      component: <NameACS />,
      enableNext: name !== '',
    },
    {
      id: 3,
      name: __('Select smart proxy'),
      component: <ACSSmartProxies />,
      enableNext: smartProxies.length,
    },
    {
      id: 4,
      name: __('URL and paths'),
      component: <AcsUrlPaths />,
      enableNext: url !== '' && subpaths !== '',
    },
    {
      id: 5,
      name: __('Credentials'),
      component: <ACSCredentials />,
    },
    {
      id: 6,
      name: __('Review details'),
      component: <ACSReview />,
      nextButtonText: __('Add'),
    },
    {
      id: 7,
      name: __('Create ACS'),
      component: <ACSCreateFinish />,
      isFinishedStep: true,
    },

  ];

  return (
    <ACSCreateContext.Provider value={{
      show,
      setIsOpen,
      currentStep,
      setCurrentStep,
      acsType,
      setAcsType,
      contentType,
      setContentType,
      name,
      setName,
      description,
      setDescription,
      smartProxies,
      setSmartProxies,
      url,
      setUrl,
      subpaths,
      setSubpaths,
      verifySSL,
      setVerifySSL,
      authentication,
      setAuthentication,
      sslCert,
      setSslCert,
      sslKey,
      setSslKey,
      sslCertName,
      setSslCertName,
      sslKeyName,
      setSslKeyName,
      username,
      setUsername,
      password,
      setPassword,
      caCert,
      setCACert,
      caCertName,
      setCACertName,
    }}
    >
      <Wizard
        title={__('Add an alternate content source')}
        steps={steps}
        startAtStep={currentStep}
        onGoToStep={({ id }) => setCurrentStep(id)}
        onNext={({ id }) => setCurrentStep(id)}
        onBack={({ id }) => setCurrentStep(id)}
        onClose={() => {
          setIsOpen(false);
        }}
        isOpen={show}
      />
    </ACSCreateContext.Provider>
  );
};

ACSCreateWizard.propTypes = {
  show: PropTypes.bool,
  setIsOpen: PropTypes.func,
};

ACSCreateWizard.defaultProps = {
  show: false,
  setIsOpen: null,
};

export default ACSCreateWizard;
