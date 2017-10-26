import React from 'react';
import { configure, mount } from 'enzyme';
import toJson from 'enzyme-to-json';
import Adapter from 'enzyme-adapter-react-16';
import Dashboard from './index';

configure({ adapter: new Adapter() });

describe('Nav component', () => {
  it('renders the navigation', () => {
    const wrapper = mount(<Dashboard />);
    expect(toJson(wrapper)).toMatchSnapshot();
  });
});
