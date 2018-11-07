// import React from 'react';
import { shallow } from 'enzyme';
import toJson from 'enzyme-to-json';
import editFormatter from '../EntitlementsInlineEditFormatter';

describe('EntitlementsInlineEditFormatter', () => {
  const data = rowData => ({
    rowData,
  });

  const mockController = (options = {}) => {
    const { editing = true, changed = false } = options;
    return {
      isEditing: () => editing,
      hasChanged: () => changed,
    };
  };

  describe('edit mode', () => {
    describe('when available quantities are being loaded', () => {
      it('renders spinner', async () => {
        const controller = mockController();
        const value = 100;
        const formatter = editFormatter(controller)(value, data({
          upstreamAvailableLoaded: false,
        }));

        expect(toJson(shallow(formatter))).toMatchSnapshot();
      });
    });

    describe('when available quantities are loaded', () => {
      it('renders edit field and max available', async () => {
        const controller = mockController();
        const value = 100;
        const formatter = editFormatter(controller)(value, data({
          upstreamAvailableLoaded: true,
          upstreamAvailable: 500,
          maxQuantity: 600,
        }));

        expect(toJson(shallow(formatter))).toMatchSnapshot();
      });

      it('renders edit field and unlimited message', async () => {
        const controller = mockController();
        const value = 100;
        const formatter = editFormatter(controller)(value, data({
          upstreamAvailableLoaded: true,
          upstreamAvailable: -1,
          maxQuantity: -1,
        }));

        expect(toJson(shallow(formatter))).toMatchSnapshot();
      });

      it('renders validation message', async () => {
        const controller = mockController();
        const value = 200;
        const formatter = editFormatter(controller)(value, data({
          upstreamAvailableLoaded: true,
          upstreamAvailable: 100,
          maxQuantity: 150,
        }));

        expect(toJson(shallow(formatter))).toMatchSnapshot();
      });

      it('renders changed values', async () => {
        const controller = mockController({ changed: true });
        const value = 100;
        const formatter = editFormatter(controller)(value, data({
          upstreamAvailableLoaded: true,
          upstreamAvailable: 200,
          maxQuantity: 300,
        }));

        expect(toJson(shallow(formatter))).toMatchSnapshot();
      });
    });

    describe('when available quantities failed to load', () => {
      it('renders just the edit field', async () => {
        const controller = mockController();
        const value = 200;
        const formatter = editFormatter(controller)(value, data({
          upstreamAvailableLoaded: true,
        }));

        expect(toJson(shallow(formatter))).toMatchSnapshot();
      });
    });
  });

  describe('value mode', () => {
    it('renders the value', async () => {
      const controller = mockController({ editing: false });
      const value = 200;
      const formatter = editFormatter(controller)(value, data({
        upstream_pool_id: ' ',
      }));

      expect(toJson(shallow(formatter))).toMatchSnapshot();
    });

    it('renders unlimited for -1', async () => {
      const controller = mockController({ editing: false });
      const value = 200;
      const formatter = editFormatter(controller)(value, data({
        available: -1,
        upstream_pool_id: ' ',
      }));

      expect(toJson(shallow(formatter))).toMatchSnapshot();
    });
  });
});
