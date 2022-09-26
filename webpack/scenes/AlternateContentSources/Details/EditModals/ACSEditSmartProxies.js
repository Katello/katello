import React, { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import PropTypes from 'prop-types';
import useDeepCompareEffect from 'use-deep-compare-effect';
import { translate as __ } from 'foremanReact/common/I18n';
import { STATUS } from 'foremanReact/constants';
import { ActionGroup, Button, DualListSelector, Form, Modal, ModalVariant } from '@patternfly/react-core';
import { editACS, getACSDetails } from '../../ACSActions';
import { selectSmartProxy, selectSmartProxyStatus } from '../../../SmartProxy/SmartProxyContentSelectors';
import { getSmartProxies } from '../../../SmartProxy/SmartProxyContentActions';
import Loading from '../../../../components/Loading';

const ACSEditSmartProxies = ({ onClose, acsId, acsDetails }) => {
  const { smart_proxies: smartProxies } = acsDetails;
  const dispatch = useDispatch();
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
      { acsId, smart_proxy_names: acsSmartProxies },
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
      variant={ModalVariant.small}
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
        <ActionGroup>
          <Button
            ouiaId="edit-acs-details-submit"
            aria-label="edit_acs_details"
            variant="primary"
            isDisabled={saving}
            isLoading={saving}
            type="submit"
          >
            {__('Edit ACS smart proxies')}
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
  }),
};

ACSEditSmartProxies.defaultProps = {
  acsDetails: { smart_proxies: [], id: undefined },
};

export default ACSEditSmartProxies;
