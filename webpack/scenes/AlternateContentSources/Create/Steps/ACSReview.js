import React, { useContext } from 'react';
import { translate as __ } from 'foremanReact/common/I18n';
import {
  TextContent,
  TextList,
  TextListVariants,
  TextListItem,
  TextListItemVariants,
} from '@patternfly/react-core';
import ACSCreateContext from '../ACSCreateContext';
import WizardHeader from '../../../ContentViews/components/WizardHeader';

const ACSReview = () => {
  const {
    name, description, acsType, contentType,
    smartProxies, url, subpaths, verifySSL,
    authentication, sslCertName, sslKeyName, username,
    password, caCertName,
  } = useContext(ACSCreateContext);

  return (
    <>
      <WizardHeader
        title={__('Review Details')}
        description={__('Review the information below and click Add to add your source. ' +
          'To edit details in previous steps, click Back or any step on the left.')}
      />
      <TextContent>
        <TextList component={TextListVariants.dl}>
          <TextListItem component={TextListItemVariants.dt}>{__('Name')}</TextListItem>
          <TextListItem component={TextListItemVariants.dd}>
            {name}
          </TextListItem>
          <TextListItem component={TextListItemVariants.dt}>{__('Source type')}</TextListItem>
          <TextListItem component={TextListItemVariants.dd}>
            {acsType}
          </TextListItem>
          <TextListItem component={TextListItemVariants.dt}>{__('Description')}</TextListItem>
          <TextListItem component={TextListItemVariants.dd}>
            {description}
          </TextListItem>
          <TextListItem component={TextListItemVariants.dt}>{__('Content type')}</TextListItem>
          <TextListItem component={TextListItemVariants.dd}>
            {contentType}
          </TextListItem>
          <TextListItem component={TextListItemVariants.dt}>{__('Smart proxies')}</TextListItem>
          <TextListItem component={TextListItemVariants.dd}>
            {smartProxies}
          </TextListItem>
          <TextListItem component={TextListItemVariants.dt}>{__('Base URL')}</TextListItem>
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
          <TextListItem component={TextListItemVariants.dt}>{__('CA Cert')}</TextListItem>
          <TextListItem component={TextListItemVariants.dd}>
            {caCertName}
          </TextListItem>
          {authentication === 'manual' && (
            <>
              <TextListItem component={TextListItemVariants.dt}>{__('Authentication type')}</TextListItem>
              <TextListItem component={TextListItemVariants.dd}>
                {__('Manual')}
              </TextListItem>
              <TextListItem component={TextListItemVariants.dt}>{__('Username')}</TextListItem>
              <TextListItem component={TextListItemVariants.dd}>
                {username}
              </TextListItem>
              <TextListItem component={TextListItemVariants.dt}>{__('Password')}</TextListItem>
              <TextListItem component={TextListItemVariants.dd}>
                {password}
              </TextListItem>
            </>
          )}
          {authentication === 'content_credentials' && (
            <>
              <TextListItem component={TextListItemVariants.dt}>{__('Authentication type')}</TextListItem>
              <TextListItem component={TextListItemVariants.dd}>
                {__('Content credential')}
              </TextListItem>
              <TextListItem component={TextListItemVariants.dt}>{__('SSL Cert')}</TextListItem>
              <TextListItem component={TextListItemVariants.dd}>
                {sslCertName}
              </TextListItem>
              <TextListItem component={TextListItemVariants.dt}>{__('Client key')}</TextListItem>
              <TextListItem component={TextListItemVariants.dd}>
                {sslKeyName}
              </TextListItem>
            </>
          )}
        </TextList>
      </TextContent>
    </>
  );
};

export default ACSReview;
