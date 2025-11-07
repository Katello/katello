import React from 'react';
import { render } from '@testing-library/react';
import ModuleStreamDetailArtifacts from '../ModuleStreamDetailArtifacts';
import { details } from './moduleStreamDetails.fixtures';

describe('Module stream detail artifacts component', () => {
  test('renders artifact list with all artifact names', () => {
    const { getByText } = render(<ModuleStreamDetailArtifacts artifacts={details.artifacts} />);

    expect(getByText('python3-avocado-plugins-varianter-yaml-to-mux-0:63.0-2.module_2037+1b0ad681.noarch')).toBeInTheDocument();
    expect(getByText('python3-avocado-plugins-varianter-pict-0:63.0-2.module_2037+1b0ad681.noarch')).toBeInTheDocument();
  });

  test('renders each artifact in a list item', () => {
    const { getAllByRole } = render(<ModuleStreamDetailArtifacts artifacts={details.artifacts} />);

    const listItems = getAllByRole('listitem');
    expect(listItems).toHaveLength(details.artifacts.length);
  });

  test('renders empty list when no artifacts provided', () => {
    const { queryAllByRole } = render(<ModuleStreamDetailArtifacts artifacts={[]} />);

    const listItems = queryAllByRole('listitem');
    expect(listItems).toHaveLength(0);
  });
});
