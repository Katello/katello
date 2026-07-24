import quantityValidation from '../upstreamSubscriptionsHelpers';

describe('quantityValidation', () => {
  it('validates correct subscription quantities', () => {
    const validPools = [
      { available: 10, updatedQuantity: 5 },
      { available: 10, updatedQuantity: '5' },
      { available: 10, updatedQuantity: '10' },
      { available: 10, updatedQuantity: '1' },
      { available: -1, updatedQuantity: '1000' },
    ];

    validPools.forEach((pool, i) => {
      const result = quantityValidation(pool)[0];
      expect({ index: i, result }).toEqual({ index: i, result: true });
    });
  });

  it('invalidates incorrect subscription quantities', () => {
    const invalidPools = [
      { available: 10, updatedQuantity: 11 },
      { available: 10, updatedQuantity: 'foo' },
      { available: 10, updatedQuantity: 0 },
      { available: 10, updatedQuantity: '0' },
      { available: 10, updatedQuantity: '11' },
      { available: 10, updatedQuantity: '2.0' },
      { available: 10, updatedQuantity: '2/3' },
      { available: -1, updatedQuantity: '-1' },
      { available: -1, updatedQuantity: '0' },
      { available: -1, updatedQuantity: 'foo' },
      { available: -1, updatedQuantity: '2/3' },
      { available: -1, updatedQuantity: '2.0' },
      { available: -1, updatedQuantity: '99999999999' },
    ];

    invalidPools.forEach((pool, i) => {
      const result = quantityValidation(pool)[0];
      expect({ index: i, result }).toEqual({ index: i, result: false });
    });
  });

  it('returns appropriate error messages', () => {
    expect(quantityValidation({ available: 10, updatedQuantity: 'foo' })[1]).toBe('Please enter digits only');
    expect(quantityValidation({ available: 10, updatedQuantity: '0' })[1]).toBe('Please enter a positive number above zero');
    expect(quantityValidation({ available: 10, updatedQuantity: '11' })[1]).toBe('Quantity must not be above 10');
    expect(quantityValidation({ available: 10, updatedQuantity: '99999999999' })[1]).toBe('Please limit number to 10 digits');
  });
});
