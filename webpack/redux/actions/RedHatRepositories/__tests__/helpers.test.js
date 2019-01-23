import { getArchFromPath } from '../helpers.js';

describe('getArchFromPath', () => {
  it('should return arch from path', () => {
    const arch = getArchFromPath('/this/has/x86_64/as/arch');
    expect(arch).toBe('x86_64');
  });

  it('should return falsey value for no arch', () => {
    const arch = getArchFromPath('/hello/there/');
    expect(arch).toBeFalsy();
  });
});
