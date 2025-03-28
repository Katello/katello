import React from 'react';
import { renderWithRedux } from 'react-testing-lib-wrapper';
import { CardExpansionContext } from 'foremanReact/components/HostDetails/CardExpansionContext';
import HwPropertiesCard from '../HwPropertiesCard';

const hostDetails = {
  subscription_facet_attributes: {
    uuid: '1234567',
    facts: {
      'memory::memtotal': '24346164',
      'cpu::core(s)_per_socket': '1',
      'cpu::cpu(s)': '6',
      'cpu::cpu_socket(s)': '6',
      'virt::host_type': 'redhat, kvm',
    },
  },
};
const customRender = (ui, { providerProps, ...renderOptions }) => renderWithRedux(
  <CardExpansionContext.Provider value={providerProps}>{ui}</CardExpansionContext.Provider>,
  renderOptions,
);

describe('HwPropertiesCard', () => {
  test('shows details when expanded', () => {
    const providerProps = {
      cardExpandStates: { 'HW properties': true },
      dispatch: () => {},
      registerCard: () => {},
    };
    const { getByText }
      = customRender(<HwPropertiesCard hostDetails={hostDetails} />, { providerProps });

    expect(getByText('HW properties')).toBeInTheDocument();
    expect(getByText('Model')).toBeInTheDocument();
  });

  test('does not show card when host is not registered', () => {
    const providerProps = {
      cardExpandStates: { 'HW properties': true },
      dispatch: () => {},
      registerCard: () => {},
    };
    const { queryByText }
      = customRender(<HwPropertiesCard hostDetails={{ name: 'not-registered' }} />, { providerProps });

    const element = queryByText((_, e) => e.textContent === 'HW properties');
    expect(element).not.toBeInTheDocument();
  });

  test('does not show details when not expanded', () => {
    const providerProps = {
      cardExpandStates: { 'HW properties': false },
      dispatch: () => {},
      registerCard: () => {},
    };
    const { queryByText, getByText }
      = customRender(<HwPropertiesCard hostDetails={hostDetails} />, { providerProps });

    expect(getByText('HW properties')).toBeInTheDocument();
    const element = queryByText((_, e) => e.textContent === 'Model');
    expect(element).not.toBeInTheDocument();
  });
});
