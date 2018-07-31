/* eslint-disable */
// Ignore eslint for this entire file because our rules
// don't match patternfly-react's rules
import React from 'react';
import { shallow } from 'enzyme';
import toJson from 'enzyme-to-json';

import { LoadingState } from './index';
jest.useFakeTimers();

test('Loading State renders properly while loading', () => {
  const component = shallow(
    <LoadingState loading loadingText="Loading">
      <p>Loading Complete</p>
    </LoadingState>
  );
    jest.runAllTimers();
    component.update();
    expect(component.state('render')).toEqual(true);
    expect(toJson(component.render())).toMatchSnapshot();
});

test('Loading State renders properly while not loading', () => {
  const component = shallow(
    <LoadingState loading={false} loadingText="Loading">
      <p>Loading Complete</p>
    </LoadingState>
  );
    jest.runAllTimers();
    component.update();
    expect(toJson(component.render())).toMatchSnapshot();
});
