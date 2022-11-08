import React, { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import PropTypes from 'prop-types';
import useDeepCompareEffect from 'use-deep-compare-effect';
import { translate as __ } from 'foremanReact/common/I18n';
import { STATUS } from 'foremanReact/constants';
import {
  ActionGroup,
  Button,
  DualListSelector,
  Form,
  FormGroup,
  Modal,
  ModalVariant,
  Switch,
  Flex,
  FlexItem,
} from '@patternfly/react-core';
import { editACS, getACSDetails } from '../../ACSActions';
import { selectSmartProxy, selectSmartProxyStatus } from '../../../SmartProxy/SmartProxyContentSelectors';
import { getSmartProxies } from '../../../SmartProxy/SmartProxyContentActions';
import Loading from '../../../../components/Loading';
import { HelpToolTip } from '../../../ContentViews/Create/ContentViewFormComponents';

const ACSEditSmartProxies = ({ onClose, acsId, acsDetails }) => {
  const { smart_proxies: smartProxies, use_http_proxies: useHttpProxies } = acsDetails;
  const dispatch = useDispatch();
  const [acsUseHttpProxies, setAcsUseHttpProxies] = useState(useHttpProxies);
  const [saving, setSaving] = useState(false);
  const [
    acsSmartProxies, setAcsSmartProxies,
  ] = useState(smartProxies.map(proxy => proxy.name));
  const availableSmartProxies = useSelector(selectSmartProxy);
  const status = useSelector(selectSmartProxyStatus);
  const { results } = availableSmartProxies;
  const [availableOptions, setAvailableOptions] =
        useState(results?.map(proxy => proxy.name).filter(p => !acsSmartProxies.includes(p)));
  const onListChange = (newAvailableOptions, newChosenOptions) => {
    setAvailableOptions(newAvailableOptions);
    setAcsSmartProxies(newChosenOptions);
  };

  useDeepCompareEffect(() => {
    if (results && status === STATUS.RESOLVED) {
      setAvailableOptions(results?.map(proxy =>
        proxy.name).filter(p => !acsSmartProxies.includes(p)));
    }
  }, [results, status, setAvailableOptions, acsSmartProxies]);

  useEffect(
    () => {
      dispatch(getSmartProxies());
    },
    [dispatch],
  );

  const onSubmit = () => {
    setSaving(true);
    dispatch(editACS(
      acsId,
      { acsId, smart_proxy_names: acsSmartProxies, use_http_proxies: acsUseHttpProxies },
      () => {
        dispatch(getACSDetails(acsId));
        onClose();
      },
      () => {
        setSaving(false);
      },
    ));
  };

  if (status === STATUS.PENDING) {
    return <Loading />;
  }

  return (
    <Modal
      title={__('Edit smart proxies')}
      variant={ModalVariant.medium}
      isOpen
      onClose={onClose}
      appendTo={document.body}
    >
      <Form onSubmit={(e) => {
        e.preventDefault();
        onSubmit();
      }}
      >
        <DualListSelector
          isSearchable
          availableOptions={availableOptions}
          chosenOptions={acsSmartProxies}
          addAll={onListChange}
          removeAll={onListChange}
          addSelected={onListChange}
          removeSelected={onListChange}
          id="selector"
        />
        <FormGroup
          label={
            <Flex spaceItems={{ default: 'spaceItemsNone' }}>
              <FlexItem>{__('Use HTTP proxies')}</FlexItem>
              <FlexItem>
                <HelpToolTip tooltip={__('Alternate content sources use the HTTP proxy of their assigned smart proxy for communication.')} />
              </FlexItem>
            </Flex>
        }
          fieldId="use_http_proxies"
        >
          <Switch
            id="use-http-proxies-switch"
            aria-label="use-http-proxies-switch"
            isChecked={acsUseHttpProxies}
            onChange={checked => setAcsUseHttpProxies(checked)}
          />
        </FormGroup>
        <ActionGroup>
          <Button
            ouiaId="edit-acs-details-submit"
            aria-label="edit_acs_details"
            variant="primary"
            isDisabled={saving}
            isLoading={saving}
            type="submit"
          >
            {__('Edit')}
          </Button>
          <Button ouiaId="edit-acs-smart-proxies-cancel" variant="link" onClick={onClose}>
            {__('Cancel')}
          </Button>
        </ActionGroup>
      </Form>
    </Modal>
  );
};

ACSEditSmartProxies.propTypes = {
  acsId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
  onClose: PropTypes.func.isRequired,
  acsDetails: PropTypes.shape({
    smart_proxies: PropTypes.arrayOf(PropTypes.shape({})),
    use_http_proxies: PropTypes.bool,
  }),
};

ACSEditSmartProxies.defaultProps = {
  acsDetails: { smart_proxies: [], id: undefined, use_http_proxies: false },
};

export default ACSEditSmartProxies;
