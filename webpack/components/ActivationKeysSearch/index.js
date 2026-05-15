import React, { useState, useEffect, useCallback } from 'react';
import { useDispatch } from 'react-redux';
import {
  Form,
  FormGroup,
  Spinner,
  EmptyState,
  Button,
  Alert, EmptyStateHeader,
} from '@patternfly/react-core';
import {
  Select,
  SelectOption,
  SelectVariant,
} from '@patternfly/react-core/deprecated';
import { FormattedMessage } from 'react-intl';
import { translate as __ } from 'foremanReact/common/I18n';
import { get } from 'foremanReact/redux/API';
import { foremanUrl } from 'foremanReact/common/helpers';

const getOrganizationIds = () => {
  const orgIdsElem = document.querySelector('#hostgroup_organization_ids');
  if (!orgIdsElem) return [];
  const ids = new Set();
  Array.from(orgIdsElem.selectedOptions || []).forEach((opt) => {
    if (opt.value) ids.add(opt.value);
  });
  const useds = orgIdsElem.getAttribute('data-useds');
  if (useds) {
    try {
      const parsed = JSON.parse(useds);
      if (Array.isArray(parsed)) parsed.forEach(id => ids.add(String(id)));
    } catch (e) {
      useds.toString().split(',').filter(Boolean).forEach(id => ids.add(id));
    }
  }
  return Array.from(ids);
};

const ACTIVATION_KEYS = 'ACTIVATION_KEYS';

