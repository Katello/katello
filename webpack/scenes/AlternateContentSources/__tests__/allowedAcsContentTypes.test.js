import { allowedAcsContentTypes } from '../helpers';

const satelliteContentTypes = ['yum', 'file'];
const upstreamContentTypes = ['yum', 'file', 'deb'];

test('upstream offers yum, deb, and file for custom and simplified ACS', () => {
  expect(allowedAcsContentTypes('custom', upstreamContentTypes)).toEqual(['yum', 'deb', 'file']);
  expect(allowedAcsContentTypes('simplified', upstreamContentTypes)).toEqual(['yum', 'deb', 'file']);
  expect(allowedAcsContentTypes('custom')).toEqual(['yum', 'deb', 'file']);
});

test('satellite stream offers only yum and file for custom and simplified ACS', () => {
  expect(allowedAcsContentTypes('custom', satelliteContentTypes)).toEqual(['yum', 'file']);
  expect(allowedAcsContentTypes('simplified', satelliteContentTypes)).toEqual(['yum', 'file']);
});

test('rhui ACS stays yum only', () => {
  expect(allowedAcsContentTypes('rhui', upstreamContentTypes)).toEqual(['yum']);
  expect(allowedAcsContentTypes('rhui', satelliteContentTypes)).toEqual(['yum']);
});
