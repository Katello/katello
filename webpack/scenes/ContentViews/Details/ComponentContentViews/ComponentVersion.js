import React from 'react';
import PropTypes from 'prop-types';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import { translate as __ } from 'foremanReact/common/I18n';
import {
  Text,
  TextContent,
  TextVariants,
} from '@patternfly/react-core';

const ComponentVersion = ({ componentCV }) => {
  const {
    id: componentId, latest, content_view_version: cvVersion, content_view: cv,
  } = componentCV;
  const {
    id: cvId,
    latest_version: latestVersion,
  } = cv;
  const { version, id: versionId } = cvVersion || {};
  const noVersionText = __('Not yet published');
  const latestDescription = __('Latest (automatically updates)');
  const manualVersionText = (latestVersion === version) ? __('Latest version') : __(`New version is available: Version ${latestVersion}`);
  if (componentId) {
    return (
      <>
        <a href={`${urlBuilder('content_views', '')}${cvId}#/versions/${versionId}`}>
          {version ? `Version ${version}` : noVersionText}
        </a>
        <TextContent>
          <Text ouiaId="version" component={TextVariants.small}>
            {latest ? latestDescription : manualVersionText}
          </Text>
        </TextContent>
      </>
    );
  }
  return (
    <a href={`${urlBuilder('content_views', '')}${cvId}${latestVersion ? `#/versions/${versionId}` : ''}`}>
      {latestVersion ? `Version ${latestVersion}` : noVersionText}
    </a>
  );
};

ComponentVersion.propTypes = {
  componentCV: PropTypes.shape({
    id: PropTypes.number,
    latest: PropTypes.bool.isRequired,
    content_view_version: PropTypes.shape({
      version: PropTypes.string,
    }),
    content_view: PropTypes.shape({
      id: PropTypes.number.isRequired,
      latest_version: PropTypes.string,
    }),
  }).isRequired,
};

export default ComponentVersion;

