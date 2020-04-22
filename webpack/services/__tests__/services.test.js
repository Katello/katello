import { dateFormatter } from '../../services';

test('can format date correctly', () => {
  const date = "2020-04-17 19:14:47 +0400"
  const timezone = "America/New_York";
  const formatted = dateFormatter(date, timezone)
  const expected = "17 Apr 2020, 19:14:47 GMT+4"
  expect(formatted).toEqual(expected);
});