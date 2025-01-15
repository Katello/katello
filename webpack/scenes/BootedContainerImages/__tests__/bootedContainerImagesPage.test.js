import React from 'react';
import { renderWithRedux, patientlyWaitFor, act } from 'react-testing-lib-wrapper';
import { nockInstance, assertNockRequest, mockAutocomplete } from '../../../test-utils/nockWrapper';
import api from '../../../services/api';
import BOOTED_CONTAINER_IMAGES_KEY from '../BootedContainerImagesConstants';
import BootedContainerImagesPage from '../BootedContainerImagesPage';
import bootcImagesData from './bootedContainerImages.fixtures';

// const bootedContainerImagesIndexPath = api.getApiUrl('/booted_container_images');
// const renderOptions = { apiNamespace: BOOTED_CONTAINER_IMAGES_KEY };
const bootcImagesUrl = '/api/v2/hosts/bootc_images';
const autocompleteUrl = '/host_bootc_images/auto_complete_search';
const autocompleteQuery = {
  search: '',
};

let firstImage;
let secondImage;
beforeEach(() => {
  const { results } = bootcImagesData;
  [firstImage, secondImage] = results;
});

test('BootedContainerImagesPage renders correctly', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl, autocompleteQuery);
  const scope = nockInstance
    .get(bootcImagesUrl)
    .query(true)
    // Why does the page load twice?
    .times(2)
    .reply(200, bootcImagesData);

  const { queryByText, queryAllByText } = renderWithRedux(<BootedContainerImagesPage />);
  expect(queryByText(firstImage.bootc_booted_image)).toBeNull();

  await patientlyWaitFor(() => {
    expect(queryByText(firstImage.bootc_booted_image)).toBeInTheDocument();
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done);
  act(done);
});
