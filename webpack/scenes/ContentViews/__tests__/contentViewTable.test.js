import React from 'react';
import { render, fireEvent, within } from 'react-testing-lib-wrapper';
import ContentViewsTable from '../Table/ContentViewsTable.js';

const contentViewIndex = require('./contentViewList.fixtures.json');

let firstCV;
let contentViews;
beforeEach(() => {
  const { results } = contentViewIndex;
  contentViews = results;
  [firstCV] = results;
});

const defaultProps = {
  loadContentViewDetails: () => {},
  detailsMap: {},
};

test('Can view content views on the screen', () => {
  const { getByText, queryByTestId, queryByText } =
    render(<ContentViewsTable results={contentViews} loading={false} {...defaultProps} />);

  // query* functions will return the element or null if it cannot be found
  // get* functions will return the element or throw an error if it cannot be found
  // Loop through the CVs in the fixture and ensure they are present
  contentViewIndex.results.map(({ name }) => {
    expect(getByText(name)).toBeTruthy();
    return name;
  });

  // Ensure loading text is not showing as a baseline sanity check Using .toBeNull() here as the
  // loading spinner isn't even in the DOM, as opposed to an element that is in the DOM but hidden.
  // Also using a test id that is set in the the application code so we can correctly identify the
  // loading text. Pattern matching by "Loading" seems like it could give false positives, a test
  // id will ensure we are correctly identifying the loading text.
  expect(queryByTestId('cv-loading-text')).toBeNull();

  // Ensure empty state text isn't showing as a baseline sanity check
  expect(queryByText(/You currently don't have any Content Views/)).toBeFalsy();
});

test('Loading spinner is showing when no data is loaded yet', () => {
  const { getByTestId } = render(<ContentViewsTable results={[]} loading {...defaultProps} />);

  // Now we check if the loading text is showing
  expect(getByTestId('cv-loading-text')).toBeVisible();
});

test('Empty state message is shown when no Content Views are created yet', () => {
  const { getByText } = render(<ContentViewsTable
    results={[]}
    loading={false}
    {...defaultProps}
  />);

  expect(getByText(/You currently don't have any Content Views/)).toBeTruthy();
});

test('Can view Environment dropdown when cell is clicked', () => {
  const { getByText, getByTestId } =
    render(<ContentViewsTable results={contentViews} loading={false} {...defaultProps} />);

  // Getting the row that corresponds with the first CV name
  const firstRow = within(getByText(firstCV.name).closest('tr'));

  // Make sure the environment expandable is not showing
  // This uses a specific test id set in the application code, but as it is built out, it could use
  // text shown on screen, which is prefered by the library. https://testing-library.com/docs/guide-which-query
  // Using .toBeVisible() here as the element is in the DOM but hidden from the user's view
  expect(getByTestId(`cv-environments-expansion-${firstCV.id}`)).not.toBeVisible();

  // Click on the environments table cell in the row to expand the dropdown.
  fireEvent.click(firstRow.getByLabelText(`environments-icon-${firstCV.id}`));

  // Ensure the environment expandable is now visible on screen to the user.
  expect(getByTestId(`cv-environments-expansion-${firstCV.id}`)).toBeVisible();
});
