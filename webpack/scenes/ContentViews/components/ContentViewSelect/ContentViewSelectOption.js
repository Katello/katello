import React from 'react';
import { Flex, SelectOption } from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import PropTypes from 'prop-types';
import { FormattedMessage } from 'react-intl';
import {
  global_palette_black_600 as pfDescriptionColor,
} from '@patternfly/react-tokens';
import { uniq } from '../../../../utils/helpers';
import ContentViewIcon from '../../../../scenes/ContentViews/components/ContentViewIcon';

const relevantVersionObjFromCv = (cv, env) => { // returns the entire version object
  const versions = cv.versions.filter(version => new Set(version.environment_ids).has(env.id));
  return uniq(versions)?.[0];
};

const relevantVersionFromCv = (cv, env) =>
  relevantVersionObjFromCv(cv, env)?.version; // returns the version text e.g. "1.0"

const ContentViewDescription = ({ cv, versionNumber }) => {
  const descriptionStyle = {
    fontSize: '12px',
    fontWeight: 400,
    color: pfDescriptionColor.value,
  };
  if (cv.default) return <span style={descriptionStyle}>{__('Library')}</span>;
  return (
    <span style={descriptionStyle}>
      <FormattedMessage
        id={`content-view-${cv.id}-version-${cv.latest_version}`}
        defaultMessage="Version {versionNumber}"
        values={{ versionNumber }}
      />
    </span>
  );
};

ContentViewDescription.propTypes = {
  cv: PropTypes.shape({
    default: PropTypes.bool.isRequired,
    id: PropTypes.number.isRequired,
    latest_version: PropTypes.string.isRequired,
  }).isRequired,
  versionNumber: PropTypes.string.isRequired,
};

const ContentViewSelectOption = (cv, env) => (
  <SelectOption
    key={cv.id}
    value={`${cv.id}`}
  >
    <Flex
      direction={{ default: 'row', sm: 'row' }}
      flexWrap={{ default: 'nowrap' }}
      alignItems={{ default: 'alignItemsCenter', sm: 'alignItemsCenter' }}
    >
      <ContentViewIcon
        composite={cv.composite}
        size="sm"
      />
      <Flex
        direction={{ default: 'column', sm: 'column' }}
        flexWrap={{ default: 'nowrap' }}
        alignItems={{ default: 'alignItemsFlexStart', sm: 'alignItemsFlexStart' }}
      >
        {cv.name}
        <ContentViewDescription
          cv={cv}
          versionNumber={relevantVersionFromCv(cv, env)}
        />
      </Flex>
    </Flex>
  </SelectOption>
);

export default ContentViewSelectOption;
