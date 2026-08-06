import 'foremanJSTestSetup';
import React from 'react';
import MutationObserver from '@sheerun/mutationobserver-shim';

// jsdom in jest 24 (standalone) lacks MutationObserver; shim needed for @testing-library/dom v7+
window.MutationObserver = MutationObserver;

// Minimal store for modules importing foremanReact/redux at module scope
jest.mock('foremanReact/redux', () => {
  const state = { katello: { setOrganization: { currentId: 1 } } };

  return { __esModule: true, default: { getState: () => state } };
});

// LongDateTime depends on react-intl's formatRelative which rejects out-of-range fixture dates
jest.mock('foremanReact/components/common/dates/LongDateTime', () => ({
  __esModule: true,
  default: ({ date, defaultValue }) => React.createElement('span', null, date || defaultValue || ''),
}));
