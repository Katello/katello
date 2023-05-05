import React from 'react';
import { translate as __ } from 'foremanReact/common/I18n';
import { Grid, GridItem, TextContent, Text, TextVariants } from '@patternfly/react-core';
import ACSTable from './MainTable/ACSTable';

const ACSIndexPage = () => (
  <>
    <Grid className="margin-24">
      <GridItem span={12}>
        <TextContent>
          <Text
            ouiaId="acs-text"
            component={TextVariants.h1}
          >
            {__('Alternate Content Sources')}
          </Text>
        </TextContent>
      </GridItem>
    </Grid>
    <Grid>
      <GridItem span={12}>
        <ACSTable />
      </GridItem>
    </Grid>
  </>
);

export default ACSIndexPage;
