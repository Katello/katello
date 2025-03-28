import React from 'react';
import { renderWithRedux } from 'react-testing-lib-wrapper';
import { CardExpansionContext } from 'foremanReact/components/HostDetails/CardExpansionContext';
import InstalledProductsCard from '../InstalledProductsCard';

const hostDetails = {
  subscription_facet_attributes: {
    installed_products: [
      { productId: '479', productName: 'Red Hat Enterprise Linux for x86_64' },
    ],
  },
};
const customRender = (ui, { providerProps, ...renderOptions }) => renderWithRedux(
  <CardExpansionContext.Provider value={providerProps}>{ui}</CardExpansionContext.Provider>,
  renderOptions,
);

describe('Installed Products Card', () => {
  test('shows details when expanded', () => {
    const providerProps = {
      cardExpandStates: { 'Installed products': true },
      dispatch: () => {},
      registerCard: () => {},
    };
    const { getByText }
      = customRender(<InstalledProductsCard hostDetails={hostDetails} />, { providerProps });

    expect(getByText('Installed products')).toBeInTheDocument();
    expect(getByText('Red Hat Enterprise Linux for x86_64')).toBeInTheDocument();
  });

  test('does not show details when not expanded', () => {
    const providerProps = {
      cardExpandStates: { 'Installed products': false },
      dispatch: () => {},
      registerCard: () => {},
    };
    const { queryByText, getByText }
      = customRender(<InstalledProductsCard hostDetails={hostDetails} />, { providerProps });

    expect(getByText('Installed products')).toBeInTheDocument();
    const element = queryByText((_, e) => e.textContent === 'Red Hat Enterprise Linux for x86_64');
    expect(element).not.toBeInTheDocument();
  });
});
