import { baseParams, buildHostSearch } from '../RemoteExecutionActions';

describe('buildHostSearch', () => {
  it('Replaces empty string with special search', () => {
    const options = {
      hostname: 'test',
      hostSearch: '',
    };
    expect(buildHostSearch(options)).toEqual('set? name');
  });
  it('Composes hostname search when hostSearch is not passed', () => {
    const options = {
      hostname: 'test',
    };
    expect(buildHostSearch(options)).toEqual('name ^ (test)');
  });
  it('Composes hostSearch when hostname is not passed', () => {
    const options = {
      hostSearch: 'test',
    };
    expect(buildHostSearch(options)).toEqual('test');
  });
});

describe('baseParams', () => {
  it('Composes base params', () => {
    const options = {
      feature: 'feature',
      hostname: 'hostname',
      hostSearch: 'hostSearch',
      descriptionFormat: 'descriptionFormat',
      inputs: { input: 'input' },
    };
    expect(baseParams(options)).toEqual({
      job_invocation: {
        feature: 'feature',
        inputs: { input: 'input' },
        description_format: 'descriptionFormat',
        search_query: 'hostSearch',
      },
    });
  });
});

