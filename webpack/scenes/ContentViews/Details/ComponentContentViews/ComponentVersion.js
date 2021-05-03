import React from 'react';
import { Link } from 'react-router-dom';
import PropTypes from 'prop-types';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import { translate as __, sprintf } from 'foremanReact/common/I18n';
import {
  Text,
  TextContent,
  TextVariants,
} from '@patternfly/react-core';

const ComponentVersion = ({ componentCV }) => {
  const { latest, content_view_version: cvVersion, content_view: cv } = componentCV;
  const {
    id,
    latest_version: latestVersion,
  } = cv;
  const { version } = cvVersion;
  const latestDescription = __('Latest (automatically updates)');
  const manualVersionText = (latestVersion === version) ? __('Latest version') : __(`New version is available: Version ${latestVersion}`);
  return (
    <>
      <Link to={urlBuilder('labs/content_views', '', id)}> {sprintf(__('Version %s', version))}</Link>
      <TextContent>
        <Text component={TextVariants.small}>{latest ? latestDescription : manualVersionText}</Text>
      </TextContent>
    </>
  );
};

ComponentVersion.propTypes = {
  componentCV: PropTypes.shape({
    latest: PropTypes.bool.isRequired,
    content_view_version: PropTypes.shape({
      version: PropTypes.string.isRequired,
    }),
    content_view: PropTypes.shape({
      id: PropTypes.number.isRequired,
      latest_version: PropTypes.string.isRequired,
    }),
  }).isRequired,
};

export default ComponentVersion;

