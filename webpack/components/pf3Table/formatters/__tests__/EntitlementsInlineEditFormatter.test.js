import React from 'react';
import { render, screen } from '@testing-library/react';
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

  const renderFormatter = (controller, value, rowData) => {
    const formatter = editFormatter(controller)(value, data(rowData));
    const component = (
      <table><tbody><tr>{formatter}</tr></tbody></table>
    );
    return render(component);
  };

  describe('edit mode', () => {
    describe('when available quantities are being loaded', () => {
      it('renders spinner while loading', () => {
        const controller = mockController();
        renderFormatter(controller, 100, {
          upstreamAvailableLoaded: false,
        });

        expect(screen.queryByDisplayValue('100')).not.toBeInTheDocument();
      });
    });

    describe('when available quantities are loaded', () => {
      it('renders edit field and max available', () => {
        const controller = mockController();
        renderFormatter(controller, 100, {
          upstreamAvailableLoaded: true,
          upstreamAvailable: 500,
          maxQuantity: 600,
        });

        expect(screen.getByDisplayValue('100')).toBeInTheDocument();
        expect(screen.getByText('Max 600')).toBeInTheDocument();
      });

      it('renders edit field and unlimited message', () => {
        const controller = mockController();
        renderFormatter(controller, 100, {
          upstreamAvailableLoaded: true,
          upstreamAvailable: -1,
          maxQuantity: -1,
        });

        expect(screen.getByDisplayValue('100')).toBeInTheDocument();
        expect(screen.getByText('Unlimited')).toBeInTheDocument();
      });

      it('renders validation message when value exceeds max', () => {
        const controller = mockController();
        renderFormatter(controller, 200, {
          upstreamAvailableLoaded: true,
          upstreamAvailable: 100,
          maxQuantity: 150,
        });

        expect(screen.getByDisplayValue('200')).toBeInTheDocument();
        expect(screen.getByText('Max 150')).toBeInTheDocument();
        expect(screen.getByText('Exceeds available quantity')).toBeInTheDocument();
      });

      it('renders when value has changed', () => {
        const controller = mockController({ changed: true });
        renderFormatter(controller, 100, {
          upstreamAvailableLoaded: true,
          upstreamAvailable: 200,
          maxQuantity: 300,
        });

        expect(screen.getByDisplayValue('100')).toBeInTheDocument();
      });
    });

    describe('when available quantities failed to load', () => {
      it('renders just the edit field', () => {
        const controller = mockController();
        renderFormatter(controller, 200, {
          upstreamAvailableLoaded: true,
        });

        expect(screen.getByDisplayValue('200')).toBeInTheDocument();
      });
    });
  });

  describe('value mode', () => {
    it('renders the numeric value', () => {
      const controller = mockController({ editing: false });
      renderFormatter(controller, 200, {});

      expect(screen.getByText('200')).toBeInTheDocument();
    });

    it('shows NA for collapsible row', () => {
      const controller = mockController({ editing: false });
      renderFormatter(controller, undefined, {
        collapsible: true,
      });

      expect(screen.getByText('NA')).toBeInTheDocument();
    });

    it('renders unlimited for -1', () => {
      const controller = mockController({ editing: false });
      renderFormatter(controller, -1, {});

      expect(screen.getByText('Unlimited')).toBeInTheDocument();
    });
  });
});
