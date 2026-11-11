import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { useDispatch, useSelector } from 'react-redux';
import { FormattedMessage } from 'react-intl';
import {
  ActionGroup,
  Button,
  Form,
  FormGroup,
  FormSelect,
  FormSelectOption,
  Text,
} from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import { noop } from 'foremanReact/common/helpers';

import { DEFAULT_CDN_URL, CDN_URLS, CDN } from './CdnConfigurationConstants';
import { updateCdnConfiguration } from '../../../Organizations/OrganizationActions';
import {
  selectOrgLoading,
  selectUpdatingCdnConfiguration,
} from '../../../Organizations/OrganizationSelectors';
import './CdnConfigurationForm.scss';

const CdnTypeForm = ({ typeChangeInProgress, onUpdate, cdnConfiguration }) => {
  const defaultUrl = cdnConfiguration.default_url || DEFAULT_CDN_URL;
  const availableUrls = cdnConfiguration.cdn_urls || CDN_URLS;
  const savedUrl = cdnConfiguration.type === CDN ? cdnConfiguration.url : null;
  const cdnUrls = [...new Set([defaultUrl, ...availableUrls, savedUrl].filter(Boolean))];
  const [selectedUrl, setSelectedUrl] = useState(savedUrl || defaultUrl);
  const [lastSavedUrl, setLastSavedUrl] = useState(savedUrl);
  if (savedUrl !== lastSavedUrl) {
    setLastSavedUrl(savedUrl);
    setSelectedUrl(savedUrl || defaultUrl);
  }
  const dispatch = useDispatch();
  const updatingCdnConfiguration = useSelector(state => selectUpdatingCdnConfiguration(state));
  const orgIsLoading = useSelector(state => selectOrgLoading(state));
  const hasChanges = typeChangeInProgress || selectedUrl !== cdnConfiguration.url;
  const performUpdate = () => {
    dispatch(updateCdnConfiguration({
      type: CDN,
      url: selectedUrl,
    }, onUpdate));
  };

  return (
    <Form isHorizontal>
      <div id="update-hint-cdn" className="margin-top-16">
        <Text ouiaId="update-hint-cdn-text">
          <FormattedMessage
            id="cdn-configuration-type"
            defaultMessage={__('Red Hat content will be consumed from the {type}.')}
            values={{
              type: <strong>{__('Red Hat CDN')}</strong>,
            }}
          />
          <br />
          {hasChanges &&
          <FormattedMessage
            id="cdn-configuration-type-cdn"
            defaultMessage={__('Click {update} below to save changes.')}
            values={{
              update: <strong>{__('Update')}</strong>,
            }}
          />
          }
        </Text>
      </div>
      <FormGroup label={__('URL')} isRequired>
        <FormSelect
          ouiaId="cdn-configuration-url-input"
          aria-label="redhat-cdn-url"
          value={selectedUrl}
          onChange={(_event, value) => setSelectedUrl(value)}
          isDisabled={updatingCdnConfiguration || orgIsLoading}
        >
          {cdnUrls.map(url =>
            <FormSelectOption key={url} value={url} label={url} />)}
        </FormSelect>
      </FormGroup>

      <ActionGroup>
        <Button
          ouiaId="cdn-configuration-update-button"
          aria-label="update-cdn-configuration"
          variant="secondary"
          onClick={performUpdate}
          isDisabled={updatingCdnConfiguration || orgIsLoading || !hasChanges}
          isLoading={updatingCdnConfiguration}
        >
          {__('Update')}
        </Button>
      </ActionGroup>
    </Form>

  );
};

CdnTypeForm.propTypes = {
  typeChangeInProgress: PropTypes.bool.isRequired,
  onUpdate: PropTypes.func,
  cdnConfiguration: PropTypes.shape({
    type: PropTypes.string,
    url: PropTypes.string,
    default_url: PropTypes.string,
    cdn_urls: PropTypes.arrayOf(PropTypes.string),
  }),
};

CdnTypeForm.defaultProps = {
  onUpdate: noop,
  cdnConfiguration: {},
};

export default CdnTypeForm;
