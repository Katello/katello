// For when no items exists, use this as rows in the table.
// Not to be used for empty searches
import React from 'react';
import { EmptyState,
  EmptyStateBody,
  EmptyStateIcon,
  EmptyStateVariant,
  Bullseye,
  Title } from '@patternfly/react-core';
import { CubeIcon } from '@patternfly/react-icons';

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
              You currently don&apos;t have any Content Views.
            </Title>
            <EmptyStateBody>
              A Content View can be added by using the &quot;New content view&quot; button above.
            </EmptyStateBody>
          </EmptyState>
        </Bullseye>
      ),
    },
  ],
}];

export default emptyRows;
