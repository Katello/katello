import React, { useContext } from 'react';
import { capitalize, upperCase } from 'lodash';
import { translate as __ } from 'foremanReact/common/I18n';
import { TextContent, TextList, TextListItem, TextListItemVariants, TextListVariants } from '@patternfly/react-core';
import ACSCreateContext from '../ACSCreateContext';
import WizardHeader from '../../../ContentViews/components/WizardHeader';
import InactiveText from '../../../ContentViews/components/InactiveText';

const ACSReview = () => {
  const {
    name, description, acsType, contentType,
    smartProxies, useHttpProxies, url, subpaths, verifySSL,
    authentication, sslCertName, sslKeyName, username,
    password, caCertName, productNames,
  } = useContext(ACSCreateContext);

  return (
    <>
      <WizardHeader
        title={__('Review details')}
        description={
          <>
            {__('Review the information below and click ')}<strong>{__('Add')}</strong>{__(' to add your source. ' +
                'To edit details in previous steps, click ')}<strong>{__('Back')}</strong>{__(' or any step on the left.')
            }
          </>
        }
      />
      <TextContent>
        <TextList component={TextListVariants.dl}>
          <TextListItem component={TextListItemVariants.dt}>{__('Name')}</TextListItem>
          <TextListItem component={TextListItemVariants.dd}>
            {name}
          </TextListItem>
          <TextListItem component={TextListItemVariants.dt}>{__('Source type')}</TextListItem>
          <TextListItem component={TextListItemVariants.dd}>
            {acsType === 'rhui' ? upperCase(acsType) : capitalize(acsType)}
          </TextListItem>
          <TextListItem component={TextListItemVariants.dt}>{__('Description')}</TextListItem>
          <TextListItem component={TextListItemVariants.dd}>
            {description}
          </TextListItem>
          <TextListItem component={TextListItemVariants.dt}>{__('Content type')}</TextListItem>
          <TextListItem component={TextListItemVariants.dd}>
            {capitalize(contentType)}
          </TextListItem>
          <TextListItem component={TextListItemVariants.dt}>{__('Smart proxies')}</TextListItem>
          <TextListItem component={TextListItemVariants.dd}>
            {smartProxies.join(', ')}
          </TextListItem>
          <TextListItem component={TextListItemVariants.dt}>{__('Use HTTP Proxies')}</TextListItem>
          <TextListItem component={TextListItemVariants.dd}>
            {useHttpProxies ? __('Yes') : __('No')}
          </TextListItem>
          {(acsType === 'custom' || acsType === 'rhui') &&
            <>
              <TextListItem component={TextListItemVariants.dt}>
                {__('Base URL')}
              </TextListItem>
              <TextListItem component={TextListItemVariants.dd}>
                {url}
              </TextListItem>
              <TextListItem component={TextListItemVariants.dt}>{__('Subpaths')}</TextListItem>
              <TextListItem component={TextListItemVariants.dd}>
                {subpaths}
              </TextListItem>
              <TextListItem component={TextListItemVariants.dt}>{__('Verify SSL')}</TextListItem>
              <TextListItem component={TextListItemVariants.dd}>
                {verifySSL ? __('Yes') : __('No')}
              </TextListItem>
              <TextListItem component={TextListItemVariants.dt}>{__('SSL CA certificate')}</TextListItem>
              <TextListItem component={TextListItemVariants.dd}>
                {caCertName}
              </TextListItem>
              {authentication === 'manual' && (
                <>
                  <TextListItem
                    component={TextListItemVariants.dt}
                  >{__('Authentication type')}
                  </TextListItem>
                  <TextListItem component={TextListItemVariants.dd}>
                    {__('Manual')}
                  </TextListItem>
                  <TextListItem component={TextListItemVariants.dt}>{__('Username')}</TextListItem>
                  <TextListItem component={TextListItemVariants.dd}>
                    {username}
                  </TextListItem>
                  <TextListItem component={TextListItemVariants.dt}>{__('Password')}</TextListItem>
                  <TextListItem component={TextListItemVariants.dd}>
                    {password.length > 0 ? '••••••••' : <InactiveText text={__('N/A')} />}
                  </TextListItem>
                </>
              )}
              {authentication === 'content_credentials' && (
                <>
                  <TextListItem
                    component={TextListItemVariants.dt}
                  >{__('Authentication type')}
                  </TextListItem>
                  <TextListItem component={TextListItemVariants.dd}>
                    {__('Content credential')}
                  </TextListItem>
                  <TextListItem component={TextListItemVariants.dt}>{__('SSL client certificate')}</TextListItem>
                  <TextListItem component={TextListItemVariants.dd}>
                    {sslCertName}
                  </TextListItem>
                  <TextListItem component={TextListItemVariants.dt}>{__('SSL client key')}</TextListItem>
                  <TextListItem component={TextListItemVariants.dd}>
                    {sslKeyName}
                  </TextListItem>
                </>
              )}
            </>
            }
          {acsType === 'simplified' &&
            <>
              <TextListItem component={TextListItemVariants.dt}>{__('Products')}</TextListItem>
              <TextListItem component={TextListItemVariants.dd}>
                {productNames.join(', ')}
              </TextListItem>
            </>
            }
        </TextList>
      </TextContent>
    </>
  );
};

export default ACSReview;
