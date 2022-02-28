import React, { useState, useEffect, useRef } from 'react';
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
  selectUpdatingCdnConfiguration,
} from '../../../Organizations/OrganizationSelectors';
import './CdnConfigurationForm.scss';

const CdnTypeForm = ({ showUpdate, onUpdate, url }) => {
  const dispatch = useDispatch();
  const [cdnUrl, setCdnUrl] = useState(url);
  const [updateEnabled, setUpdateEnabled] = useState(showUpdate);
  const updatingCdnConfiguration = useSelector(state => selectUpdatingCdnConfiguration(state));
  const firstUpdate = useRef(true);

  useEffect(() => {
    if (firstUpdate.current) {
      firstUpdate.current = false;
      return;
    }
    setUpdateEnabled(true);
  }, [cdnUrl]);

  const performUpdate = () => {
    setUpdateEnabled(false);
    dispatch(updateCdnConfiguration({
      type: CDN,
      url: cdnUrl,
    }, onUpdate));
  };

  return (
    <Form isHorizontal>
      <div id="update-hint-cdn" className="margin-top-16">
        <Text>
          <FormattedMessage
            id="cdn-configuration-type"
            defaultMessage={__('Red Hat content will be consumed from the {type}.')}
            values={{
              type: <strong>{__('Red Hat CDN')}</strong>,
            }}
          />
          <br />
          {showUpdate &&
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
          aria-label="cdn-url"
          type="text"
          value={cdnUrl}
          onChange={setCdnUrl}
          isDisabled={updatingCdnConfiguration}
        />
      </FormGroup>

      <ActionGroup>
        <Button
          aria-label="update-cdn-configuration"
          variant="secondary"
          onClick={performUpdate}
          isDisabled={updatingCdnConfiguration || !updateEnabled || !cdnUrl}
          isLoading={updatingCdnConfiguration}
        >
          {__('Update')}
        </Button>
      </ActionGroup>
    </Form>

  );
};

CdnTypeForm.propTypes = {
  showUpdate: PropTypes.bool.isRequired,
  onUpdate: PropTypes.func,
  url: PropTypes.string,
};

CdnTypeForm.defaultProps = {
  url: CDN_URL,
  onUpdate: noop,
};

export default CdnTypeForm;
