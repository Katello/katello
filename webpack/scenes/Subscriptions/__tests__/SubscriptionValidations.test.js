import { validateQuantity, recordsValid } from '../SubscriptionValidations';

describe('validateQuantity', () => {
  const validResult = {
    state: undefined,
    message: undefined,
  };
  const validationError = message => ({
    state: 'error',
    message,
  });

  it('accepts a number', () => {
    expect(validateQuantity('123', 500))
      .toEqual(validResult);
  });

  it('accepts a string number', () => {
    expect(validateQuantity(123, 500))
      .toEqual(validResult);
  });

  it('detects not a number', () => {
    expect(validateQuantity('123abc', 500))
      .toEqual(validationError('Not a number'));
  });

  it('detects negative number', () => {
    expect(validateQuantity('-1', 500))
      .toEqual(validationError('Has to be > 0'));
  });

  it('detects zero', () => {
    expect(validateQuantity('0', 500))
      .toEqual(validationError('Has to be > 0'));
  });

  it('detects too big quantity', () => {
    expect(validateQuantity('501', 500))
      .toEqual(validationError('Exceeds available quantity'));
  });

  it('skips quantity detection', () => {
    expect(validateQuantity(100))
      .toEqual(validResult);
  });

  it('detects unlimited maxQuantity', () => {
    expect(validateQuantity('500000', -1))
      .toEqual(validResult);
  });
});

describe('recordsValid', () => {
  it('accepts empty array', () => {
    expect(recordsValid([])).toBe(true);
  });

  /* eslint-disable object-curly-newline */
  it('accepts valid array', () => {
    const rows = [
      { quantity: 10, available: 10, upstreamAvailable: 100, upstream_pool_id: ' ' },
      { quantity: 10, available: 10, upstreamAvailable: -1 },
      { quantity: -1, available: -1 },
      { quantity: 10, available: 10, upstream_pool_id: ' ' },
    ];
    expect(recordsValid(rows)).toBe(true);
  });
  /* eslint-enable object-curly-newline */

  it('detects invalid record', () => {
    /* eslint-disable object-curly-newline */
    const rows = [
      { quantity: 10, available: 10, upstreamAvailable: 100, maxQuantity: 100, upstream_pool_id: ' ' },
      { quantity: 10, available: 10, upstreamAvailable: 0, maxQuantity: 5, upstream_pool_id: ' ' },
    ];
    /* eslint-enable object-curly-newline */
    expect(recordsValid(rows)).toBe(false);
  });
});
