import React from 'react';
import { shallow } from 'enzyme';
import toJson from 'enzyme-to-json';
import configureMockStore from 'redux-mock-store';

import RedHatRepositoriesPage from './index';

const mockStore = configureMockStore([]);
const store = mockStore({});

describe('<RedHatRepositoriesPage />', () => {
  it('should match snapshot', () => {
    const wrapper = shallow(<RedHatRepositoriesPage store={store} />);

    expect(toJson(wrapper)).toMatchSnapshot();
  });
});
