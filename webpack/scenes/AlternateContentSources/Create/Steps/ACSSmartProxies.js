import React, { useContext, useState } from 'react';
import { useSelector } from 'react-redux';
import { translate as __ } from 'foremanReact/common/I18n';
import {
  DualListSelector,
  FormGroup,
  Switch,
  Flex,
  FlexItem,
} from '@patternfly/react-core';
import ACSCreateContext from '../ACSCreateContext';
import WizardHeader from '../../../ContentViews/components/WizardHeader';
import { selectSmartProxy } from '../../../SmartProxy/SmartProxyContentSelectors';
import { HelpToolTip } from '../../../ContentViews/Create/ContentViewFormComponents';

const ACSSmartProxies = () => {
  const {
    smartProxies, setSmartProxies, useHttpProxies, setUseHttpProxies,
  } = useContext(ACSCreateContext);
  const availableSmartProxies = useSelector(selectSmartProxy);
  const { results } = availableSmartProxies;
  const [availableOptions, setAvailableOptions] = useState(results?.map(proxy =>
    proxy.name)?.filter(sp => !smartProxies.includes(sp)));
  const onListChange = (newAvailableOptions, newChosenOptions) => {
    setAvailableOptions(newAvailableOptions);
    setSmartProxies(newChosenOptions);
  };

  return (
    <>
      <WizardHeader
        title={__('Select smart proxy')}
        description={__('Select smart proxies to be used with this source.')}
      />
      <DualListSelector
        isSearchable
        availableOptions={availableOptions}
        chosenOptions={smartProxies}
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
          ouiaId="use-http-proxies-switch"
          aria-label="use-http-proxies-switch"
          isChecked={useHttpProxies}
          onChange={checked => setUseHttpProxies(checked)}
        />
      </FormGroup>
    </>
  );
};

export default ACSSmartProxies;
