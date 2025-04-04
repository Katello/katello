import React, { useContext } from 'react';
import {
  Badge,
  Button,
  Flex,
  FlexItem,
  Text,
  TextContent,
  TextVariants,
  Grid,
  GridItem,
  useWizardContext,
} from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import { BulkRepositorySetsWizardContext } from './BulkRepositorySetsWizard';
import { dropdownValues } from './01_BulkRepositorySetsTable';

export const BulkRepositorySetsReview = () => {
  const { goToStepById } = useWizardContext();
  const {
    pendingOverrides,
  } = useContext(BulkRepositorySetsWizardContext);
  const overridesEntries = Object.entries(pendingOverrides);
  const overridesTexts = overridesEntries
    .filter(([_repoLabel, value]) => Number(value) !== 0)
    .map(([repoLabel, value]) => [repoLabel, dropdownValues[value]]);

  return (
    <>
      <TextContent>
        <Text component={TextVariants.h3} ouiaId="bulk-repo-sets-wizard-review-header">
          {__('Review')}
        </Text>
        <Text component={TextVariants.p} ouiaId="bulk-repo-sets-wizard-review-description">
          {__('Review and then click \'Set content overrides.\' Status will be changed for the selected repository sets on the selected hosts.')}
        </Text>
      </TextContent>
      <Grid>
        <GridItem span={8}>
          <Flex>
            <FlexItem>
              <Text component={TextVariants.h4} ouiaId="bulk-repo-sets-wizard-review-header">
                <strong>{__('Changed status')}</strong>
              </Text>
            </FlexItem>
            <FlexItem>
              <Badge isRead>
                {overridesTexts.length}
              </Badge>
            </FlexItem>
          </Flex>
        </GridItem>
        <GridItem span={4}>
          <Text component={TextVariants.p} ouiaId="brsw-review-step-edit-wrapper">
            <Button variant="link" onClick={() => goToStepById('brsw-step-1')} ouiaId="brsw-review-step-edit-btn">
              {__('Edit')}
            </Button>
          </Text>
        </GridItem>
        {overridesTexts.map(([repoLabel, actionText]) => (
          <React.Fragment key={repoLabel}>
            <GridItem span={8}>
              <Text component={TextVariants.p} ouiaId="brsw-review-step-repo-label">
                {repoLabel}
              </Text>
            </GridItem>
            <GridItem span={4}>
              <Text component={TextVariants.p} ouiaId="brsw-review-step-action-text">
                {actionText}
              </Text>
            </GridItem>
          </React.Fragment>
        ))}
      </Grid>
    </>
  );
};

export default BulkRepositorySetsReview;
