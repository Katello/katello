// Setup file for enzyme
// See http://airbnb.io/enzyme/docs/installation/react-16.html
import 'core-js/shim';
import 'regenerator-runtime/runtime';

import { configure } from 'enzyme';
import Adapter from 'enzyme-adapter-react-16';
import MutationObserver from '@sheerun/mutationobserver-shim';
import * as Services from './services/api';

configure({ adapter: new Adapter() });

// Mocking translation function
global.__ = text => text; // eslint-disable-line
Services.orgId = () => 1;

// Mocking locales to prevent unnecessary fallback messages
window.locales = { en: { domain: 'app', locale_data: { app: { '': {} } } } };

// see https://github.com/testing-library/dom-testing-library/releases/tag/v7.0.0
window.MutationObserver = MutationObserver;

// This will return undefined in test environments and is expected in some helper functions.
window.URL_PREFIX = '';
