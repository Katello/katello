import React from 'react';
import { translate as __ } from 'foremanReact/common/I18n';
import { Grid, GridItem, TextContent, Text, TextVariants } from '@patternfly/react-core';
import ContentViewsTable from './Table/ContentViewsTable';
import ContentViewsCounter from './components/ContentViewsCounter';

const ContentViewsPage = () => (
  <Grid className="grid-with-margin">
    <GridItem span={12}>
      <TextContent>
        <Text component={TextVariants.h1}>{__('Content Views')}</Text>
      </TextContent>
    </GridItem>
    <GridItem span={12}>
      <ContentViewsCounter />
    </GridItem>
    <GridItem span={12}>
      <ContentViewsTable />
    </GridItem>
  </Grid>
);

export default ContentViewsPage;
