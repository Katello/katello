import React, { useCallback, useContext, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { useHistory } from 'react-router-dom';
import PropTypes from 'prop-types';
import useDeepCompareEffect from 'use-deep-compare-effect';
import {
  WizardContextConsumer,
} from '@patternfly/react-core/deprecated';
import { translate as __ } from 'foremanReact/common/I18n';
import { STATUS } from 'foremanReact/constants';
import ACSCreateContext from '../ACSCreateContext';
import { selectCreateACS, selectCreateACSError, selectCreateACSStatus } from '../../ACSSelectors';
import getAlternateContentSources, { createACS } from '../../ACSActions';
import Loading from '../../../../components/Loading';
import { spaceSepOrUndef } from '../../helpers';

const ACSCreateFinishWrapper = () => (
  <WizardContextConsumer>
    {({ activeStep }) => <ACSCreateFinish activeStep={activeStep} />}
  </WizardContextConsumer>
);

const ACSCreateFinish = ({ activeStep }) => {
  const { push } = useHistory();
  const currentStep = activeStep.id;
  const {
    setIsOpen,
    acsType,
    contentType,
    name,
    description,
    smartProxies,
    url,
    subpaths,
    useHttpProxies,
    verifySSL,
    authentication,
    sslCert,
    sslKey,
    username,
    password,
    caCert,
    productIds,
    debReleases,
    debComponents,
    debArchitectures,
  } = useContext(ACSCreateContext);
  const dispatch = useDispatch();
  const response = useSelector(state => selectCreateACS(state, name));
  const status = useSelector(state => selectCreateACSStatus(state, name));
  const error = useSelector(state => selectCreateACSError(state, name));
  const [createACSDispatched, setCreateACSDispatched] = useState(false);
  const [saving, setSaving] = useState(true);

  const acsTypeParams = useCallback((params, type) => {
    let acsParams = params;
    if (type === 'custom' || type === 'rhui') {
      acsParams = {
        base_url: url, verify_ssl: verifySSL, ssl_ca_cert_id: caCert, ...acsParams,
      };
      if (contentType === 'deb') {
        acsParams = {
          ...acsParams,
          deb_releases: spaceSepOrUndef(debReleases),
          deb_components: spaceSepOrUndef(debComponents),
          deb_architectures: spaceSepOrUndef(debArchitectures),
          subpaths: [],
        };
      } else if (subpaths !== '') {
        acsParams = { subpaths: subpaths.split(','), ...acsParams };
      }
    }
    if (type === 'simplified') {
      acsParams = { product_ids: productIds, ...acsParams };
    }
    return acsParams;
  }, [
    caCert,
    productIds,
    subpaths,
    url,
    verifySSL,
    contentType,
    debReleases,
    debComponents,
    debArchitectures,
  ]);

  useDeepCompareEffect(() => {
    if (currentStep === 8 && !createACSDispatched) {
      setCreateACSDispatched(true);
      let params = {
        name,
        description,
        smart_proxy_names: smartProxies,
        use_http_proxies: useHttpProxies,
        content_type: contentType,
        alternate_content_source_type: acsType,
      };
      params = acsTypeParams(params, acsType);
      if (authentication === 'content_credentials') {
        params = { ssl_client_cert_id: sslCert, ssl_client_key_id: sslKey, ...params };
      }
      if (authentication === 'manual') {
        params = { upstream_username: username, upstream_password: password, ...params };
      }
      dispatch(createACS(params, name, () => { dispatch(getAlternateContentSources()); }));
    }
  }, [dispatch, createACSDispatched, setCreateACSDispatched,
    acsType, authentication, name, description, url, subpaths,
    smartProxies, contentType, useHttpProxies, verifySSL, caCert, sslCert, sslKey,
    username, password, currentStep, acsTypeParams]);

  useDeepCompareEffect(() => {
    const { id } = response;
    if (id && status === STATUS.RESOLVED && saving) {
      setSaving(false);
      window.location.assign(`/alternate_content_sources/${id}/details`);
      setIsOpen(false);
    } else if (status === STATUS.ERROR) {
      setSaving(false);
      setIsOpen(false);
    }
  }, [response, status, error, push, saving, dispatch, setIsOpen]);

  return <Loading loadingText={__('Saving alternate content source...')} />;
};

ACSCreateFinish.propTypes = {
  activeStep: PropTypes.shape({
    id: PropTypes.number.isRequired,
  }).isRequired,
};

export default ACSCreateFinishWrapper;
