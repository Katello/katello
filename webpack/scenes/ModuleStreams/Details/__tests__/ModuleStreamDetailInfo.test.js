import React from 'react';
import { render } from '@testing-library/react';
import ContentDetailInfo from '../../../../components/Content/Details/ContentDetailInfo';
import { details } from './moduleStreamDetails.fixtures';
import { displayMap } from '../ModuleDetailsSchema';

describe('Module stream detail info component', () => {
  test('renders table with module stream details', () => {
    const { getByText } = render(<ContentDetailInfo
      contentDetails={details}
      displayMap={displayMap}
    />);

    // Verify all field labels are displayed
    expect(getByText('Name')).toBeInTheDocument();
    expect(getByText('Summary')).toBeInTheDocument();
    expect(getByText('Description')).toBeInTheDocument();
    expect(getByText('Stream')).toBeInTheDocument();
    expect(getByText('Version')).toBeInTheDocument();
    expect(getByText('Arch')).toBeInTheDocument();
    expect(getByText('Context')).toBeInTheDocument();
    expect(getByText('UUID')).toBeInTheDocument();

    // Verify actual values from fixture data are displayed
    expect(getByText('avocado')).toBeInTheDocument();
    expect(getByText('Framework with tools and libraries for Automated Testing')).toBeInTheDocument();
    expect(getByText('Avocado is a set of tools and libraries (what people call these days a framework) to perform automated testing.')).toBeInTheDocument();
    expect(getByText('latest')).toBeInTheDocument();
    expect(getByText('20180816135607')).toBeInTheDocument();
    expect(getByText('x86_64')).toBeInTheDocument();
    expect(getByText('a5b0195c')).toBeInTheDocument();
    expect(getByText('8ae7f190-0a48-41a2-93e0-7bc3e4734355')).toBeInTheDocument();
  });
});
