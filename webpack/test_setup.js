import 'foremanJSTestSetup';
import MutationObserver from '@sheerun/mutationobserver-shim';

// jsdom in jest 24 (standalone) lacks MutationObserver; shim needed for @testing-library/dom v7+
window.MutationObserver = MutationObserver;

// Minimal store for modules importing foremanReact/redux at module scope
jest.mock('foremanReact/redux', () => {
  const state = { katello: { setOrganization: { currentId: 1 } } };

  return { __esModule: true, default: { getState: () => state } };
});

// i18nProviderWrapperFactory renders async (waits for intl.ready); provide a synchronous
// version so renderWithI18n from rtlTestHelpers works with synchronous getBy* assertions.
jest.mock('foremanReact/common/i18nProviderWrapperFactory', () => {
  const React = require('react');
  const { IntlProvider } = require('react-intl');
  return {
    i18nProviderWrapperFactory: () => WrappedComponent => {
      const Wrapper = props =>
        React.createElement(IntlProvider, { locale: 'en' },
          React.createElement(WrappedComponent, props));
      return Wrapper;
    },
  };
});

// LongDateTime depends on react-intl's formatRelative which rejects out-of-range fixture dates
jest.mock('foremanReact/components/common/dates/LongDateTime', () => ({
  __esModule: true,
  // eslint-disable-next-line global-require
  default: ({ date, defaultValue }) => require('react').createElement('span', null, date || defaultValue || ''),
}));