const ActivationKeysSearch = () => {
  const KT_AK_LABEL = 'kt_activation_keys';
  const [organizationIds, setOrganizationIds] = useState(getOrganizationIds());
  const [isLoading, setIsLoading] = useState(false);
  const [activationKeys, setActivationKeys] = useState([]);
  const [selectedKeys, setSelectedKeys] = useState([]);
  const [isOpen, setIsOpen] = useState(false);
  const dispatch = useDispatch();

  const ktLoadActivationKeys = useCallback(() => {
    if (organizationIds.length === 0) return;
    setIsLoading(true);
    setActivationKeys([]);
    let completed = 0;
    organizationIds.forEach((orgId) => {
      dispatch(get({
        key: `${ACTIVATION_KEYS}_${orgId}`,
        url: foremanUrl('/katello/api/v2/activation_keys'),
        params: {
          organization_id: orgId,
          full_result: true,
        },
        handleSuccess: ({ data }) => {
          setActivationKeys((prev) => {
            const existingIds = new Set(prev.map(ak => ak.id));
            const newKeys = data.results.filter(ak => !existingIds.has(ak.id));
            return [...prev, ...newKeys];
          });
          completed += 1;
          if (completed >= organizationIds.length) setIsLoading(false);
        },
        handleError: () => {
          completed += 1;
          if (completed >= organizationIds.length) setIsLoading(false);
        },
        errorToast: () =>
          __('There was a problem retrieving Activation Key data from the server.'),
      }));
    });
  }, [dispatch, organizationIds]);

  const getParamContainer = useCallback(() => {
    let ret;
    const inputs = document.querySelectorAll("div#parameters .fields input[type='text']");
    inputs.forEach((input) => {
      if (input.value === KT_AK_LABEL) {
        ret = input.closest('.fields');
      }
    });
    return ret;
  }, [KT_AK_LABEL]);

  // Update organization IDs when they change
  useEffect(() => {
    const orgElem = document.querySelector('#hostgroup_organization_ids');
    if (!orgElem) return undefined;

    const handleChange = () => setOrganizationIds(getOrganizationIds());

    const observer = new MutationObserver(handleChange);
    observer.observe(orgElem, { childList: true, attributes: true, subtree: true });
    orgElem.addEventListener('change', handleChange);

    return () => {
      observer.disconnect();
      orgElem.removeEventListener('change', handleChange);
    };
  }, []);

  // Initialize from hidden parameter on mount
  useEffect(() => {
    const ktHideParams = () => {
      const container = getParamContainer();
      if (container) {
        container.style.display = 'none';
      }
    };

    const ktAkGetKeysFromParam = () => {
      let keys = [];
      const container = getParamContainer();
      if (container) {
        const textarea = container.querySelector('textarea');
        if (textarea) {
          keys = textarea.value.split(',').map(key => key.trim());
        }
      }
      return keys;
    };
    ktHideParams();
    setSelectedKeys(ktAkGetKeysFromParam());
  }, [getParamContainer]);

  // Load activation keys when organizations change
  useEffect(() => {
    if (organizationIds.length > 0) {
      ktLoadActivationKeys();
    }
  }, [ktLoadActivationKeys, organizationIds]);

  useEffect(() => {
    function ktSetParam() {
      let paramContainerCopy = getParamContainer();
      if (selectedKeys.length > 0) {
        const value = selectedKeys.map(key => key.split(' — ')[0].trim()).join(',');
        if (!paramContainerCopy) {
          const addParameterButton = document.querySelector('#parameters .btn-primary');
          addParameterButton.click();
          const directionOfAddedItems = addParameterButton.getAttribute('direction');
          const paramContainers = document.querySelectorAll('#parameters .fields');
          if (directionOfAddedItems === 'append') {
            paramContainerCopy = paramContainers[paramContainers.length - 1];
          } else {
            [paramContainerCopy] = paramContainers;
          }
          paramContainerCopy.querySelector("input[name*='name']").value = KT_AK_LABEL;
        }
        paramContainerCopy.querySelector('textarea').value = value;
        const destroyInput = paramContainerCopy.querySelector("input[name*='[_destroy]']");
        if (destroyInput) destroyInput.value = 0;
      } else if (paramContainerCopy) {
        const destroyInput = paramContainerCopy.querySelector("input[name*='[_destroy]']");
        if (destroyInput) destroyInput.value = 1;
      }
    }
    ktSetParam();
  }, [getParamContainer, selectedKeys]);

  if (organizationIds.length === 0) {
    return (
      <EmptyState>
        <EmptyStateHeader
          titleText={
            <>{__('Please select an organization to view activation keys.')}</>
          }
          headingLevel="h4"
        />
      </EmptyState>
    );
  }

  const multiOrg = organizationIds.length > 1;

  const onSelect = (_event, selection) => {
    setIsOpen(false);
    if (selectedKeys.includes(selection)) {
      setSelectedKeys(prevState => prevState.filter(item => item !== selection));
    } else {
      setSelectedKeys(prevState => [...prevState, selection]);
    }
  };

  const isEmptyResults = activationKeys.length === 0;
  return (
    <div>
      <Form isHorizontal>
        <FormGroup label={__('Activation Keys')}>
          <Select
            ouiaId="ak-select"
            variant={SelectVariant.typeaheadMulti}
            onToggle={(_event, val) => setIsOpen(val)}
            onSelect={onSelect}
            selections={selectedKeys}
            isOpen={isOpen}
            isCreatable
            shouldResetOnSelect
            isDisabled={isLoading || isEmptyResults}
            placeholderText={
              isEmptyResults
                ? __('No activation keys available')
                : null
            }
          >
            {activationKeys.map(({ id, name, organization }) => {
              const label = multiOrg ? `${name} — ${organization?.name}` : name;
              return (
                <SelectOption key={id} value={label} />
              );
            })}
          </Select>
        </FormGroup>
        <Alert title={__('Activation Key information')} variant="info" ouiaId="ak-info">
          <p>{__("The value will be available in templates as @host.params['kt_activation_keys']")}</p>
          <p>
            <FormattedMessage
              id="ak-link-manage"
              defaultMessage={__('Activation keys can be managed {here}.')}
              values={{
                here: (
                  <b>
                    <a href="/activation_keys" target="_blank">
                      {__('here')}
                    </a>
                  </b>
                ),
              }}
            />
          </p>
          <p>
            <FormattedMessage
              id="ak-subscriptions-info"
              defaultMessage={__('Activation keys may be used during {system_registration}.')}
              values={{
                system_registration: <a href="/hosts/register">{__('system registration')}</a>,
              }}
            />
          </p>
          <p>
            <Button
              id="ak_refresh_subscriptions"
              variant="link"
              onClick={ktLoadActivationKeys}
              ouiaId="ak-refresh-button"
              isInline
            >
              {__('Reload data')}
            </Button>
          </p>
        </Alert>
      </Form>
      {isLoading && <Spinner id="ak-subscriptions-spinner" />}
    </div>
  );
};

export default ActivationKeysSearch;
