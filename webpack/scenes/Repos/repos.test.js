import React from 'react';
import { configure, mount } from 'enzyme';
import toJson from 'enzyme-to-json';
import Adapter from 'enzyme-adapter-react-16';
import Repos from './index';

configure({ adapter: new Adapter() });

describe('Nav component', () => {
  it('renders the navigation', () => {
    const wrapper = mount(<Repos />);
    expect(toJson(wrapper)).toMatchSnapshot();
  });
});
