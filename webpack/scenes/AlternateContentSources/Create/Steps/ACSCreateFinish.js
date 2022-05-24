import React, { useContext, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import useDeepCompareEffect from 'use-deep-compare-effect';
import { translate as __ } from 'foremanReact/common/I18n';
import { STATUS } from 'foremanReact/constants';
import ACSCreateContext from '../ACSCreateContext';
import { selectCreateACS, selectCreateACSError, selectCreateACSStatus } from '../../ACSSelectors';
import getAlternateContentSources, { createACS } from '../../ACSActions';
import Loading from '../../../../components/Loading';

const ACSCreateFinish = () => {
  const {
    currentStep,
    setIsOpen,
    acsType,
    contentType,
    name,
    description,
    smartProxies,
    url,
    subpaths,
    verifySSL,
    authentication,
    sslCert,
    sslKey,
    username,
    password,
    caCert,
  } = useContext(ACSCreateContext);
  const dispatch = useDispatch();
  const response = useSelector(state => selectCreateACS(state));
  const status = useSelector(state => selectCreateACSStatus(state));
  const error = useSelector(state => selectCreateACSError(state));
  const [createACSDispatched, setCreateACSDispatched] = useState(false);
  const [saving, setSaving] = useState(true);

  useDeepCompareEffect(() => {
    if (currentStep === 7 && !createACSDispatched) {
      setCreateACSDispatched(true);
      let params = {
        name,
        description,
        base_url: url,
        smart_proxy_names: smartProxies,
        content_type: contentType,
        alternate_content_source_type: acsType,
        verify_ssl: verifySSL,
        ssl_ca_cert_id: caCert,
      };
      if (subpaths !== '') {
        params = { subpaths: subpaths.split(','), ...params };
      }
      if (authentication === 'content_credentials') {
        params = { ssl_client_cert_id: sslCert, ssl_client_key_id: sslKey, ...params };
      }
      if (authentication === 'manual') {
        params = { upstream_username: username, upstream_password: password, ...params };
      }
      dispatch(createACS(params));
    }
  }, [dispatch, createACSDispatched, setCreateACSDispatched,
    acsType, authentication, name, description, url, subpaths,
    smartProxies, contentType, verifySSL, caCert, sslCert, sslKey,
    username, password, currentStep]);

  useDeepCompareEffect(() => {
    const { id } = response;
    if (id && status === STATUS.RESOLVED && saving) {
      setSaving(false);
      dispatch(getAlternateContentSources());
      setIsOpen(false);
    } else if (status === STATUS.ERROR) {
      setSaving(false);
      setIsOpen(false);
    }
  }, [response, status, error, saving, dispatch, setIsOpen]);

  return <Loading loadingText={__('Saving alternate content source...')} />;
};

export default ACSCreateFinish;
