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

// const dropdownValues = {
//   0: __('No change'),
//   1: __('Override to enabled'),
//   2: __('Override to disabled'),
//   3: __('Reset to default'),
// };

const pendingOverrideToApiParamItem = ({ repoLabel, value }) => {
  switch (Number(value)) {
  case 0:
    return null;
  case 1:
    return {
      content_label: repoLabel,
      name: 'enabled',
      value: true,
    };
  case 2:
    return {
      content_label: repoLabel,
      name: 'enabled',
      value: false,
    };
  case 3:
    return {
      content_label: repoLabel,
      name: 'enabled',
      remove: true,
    };
  default:
    return null;
  }
};

export const BulkRepositorySetsReview = () => {
  const { goToStepById, activeStep } = useWizardContext();
  const {
    pendingOverrides, setShouldValidateStep1, setShouldValidateStep2,
  } = useContext(BulkRepositorySetsWizardContext);
  const overridesEntries = Object.entries(pendingOverrides);
  const apiParams = overridesEntries
    .map(([repoLabel, value]) => pendingOverrideToApiParamItem({ repoLabel, value }))
    .filter(item => item);
  console.log(apiParams);

  const overridesTexts = overridesEntries
    .filter(([_repoLabel, value]) => Number(value) !== 0)
    .map(([repoLabel, value]) => [repoLabel, dropdownValues[value]]);

  if (activeStep?.id === 'brsw-step-3') {
    setShouldValidateStep1(true);
    setShouldValidateStep2(true);
  }
  return (
    <>
      <TextContent>
        <Text component={TextVariants.h3} ouiaId="bulk-repo-sets-wizard-review-header">
          {__('Review')}
        </Text>
        <Text component={TextVariants.p} ouiaId="bulk-repo-sets-wizard-review-description">
          {__('Review and then click Submit. Status will be changed for the selected repository sets on the selected hosts.')}
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
          <>
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
          </>
        ))}
      </Grid>
    </>
  );
};

export default BulkRepositorySetsReview;
