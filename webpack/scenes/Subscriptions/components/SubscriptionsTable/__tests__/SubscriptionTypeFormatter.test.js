import { shallow } from 'enzyme';
import toJson from 'enzyme-to-json';
import { subscriptionTypeFormatter } from '../SubscriptionTypeFormatter';

describe('subscriptionTypeFormatter', () => {
  const data = rowData => ({
    rowData,
  });

  it('renders physical subscriptions', async () => {
    const formatter = subscriptionTypeFormatter(null, data({ virt_only: false }));

    expect(toJson(shallow(formatter))).toMatchSnapshot();
  });

  it('renders temporary subscriptions', async () => {
    const formatter = subscriptionTypeFormatter(null, data({ unmapped_guest: true }));

    expect(toJson(shallow(formatter))).toMatchSnapshot();
  });

  it('renders virtual subscriptions', async () => {
    const formatter = subscriptionTypeFormatter(null, data({}));

    expect(toJson(shallow(formatter))).toMatchSnapshot();
  });

  it('renders link to a host', async () => {
    const formatter = subscriptionTypeFormatter(null, data({ hypervisor: { name: 'host.example.com', id: 83 } }));

    expect(toJson(shallow(formatter))).toMatchSnapshot();
  });
});
