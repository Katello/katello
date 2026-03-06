import Immutable from 'seamless-immutable';

const groupedSubscriptions = Immutable({
  RH00001: {
    open: true,
    subscriptions: [
      {
        id: 1,
        name: 'Alpha',
        quantity: 10,
        product_id: 'RH00001',
      },
      {
        id: 2,
        name: 'Alpha',
        quantity: 15,
        product_id: 'RH00001',
      },
    ],
  },
  RH00002: {
    open: false,
    subscriptions: [
      {
        id: 3,
        name: 'Charlie',
        quantity: 10,
        product_id: 'RH00002',
      },
    ],
  },
  RH00003: {
    open: false,
    subscriptions: [
      {
        id: 4,
        name: 'Bravo',
        quantity: 100,
        product_id: 'RH00003',
      },
    ],
  },
  RH00004: {
    open: false,
    subscriptions: [
      {
        id: 5,
        name: 'Delta',
        quantity: 15,
        product_id: 'RH00004',
      },
    ],
  },
});

export const genericRow = Immutable({
  collapsible: true,
  contract_number: 'NA',
  end_date: 'NA',
  hypervisor: undefined,
  id: 'RH00001',
  name: 'Alpha',
  product_id: 'RH00001',
  start_date: 'NA',
  virt_only: undefined,
  product_host_count: 'NA',
});

export const subOneRowOne = Immutable({
  id: 1,
  maxQuantity: 60,
  name: 'Alpha',
  product_id: 'RH00001',
  quantity: 10,
  upstreamAvailable: 50,
  upstreamAvailableLoaded: true,
});

export const subOneRowTwo = Immutable({
  id: 2,
  maxQuantity: 65,
  name: 'Alpha',
  product_id: 'RH00001',
  quantity: 15,
  upstreamAvailable: 50,
  upstreamAvailableLoaded: true,
});

export const subTwo = Immutable({
  id: 3,
  maxQuantity: -1,
  name: 'Charlie',
  product_id: 'RH00002',
  quantity: 10,
  upstreamAvailable: -1,
  upstreamAvailableLoaded: true,
});

export const subThree = Immutable({
  id: 4,
  maxQuantity: 200,
  name: 'Bravo',
  product_id: 'RH00003',
  quantity: 100,
  upstreamAvailable: 100,
  upstreamAvailableLoaded: true,
});

export const subFour = Immutable({
  id: 5,
  maxQuantity: 65,
  name: 'Delta',
  product_id: 'RH00004',
  quantity: 15,
  upstreamAvailable: 50,
  upstreamAvailableLoaded: true,
});

export default groupedSubscriptions;

