import React, { useEffect, useState } from 'react';
import { useDispatch, shallowEqual, useSelector } from 'react-redux';
import { Split, SplitItem, GridItem, TextContent, Text, TextVariants, Label } from '@patternfly/react-core';
import { STATUS } from 'foremanReact/constants';

import RepoIcon from '../Repositories/RepoIcon';
import { repoType, capitalize } from '../../../../utils/helpers';

const ContentViewFilterDetailsHeader = ({ details }) => {
  const { type, name, inclusion, description } = details;
  const repositoryType = repoType(type);
  const displayedType = type ? capitalize(type.replace(/_/g, " ")) : "";

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
            <Label color="blue">{inclusion ? "Include" : "Exclude" }</Label>
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
}

export default ContentViewFilterDetailsHeader;