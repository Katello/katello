import React, { useState, useEffect, useCallback, useMemo } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import {
  Form,
  FormGroup,
  Spinner,
  EmptyState,
  Title,
  Button,
  Select,
  SelectOption,
  SelectVariant,
  Alert,
} from '@patternfly/react-core';
import { FormattedMessage } from 'react-intl';
import $ from 'jquery';
import { translate as __ } from 'foremanReact/common/I18n';
import { get } from 'foremanReact/redux/API';
import { foremanUrl } from 'foremanReact/common/helpers';
import { STATUS } from 'foremanReact/constants';
import { selectAPIStatus } from 'foremanReact/redux/API/APISelectors';

const ActivationKeysSearch = () => {
  const ACTIVATION_KEYS = 'ACTIVATION_KEYS';
  const KT_AK_LABEL = 'kt_activation_keys';
  const selectedEnvId = useMemo(() => {
    const selectElement = document.querySelector('#hostgroup_lifecycle_environment_id');
    const selectedOption = selectElement.options[selectElement.selectedIndex];
    let dataId = selectedOption?.getAttribute?.('data-id');
    if (!dataId) {
      dataId = selectElement.value;
    }
    return dataId;
  }, []);
  const selectedContentViewId = useMemo(() => {
    const selectElement = document.querySelector('#hostgroup_content_view_id');
    const selectedOption = selectElement.options[selectElement.selectedIndex];
    let dataId = selectedOption?.getAttribute?.('data-id');
    if (!dataId) {
      dataId = selectElement.value;
    }
    return dataId;
  }, []);
  const isLoading =
    useSelector(state => selectAPIStatus(state, ACTIVATION_KEYS)) === STATUS.PENDING;
  const [activationKeys, setActivationKeys] = useState([]);
  const [selectedKeys, setSelectedKeys] = useState([]);
  const [isOpen, setIsOpen] = useState(false);
  const dispatch = useDispatch();

  const ktLoadActivationKeys = useCallback(() => {
    if (selectedEnvId && selectedContentViewId) {
      dispatch(get({
        key: ACTIVATION_KEYS,
        url: foremanUrl(`/katello/api/v2/environments/${selectedEnvId}/activation_keys`),
        params: { content_view_id: selectedContentViewId },
        handleSuccess: ({ data }) => {
          setActivationKeys(data.results);
        },
        errorToast: () =>
          __('There was a problem retrieving Activation Key data from the server.'),
      }));
    }
  }, [dispatch, selectedEnvId, selectedContentViewId, setActivationKeys]);
  const paramContainer = useMemo(() => {
    let ret;
    const inputs = document.querySelectorAll("div#parameters .fields input[type='text']");
    inputs.forEach((input) => {
      if (input.value === KT_AK_LABEL) {
        ret = input.closest('.fields');
      }
    });
    return ret;
  }, []);
  useEffect(() => {
    $('#hostgroup_lifecycle_environment_id').on('change', ktLoadActivationKeys); // cant use eventlistener on select2
    $('#hostgroup_content_view_id').on('change', ktLoadActivationKeys); // cant use eventlistener on select2
    if (selectedEnvId && selectedContentViewId) {
      ktLoadActivationKeys();
    }

    const ktHideParams = () => {
      if (paramContainer) {
        paramContainer.style.display = 'none';
      }
    };

    const ktAkGetKeysFromParam = () => {
      let keys = [];
      if (paramContainer) {
        const textarea = paramContainer.querySelector('textarea');
        if (textarea) {
          keys = textarea.value.split(',').map(key => key.trim());
        }
      }
      return keys;
    };
    ktHideParams();
    setSelectedKeys(ktAkGetKeysFromParam());
  }, [ktLoadActivationKeys, paramContainer, selectedContentViewId, selectedEnvId]);

  useEffect(() => {
    function ktSetParam() {
      let paramContainerCopy = paramContainer;
      if (selectedKeys.length > 0) {
        const value = selectedKeys.map(key => key.trim()).join(',');
        if (!paramContainerCopy) {
          // we create the param for kt_activation_keys
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
        paramContainerCopy.querySelector("input[type='hidden']").value = 0;
      } else if (paramContainerCopy) {
        // we remove the param by setting destroy to 1
        paramContainerCopy.querySelector("input[type='hidden']").value = 1;
      }
    }
    ktSetParam();
  }, [paramContainer, selectedKeys]);

  if (!(selectedEnvId && selectedContentViewId)) {
    return (
      <EmptyState>
        <Title headingLevel="h4" size="lg" ouiaId="ak-empty-state-title">
          {__('Please select a lifecycle environment and content view to view activation keys.')}
        </Title>
      </EmptyState>
    );
  }

  const onSelect = (event, selection) => {
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
            onToggle={setIsOpen}
            onSelect={onSelect}
            selections={selectedKeys}
            isOpen={isOpen}
            isCreatable
            shouldResetOnSelect
            isDisabled={isLoading || isEmptyResults}
            placeholder={
              isEmptyResults
                ? __('The selected lifecycle environment contains no activation keys')
                : null
            }
          >
            {activationKeys.map(({ id, name }) => (
              <SelectOption key={id} value={name} />
            ))}
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
