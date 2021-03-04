import React from 'react';
import PropTypes from 'prop-types';
import { Split, SplitItem, GridItem, TextContent, Text, TextVariants, Label } from '@patternfly/react-core';

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
            <Label color="blue">{inclusion ? 'Include' : 'Exclude' }</Label>
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
    name: PropTypes.string.isRequired,
    type: PropTypes.string.isRequired,
    inclusion: PropTypes.bool.isRequired,
    description: PropTypes.string.isRequired,
  }).isRequired,
};

export default ContentViewFilterDetailsHeader;
