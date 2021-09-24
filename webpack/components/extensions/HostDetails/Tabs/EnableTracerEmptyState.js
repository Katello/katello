import React, { useState, useEffect, useCallback } from 'react';
import useDeepCompareEffect from 'use-deep-compare-effect';
import {
  EmptyState,
  EmptyStateIcon,
  EmptyStateBody,
  Title,
  EmptyStateVariant,
  Button,
  Flex,
  FlexItem,
} from '@patternfly/react-core';
import { WrenchIcon } from '@patternfly/react-icons';
import { translate as __ } from 'foremanReact/common/I18n';
import { useSelector, useDispatch } from 'react-redux';
import { selectAPIResponse } from 'foremanReact/redux/API/APISelectors';
import EnableTracerModal from './EnableTracerModal';

const EnableTracerEmptyState = () => {
  const title = __('Traces are not enabled');
  const body = __('Traces help administrators identify applications that need to be restarted after a system is patched.');
  const [enableTracerModalOpen, setEnableTracerModalOpen] = useState(false);

  return (
    <EmptyState variant={EmptyStateVariant.small}>
      <EmptyStateIcon icon={WrenchIcon} />
      <Title headingLevel="h2" size="lg">
        {title}
      </Title>
      <EmptyStateBody>
        <Flex direction={{ default: 'column' }}>
          <FlexItem>{body}</FlexItem>
          <FlexItem>
            <Button onClick={() => setEnableTracerModalOpen(true)}>
              {__('Enable Traces')}
            </Button>
          </FlexItem>
        </Flex>
      </EmptyStateBody>
      <EnableTracerModal isOpen={enableTracerModalOpen} setIsOpen={setEnableTracerModalOpen} />
    </EmptyState>
  );
};

export default EnableTracerEmptyState;
