import React from 'react';
import { shallow } from 'enzyme';
import toJson from 'enzyme-to-json';
import ModuleStreamsPage from '../ModuleStreamsPage';
import ContentPage from '../../../components/Content/ContentPage';

describe('Module streams page', () => {
  it('should render and contain appropiate components', async () => {
    const moduleStreams = {};
    const mockLocation = { search: '' };
    const getModuleStreams = () => {};

    const wrapper = shallow(<ModuleStreamsPage
      moduleStreams={moduleStreams}
      getModuleStreams={getModuleStreams}
      location={mockLocation}
    />);

    expect(toJson(wrapper)).toMatchSnapshot();
    expect(wrapper.find(ContentPage)).toHaveLength(1);
  });
});

