import React from 'react';
import { shallow } from 'enzyme';
import toJson from 'enzyme-to-json';
import * as hooks from 'foremanReact/components/PF4/TableIndexPage/Table/TableHooks';
import ModuleStreamsPage from '../ModuleStreamsPage';
import GenericContentPage from '../../../components/Content/GenericContentPage';

describe('Module streams page', () => {
  it('should render and contain appropiate components', async () => {
    const moduleStreams = {};
    jest.spyOn(hooks, 'useUrlParams').mockImplementation(() => ({
      searchParam: '',
    }));
    const getModuleStreams = () => {};

    const wrapper = shallow(<ModuleStreamsPage
      moduleStreams={moduleStreams}
      getModuleStreams={getModuleStreams}
    />);

    expect(toJson(wrapper)).toMatchSnapshot();
    expect(wrapper.find(GenericContentPage)).toHaveLength(1);
  });
});

