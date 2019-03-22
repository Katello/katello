
export const services = {
  candlepin: { status: 'ok', message: 'a message' },
  candlepin_auth: { status: 'error', message: 'error message' },
  foreman_tasks: { status: 'ok' },
  pulp: { status: 'ok' },
  pulp_auth: { status: 'ok' },
};

export const withServices = {
  status: 'RESOLVED',
  services,
  getSystemStatuses: jest.fn(),
};

export const pending = {
  status: 'PENDING',
  services: {},
  getSystemStatuses: jest.fn(),
};
