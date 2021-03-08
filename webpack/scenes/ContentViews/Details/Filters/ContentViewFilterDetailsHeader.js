import React from 'react';
import PropTypes from 'prop-types';
import { Split, SplitItem, GridItem, TextContent, Text, TextVariants, Label } from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';

import RepoIcon from '../Repositories/RepoIcon';
import { repoType, capitalize } from '../../../../utils/helpers';

const ContentViewFilterDetailsHeader = ({ details }) => {
  const {
    type, name, inclusion, description,
  } = details;
  const repositoryType = repoType(type);
  const displayedType = type ? capitalize(type.replace(/_/g, ' ')) : '';

  return (
    <>
      <GridItem span={12}>
        <TextContent>
          <Text component={TextVariants.h2}>{name}</Text>
        </TextContent>
      </GridItem>
      <GridItem span={10}>
        <Split hasGutter>
          <SplitItem>
            <Label color="blue">{inclusion ? __('Include') : __('Exclude') }</Label>
          </SplitItem>
          <SplitItem>
            <RepoIcon type={repositoryType} />
          </SplitItem>
          <SplitItem>
            <Text component={TextVariants.p}>
              {displayedType}
            </Text>
          </SplitItem>
        </Split>
      </GridItem>
      <GridItem span={12}>
        <TextContent>
          <Text component={TextVariants.p}>{description}</Text>
        </TextContent>
      </GridItem>
    </>
  );
};

ContentViewFilterDetailsHeader.propTypes = {
  details: PropTypes.shape({
    name: PropTypes.string,
    type: PropTypes.string,
    inclusion: PropTypes.bool,
    description: PropTypes.string,
  }).isRequired,
};

export default ContentViewFilterDetailsHeader;
