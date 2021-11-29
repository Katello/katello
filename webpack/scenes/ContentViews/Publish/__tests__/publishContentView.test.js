import React from 'react';
import * as reactRedux from 'react-redux';
import { renderWithRedux, patientlyWaitFor, fireEvent } from 'react-testing-lib-wrapper';
import { nockInstance, assertNockRequest } from '../../../../test-utils/nockWrapper';
import api from '../../../../services/api';
import PublishContentViewWizard from '../PublishContentViewWizard';
import cvDetailData from '../../Details/__tests__/contentViewDetails.fixtures.json';
import publishResponseData from './publishResponse.fixture.json';
import environmentPathsData from './environmentPaths.fixtures.json';

const cvPublishPath = api.getApiUrl('/content_views/1/publish');

const environmentPathsPath = api.getApiUrl('/organizations/1/environments/paths');

test('Can call API and show Wizard', async (done) => {
  const scope = nockInstance
    .get(environmentPathsPath)
    .query(true)
    .reply(200, environmentPathsData);
  const useSelectorMock = jest.spyOn(reactRedux, 'useSelector');
  useSelectorMock.mockReturnValue(environmentPathsData);

  const { getByText } = renderWithRedux(<PublishContentViewWizard
    details={cvDetailData}
    show
    setIsOpen={() => { }}
    currentStep={1}
    setCurrentStep={() => { }}
  />);

  await patientlyWaitFor(() => expect(getByText('Publish new version - 6.0')).toBeInTheDocument());
  useSelectorMock.mockClear();
  assertNockRequest(scope, done);
});

test('Can show Wizard and show environment paths', async (done) => {
  const scope = nockInstance
    .get(environmentPathsPath)
    .query(true)
    .reply(200, environmentPathsData);
  const useSelectorMock = jest.spyOn(reactRedux, 'useSelector');
  useSelectorMock.mockReturnValue(environmentPathsData);

  const { getByText, getByLabelText } = renderWithRedux(<PublishContentViewWizard
    details={cvDetailData}
    show
    setIsOpen={() => { }}
    currentStep={1}
    setCurrentStep={() => { }}
  />);

  await patientlyWaitFor(() => expect(getByText('Publish new version - 6.0')).toBeInTheDocument());
  const checkboxLabel = /promote-switch/;
  await patientlyWaitFor(() => expect(getByLabelText(checkboxLabel)).toBeInTheDocument());
  expect(getByLabelText(checkboxLabel).checked).toBeFalsy();
  fireEvent.click(getByLabelText(checkboxLabel));
  await patientlyWaitFor(() => {
    expect(getByLabelText(checkboxLabel).checked).toBeTruthy();
    expect(getByText('dev1')).toBeTruthy();
  });
  useSelectorMock.mockClear();
  assertNockRequest(scope, done);
});

test('Can show and hide force promotion alert', async (done) => {
  const scope = nockInstance
    .get(environmentPathsPath)
    .query(true)
    .reply(200, environmentPathsData);
  const useSelectorMock = jest.spyOn(reactRedux, 'useSelector');
  useSelectorMock.mockReturnValue(environmentPathsData);

  const {
    getByText, getByLabelText, queryByText, getAllByText,
  } = renderWithRedux(<PublishContentViewWizard
    details={cvDetailData}
    show
    setIsOpen={() => { }}
    currentStep={1}
    setCurrentStep={() => { }}
  />);

  await patientlyWaitFor(() => expect(getByText('Publish new version - 6.0')).toBeInTheDocument());
  const promoteSwitch = /promote-switch/;
  const inOrderEnv = 'dev1';
  const outOfOrderEnv = 'prod';
  const outOfOrderEnv2 = 'qa2';
  await patientlyWaitFor(() => expect(getByLabelText(promoteSwitch)).toBeInTheDocument());
  fireEvent.click(getByLabelText(promoteSwitch));
  await patientlyWaitFor(() => {
    expect(getByLabelText(promoteSwitch).checked).toBeTruthy();
    expect(getByLabelText(inOrderEnv)).toBeInTheDocument();
    expect(getByLabelText(outOfOrderEnv)).toBeInTheDocument();
  });

  // check outOfOrderEnv
  fireEvent.click(getByLabelText(outOfOrderEnv));
  expect(getByText('Force promotion')).toBeInTheDocument();
  expect(getAllByText(outOfOrderEnv)[0].closest('a'))
    .toHaveAttribute('href', '/lifecycle_environments/5');

  // check outOfOrder env in 2nd path
  fireEvent.click(getByLabelText(outOfOrderEnv2));
  expect(getByText('Force promotion')).toBeInTheDocument();
  expect(getAllByText(outOfOrderEnv2)[0].closest('a'))
    .toHaveAttribute('href', '/lifecycle_environments/7');

  // uncheck outOfOrderEnv
  fireEvent.click(getByLabelText(outOfOrderEnv));
  fireEvent.click(getByLabelText(outOfOrderEnv2));
  expect(queryByText('Force promotion')).not.toBeInTheDocument();

  // Check inOrderEnv
  fireEvent.click(getByLabelText(inOrderEnv));
  expect(queryByText('Force promotion')).not.toBeInTheDocument();

  useSelectorMock.mockClear();
  assertNockRequest(scope, done);
});


test('Can show Wizard form and move to review', async (done) => {
  const scope = nockInstance
    .get(environmentPathsPath)
    .query(true)
    .reply(200, environmentPathsData);

  const { getByText } = renderWithRedux(<PublishContentViewWizard
    details={cvDetailData}
    show
    setIsOpen={() => { }}
    currentStep={1}
    setCurrentStep={() => { }}
  />);
  const useSelectorMock = jest.spyOn(reactRedux, 'useSelector');
  useSelectorMock.mockReturnValue(environmentPathsData);
  await patientlyWaitFor(() => expect(getByText('Publish new version - 6.0')).toBeInTheDocument());
  await patientlyWaitFor(() => expect(getByText('Next')).toBeInTheDocument());
  fireEvent.click(getByText('Next'));
  // Test the review page
  await patientlyWaitFor(() => {
    expect(getByText('Newly published')).toBeInTheDocument();
    expect(getByText('Version 6.0')).toBeInTheDocument();
    expect(getByText('Library')).toBeTruthy();
  });
  useSelectorMock.mockClear();
  assertNockRequest(scope, done);
});

test('Can move to Finish step and publish CV', async (done) => {
  const scope = nockInstance
    .get(environmentPathsPath)
    .query(true)
    .reply(200, environmentPathsData);

  const cvPublishParams = {
    id: 1, versionCount: 5, description: '', environment_ids: [], is_force_promote: false,
  };

  const publishScope = nockInstance
    .post(cvPublishPath, cvPublishParams)
    .reply(202, publishResponseData);

  const { getByText } = renderWithRedux(<PublishContentViewWizard
    details={cvDetailData}
    show
    setIsOpen={() => { }}
    currentStep={1}
    setCurrentStep={() => { }}
  />);
  const useSelectorMock = jest.spyOn(reactRedux, 'useSelector');
  useSelectorMock.mockReturnValue(environmentPathsData);
  fireEvent.click(getByText('Next'));
  // Test the review page
  await patientlyWaitFor(() => {
    expect(getByText('Finish')).toBeInTheDocument();
  });
  fireEvent.click(getByText('Finish'));
  useSelectorMock.mockClear();
  assertNockRequest(scope);
  assertNockRequest(publishScope, done);
});
