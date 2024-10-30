import Immutable from 'seamless-immutable';
import { toastErrorAction, failureAction } from '../../../../services/api/testHelpers';

export const initialState = Immutable({
  loading: false,
  productContent: {
    results: [],
    total: 0,
  },
});


export const loadingState = Immutable({
  ...initialState,
  loading: true,
});

export const emptyState = Immutable({
  ...loadingState,
});


export const subDetails = Immutable({
  error: null,
  arch: 'ia64,ppc,ppc64,ppc64le,s390,s390x,x86,x86_64',
  description: 'OpenShift Enterprise',
  support_type: 'L1-L3',
  roles: 'Test Role',
  usage: ' Development',
  id: 48,
  cp_id: '4028f92a6317cfbd0163b419377f3bee',
  subscription_id: 3,
  name: 'OpenShift Employee Subscription',
  start_date: '2013-03-01 00:00:00 -0500',
  end_date: '2021-12-31 23:59:59 -0500',
  available: 1,
  quantity: 1,
  consumed: 0,
  account_number: 1212729,
  contract_number: 10126160,
  support_level: 'Self-Support',
  product_id: 'SER0421',
  sockets: null,
  cores: 4,
  ram: null,
  instance_multiplier: 1,
  stacking_id: 'SER0421',
  multi_entitlement: true,
  type: 'NORMAL',
  product_name: 'OpenShift Employee Subscription',
  unmapped_guest: false,
  virt_only: false,
  virt_who: false,
  upstream: true,
  host_count: 0,
  provided_products: [
    {
      id: 1,
      name: 'Red Hat OpenShift Container Platform',
    },
    {
      id: 2,
      name: 'Oracle Java for RHEL Server',
    },
    {
      id: 3,
      name: 'Red Hat OpenShift Enterprise JBoss EAP add-on',
    },
    {
      id: 4,
      name: 'Red Hat CloudForms Beta',
    },
    {
      id: 5,
      name: 'Red Hat CloudForms',
    },
    {
      id: 6,
      name: 'Red Hat OpenShift Enterprise Client Tools',
    },
    {
      id: 7,
      name: 'Red Hat Enterprise Linux Atomic Host',
    },
    {
      id: 8,
      name: 'JBoss Enterprise Application Platform',
    },
    {
      id: 9,
      name: 'Red Hat JBoss AMQ Clients',
    },
    {
      id: 10,
      name: 'Red Hat Beta',
    },
    {
      id: 11,
      name: 'Red Hat OpenShift Enterprise Infrastructure',
    },
    {
      id: 12,
      name: 'Red Hat Enterprise Linux Fast Datapath Beta',
    },
    {
      id: 13,
      name: 'Red Hat Ansible Engine',
    },
    {
      id: 14,
      name: 'Red Hat OpenShift Enterprise Application Node',
    },
    {
      id: 15,
      name: 'Red Hat OpenShift Enterprise JBoss FUSE add-on',
    },
    {
      id: 16,
      name: 'Red Hat Software Collections Beta for RHEL Server',
    },
    {
      id: 17,
      name: 'Red Hat Software Collections for RHEL Server',
    },
    {
      id: 18,
      name: 'Red Hat Enterprise Linux Fast Datapath',
    },
    {
      id: 19,
      name: 'Red Hat Enterprise Linux Server',
    },
    {
      id: 20,
      name: 'Red Hat OpenShift Enterprise JBoss A-MQ add-on',
    },
    {
      id: 21,
      name: 'JBoss Enterprise Web Server',
    },
    {
      id: 22,
      name: 'Red Hat JBoss Core Services',
    },
  ],
  activation_keys: [],
});

export const successState = {
  ...initialState,
  ...subDetails,
};

export const loadSubscriptionsDetailsFailureActions = [
  {
    type: 'SUBSCRIPTION_DETAILS_REQUEST',
  },
  failureAction('SUBSCRIPTION_DETAILS_FAILURE', 'Request failed with status code 500'),
  toastErrorAction('Request failed with status code 500'),
];

export const loadSubscriptionsDetailsSuccessActions = [
  {
    type: 'SUBSCRIPTION_DETAILS_REQUEST',
  },
  {
    type: 'SUBSCRIPTION_DETAILS_SUCCESS',
    response: subDetails,
  },
];

export default subDetails;
