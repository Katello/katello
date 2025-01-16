import React from 'react';
import { renderWithRedux, patientlyWaitFor, act } from 'react-testing-lib-wrapper';
import { nockInstance, assertNockRequest, mockAutocomplete } from '../../../test-utils/nockWrapper';
import BootedContainerImagesPage from '../BootedContainerImagesPage';
import bootcImagesData from './bootedContainerImages.fixtures';

const bootcImagesUrl = '/api/v2/hosts/bootc_images';
const autocompleteUrl = '/host_bootc_images/auto_complete_search';
const autocompleteQuery = {
  search: '',
};

const buildBootedImage = id => ({
  bootc_booted_image: `quay.io/centos-bootc/centos-bootc:stream${id}`,
  digests: [
    {
      bootc_booted_digest: `sha256:54256a998f0c62e16f3927c82b570f90bd8449a52e03daabd5fd16d6419fd57${id}`,
      host_count: 1,
    },
  ],
});

const createBootedImages = (amount) => {
  const response = {
    total: amount,
    subtotal: amount,
    page: 1,
    per_page: 20,
    error: null,
    search: null,
    sort: {
      by: 'bootc_booted_image',
      order: 'asc',
    },
    results: [],
  };

  [...Array(amount).keys()].forEach((_, i) => response.results.push(buildBootedImage(i + 1)));

  return response;
};

let centos10Image;
let centos9Image;
let stream10Digest1;
let stream10Digest2;
let stream10Digest3;
let stream10Digest4;
let stream9Digest;
beforeEach(() => {
  const { results } = bootcImagesData;
  [centos10Image, centos9Image] = results;
  [stream10Digest1, stream10Digest2, stream10Digest3, stream10Digest4] =
    centos10Image.digests.map(digest => digest.bootc_booted_digest);
  stream9Digest = centos9Image.digests[0].bootc_booted_digest;
});

test('BootedContainerImagesPage renders correctly expanded', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl, autocompleteQuery);
  const scope = nockInstance
    .get(bootcImagesUrl)
    .query(true)
    // Why does the page load twice?
    .times(2)
    .reply(200, bootcImagesData);

  const {
    queryByText, queryAllByText, queryAllByRole,
  } = renderWithRedux(<BootedContainerImagesPage />);

  expect(queryByText(centos10Image.bootc_booted_image)).toBeNull();

  await patientlyWaitFor(() => {
    // Expand the rows
    queryAllByRole('button').find(btn => btn.getAttribute('aria-labelledby') ===
      'simple-node1 booted-containers-expander-quay.io/centos-bootc/centos-bootc:stream91').click();
    queryAllByRole('button').find(btn => btn.getAttribute('aria-labelledby') ===
      'simple-node0 booted-containers-expander-quay.io/centos-bootc/centos-bootc:stream100').click();

    // Check that the digest host count links appear
    expect(queryAllByText('1').find(link => String(link.getAttribute('href')).includes(stream10Digest1))).toBeVisible();
    expect(queryAllByText('2').find(link => String(link.getAttribute('href')).includes(stream10Digest2))).toBeVisible();
    expect(queryAllByText('3').find(link => String(link.getAttribute('href')).includes(stream10Digest3))).toBeVisible();
    expect(queryAllByText('4').find(link => String(link.getAttribute('href')).includes(stream10Digest4))).toBeVisible();
    expect(queryAllByText('6').find(link => String(link.getAttribute('href')).includes(stream9Digest))).toBeVisible();

    // Check that the image host count links appear
    const links = queryAllByRole('link');
    const stream10Link = links.find(link => link.getAttribute('href') === `/new/hosts?search=bootc_booted_image%20=%20${centos10Image.bootc_booted_image}`);
    const stream9Link = links.find(link => link.getAttribute('href') === `/new/hosts?search=bootc_booted_image%20=%20${centos9Image.bootc_booted_image}`);
    expect(stream10Link).toBeVisible();
    expect(stream9Link).toBeVisible();

    // Check that the image names appear
    expect(queryByText(centos10Image.bootc_booted_image)).toBeVisible();
    expect(queryByText(centos9Image.bootc_booted_image)).toBeVisible();

    // Check that the digest counts appear
    // console.log(queryAllByText('4')[0].closest('td'));
    expect(queryAllByText('4')[0].closest('td')).toBeVisible();
    expect(queryAllByText('1')[1].closest('td')).toBeVisible();

    // Check that the digest names appear
    expect(queryByText(stream10Digest1).closest('td')).toBeVisible();
    expect(queryByText(stream10Digest2).closest('td')).toBeVisible();
    expect(queryByText(stream10Digest3).closest('td')).toBeVisible();
    expect(queryByText(stream10Digest4).closest('td')).toBeVisible();
    expect(queryByText(stream9Digest).closest('td')).toBeVisible();
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done);
  act(done);
});

