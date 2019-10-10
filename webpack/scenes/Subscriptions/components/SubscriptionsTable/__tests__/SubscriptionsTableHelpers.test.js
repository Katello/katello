import groupedSubscriptions, { genericRow, subOneRowOne, subOneRowTwo, subTwo, subThree, subFour } from './SubscriptionsTable.fixtures';
import { buildTableRows } from '../SubscriptionsTableHelpers';

describe('Build Table Rows', () => {
  it('should display correct maxQuantity', () => {
    const availableQuantities = {
      1: 50,
      2: 50,
      3: -1,
      4: 100,
      5: 50,
    };

    const rows = [genericRow, subOneRowOne, subOneRowTwo, subTwo, subThree, subFour];

    expect(buildTableRows(groupedSubscriptions, availableQuantities, {}))
      .toEqual(rows);
  });

  it('should update quantities', () => {
    const availableQuantities = {
      1: 50,
      2: 50,
      3: -1,
      4: 100,
      5: 50,
    };

    const updatedQuantities = {
      1: 20,
      4: 150,
    };

    const rows = [genericRow,
      { ...subOneRowOne, entitlementsChanged: true, quantity: 20 },
      subOneRowTwo,
      subTwo,
      { ...subThree, entitlementsChanged: true, quantity: 150 },
      subFour,
    ];

    expect(buildTableRows(groupedSubscriptions, availableQuantities, updatedQuantities))
      .toEqual(rows);
  });
});
