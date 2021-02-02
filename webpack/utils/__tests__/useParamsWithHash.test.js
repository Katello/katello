import paramsFromHash from '../paramsFromHash';

test('can parse both hash and query params', () => {
  const { hash, params: { foo } } = paramsFromHash('#filters?foo=bar');
  expect(hash).toBe('filters');
  expect(foo).toBe('bar');
});

test('can parse just hash', () => {
  const { hash } = paramsFromHash('#filters');
  expect(hash).toBe('filters');
});

test('can parse just query params', () => {
  const { params: { foo } } = paramsFromHash('?foo=bar');
  expect(foo).toBe('bar');
});

test("won't error with blank string", () => {
  const { hash } = paramsFromHash('');
  expect(hash).toBe('');
});