test('BootedContainerImagesPage renders correctly unexpanded', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl, autocompleteQuery);
  const scope = nockInstance
    .get(bootcImagesUrl)
    .query(true)
    // Why does the page load twice?
    .times(2)
    .reply(200, bootcImagesData);

  const {
    queryByText, queryAllByText, queryAllByRole,
  } = renderWithRedux(<BootedContainerImagesPage />);

  expect(queryByText(centos10Image.bootc_booted_image)).toBeNull();

  await patientlyWaitFor(() => {
    // Check that the digest host count links don't appear
    expect(queryAllByText('1').find(link => String(link.getAttribute('href')).includes(stream10Digest1))).not.toBeVisible();
    expect(queryAllByText('2').find(link => String(link.getAttribute('href')).includes(stream10Digest2))).not.toBeVisible();
    expect(queryAllByText('3').find(link => String(link.getAttribute('href')).includes(stream10Digest3))).not.toBeVisible();
    expect(queryAllByText('4').find(link => String(link.getAttribute('href')).includes(stream10Digest4))).not.toBeVisible();
    expect(queryAllByText('6').find(link => String(link.getAttribute('href')).includes(stream9Digest))).not.toBeVisible();

    // Check that the image host count links appear
    const links = queryAllByRole('link');
    const stream10Link = links.find(link => link.getAttribute('href') === `/new/hosts?search=bootc_booted_image%20=%20${centos10Image.bootc_booted_image}`);
    const stream9Link = links.find(link => link.getAttribute('href') === `/new/hosts?search=bootc_booted_image%20=%20${centos9Image.bootc_booted_image}`);
    expect(stream10Link).toBeVisible();
    expect(stream9Link).toBeVisible();

    // Check that the image names appear
    expect(queryByText(centos10Image.bootc_booted_image)).toBeVisible();
    expect(queryByText(centos9Image.bootc_booted_image)).toBeVisible();

    // Check that the digest counts appear
    expect(queryAllByText('4')[0].closest('td')).toBeVisible();
    expect(queryAllByText('1')[1].closest('td')).toBeVisible();

    // Check that the digest names don't appear
    expect(queryByText(stream10Digest1).closest('td')).not.toBeVisible();
    expect(queryByText(stream10Digest2).closest('td')).not.toBeVisible();
    expect(queryByText(stream10Digest3).closest('td')).not.toBeVisible();
    expect(queryByText(stream10Digest4).closest('td')).not.toBeVisible();
    expect(queryByText(stream9Digest).closest('td')).not.toBeVisible();
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done);
  act(done);
});

test('Can handle no booted images being present', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl, autocompleteQuery);
  const noResults = {
    total: 0,
    subtotal: 0,
    page: 1,
    per_page: 20,
    results: [],
  };
  const scope = nockInstance
    .get(bootcImagesUrl)
    .query(true)
    // Why does the page load twice?
    .times(2)
    .reply(200, noResults);
  const { queryByText } = renderWithRedux(<BootedContainerImagesPage />);

  expect(queryByText(centos10Image.bootc_booted_image)).toBeNull();
  await patientlyWaitFor(() => expect(queryByText('No Results')).toBeInTheDocument());
  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done);
});

test('Can handle pagination', async (done) => {
  const largeBootcData = createBootedImages(100);
  const { results } = largeBootcData;
  const bootcFirstPage = { ...largeBootcData, ...{ results: results.slice(0, 20) } };
  const bootcSecondPage = { ...largeBootcData, page: 2, results: results.slice(20, 40) };
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl, autocompleteQuery);

  // Match first page API request
  const firstPageScope = nockInstance
    .get(bootcImagesUrl)
    .query(true)
    .times(2)
    .reply(200, bootcFirstPage);

  // Match second page API request
  const secondPageScope = nockInstance
    .get(bootcImagesUrl)
    // Using a custom query params matcher because parameters can be strings
    .query(actualQueryObject => (parseInt(actualQueryObject.page, 10) === 2))
    .reply(200, bootcSecondPage);
  const { queryByText, getAllByLabelText } = renderWithRedux(<BootedContainerImagesPage />);
  // Wait for first paginated page to load and assert only the first page of results are present
  await patientlyWaitFor(() => {
    expect(queryByText(results[0].bootc_booted_image)).toBeInTheDocument();
    expect(queryByText(results[19].bootc_booted_image)).toBeInTheDocument();
    expect(queryByText(results[21].bootc_booted_image)).not.toBeInTheDocument();
  });

  // Label comes from patternfly, if this test fails, check if patternfly updated the label.
  const [top, bottom] = getAllByLabelText('Go to next page');
  expect(top).toBeInTheDocument();
  expect(bottom).toBeInTheDocument();
  bottom.click();
  // Wait for second paginated page to load and assert only the second page of results are present
  await patientlyWaitFor(() => {
    expect(queryByText(results[20].bootc_booted_image)).toBeInTheDocument();
    expect(queryByText(results[39].bootc_booted_image)).toBeInTheDocument();
    expect(queryByText(results[41].bootc_booted_image)).not.toBeInTheDocument();
  });
  assertNockRequest(autocompleteScope);
  assertNockRequest(firstPageScope);
  assertNockRequest(secondPageScope, done);
  act(done);
});
