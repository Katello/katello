import React from 'react';
import { mount } from 'enzyme';
import toJson from 'enzyme-to-json';
import Dashboard from './index';

describe('Nav component', () => {
  it('renders the navigation', () => {
    const wrapper = mount(<Dashboard />);
    expect(toJson(wrapper)).toMatchSnapshot();
  });
});
