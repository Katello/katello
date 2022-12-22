import React from 'react';
import PropTypes from 'prop-types';
import { useDispatch, useSelector } from 'react-redux';
import { FormattedMessage } from 'react-intl';
import {
  ActionGroup,
  Button,
  Form,
  FormGroup,
  TextInput,
  Text,
} from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import { noop } from 'foremanReact/common/helpers';

import { CDN_URL, CDN } from './CdnConfigurationConstants';
import { updateCdnConfiguration } from '../../../Organizations/OrganizationActions';
import {
  selectOrgLoading,
  selectUpdatingCdnConfiguration,
} from '../../../Organizations/OrganizationSelectors';
import './CdnConfigurationForm.scss';

const CdnTypeForm = ({ typeChangeInProgress, onUpdate }) => {
  const dispatch = useDispatch();
  const updatingCdnConfiguration = useSelector(state => selectUpdatingCdnConfiguration(state));
  const orgIsLoading = useSelector(state => selectOrgLoading(state));
  const performUpdate = () => {
    dispatch(updateCdnConfiguration({
      type: CDN,
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
          {typeChangeInProgress &&
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
        <TextInput
          ouiaId="cdn-configuration-url-input"
          aria-label="redhat-cdn-url"
          type="text"
          value={CDN_URL}
          isDisabled
        />
      </FormGroup>

      <ActionGroup>
        <Button
          ouiaId="cdn-configuration-update-button"
          aria-label="update-cdn-configuration"
          variant="secondary"
          onClick={performUpdate}
          isDisabled={updatingCdnConfiguration || orgIsLoading || !typeChangeInProgress}
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
};

CdnTypeForm.defaultProps = {
  onUpdate: noop,
};

export default CdnTypeForm;
