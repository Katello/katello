import React from 'react';
import { translate as __ } from 'foremanReact/common/I18n';
import { Grid, GridItem, TextContent, Text, TextVariants } from '@patternfly/react-core';
import SyncPlansTable from "../SyncPlans/MainTable/SyncPlanTable";
const SyncPlanIndexPage = () => (
    <>
      <Grid className="margin-24">
        <GridItem span={12}>
          <TextContent>
            <Text component={TextVariants.h1}>{__('Sync plans')}</Text>
          </TextContent>
        </GridItem>
      </Grid>
      <Grid>
        <GridItem span={12}>
          <SyncPlansTable />
        </GridItem>
      </Grid>
    </>
)

export default SyncPlanIndexPage;