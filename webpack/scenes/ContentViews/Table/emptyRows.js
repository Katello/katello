// Meant for when the user has none of the object created, not when a search returns empty results
import React from 'react';
import { EmptyState,
  EmptyStateBody,
  EmptyStateIcon,
  EmptyStateVariant,
  Bullseye,
  Title } from '@patternfly/react-core';
import { CubeIcon } from '@patternfly/react-icons';
import { translate as __ } from 'foremanReact/common/I18n';

const emptyRows = [{
  heightAuto: true,
  noactions: 'true',
  cells: [
    {
      props: { colSpan: 6, noactions: 'true' },
      title: (
        <Bullseye>
          <EmptyState variant={EmptyStateVariant.small}>
            <EmptyStateIcon icon={CubeIcon} />
            <Title headingLevel="h2" size="lg">
              {__("You currently don't have any Content Views.")}
            </Title>
            <EmptyStateBody>
              {__('A Content View can be added by using the "New content view" button above.')}
            </EmptyStateBody>
          </EmptyState>
        </Bullseye>
      ),
    },
  ],
}];

export default emptyRows;
