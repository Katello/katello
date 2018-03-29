import React from 'react';
import { shallow } from 'enzyme';
import toJson from 'enzyme-to-json';

import Search from '../Search';

describe('Search component', () => {
  const getBaseProps = () => ({
    onSearch: () => {},
    getAutoCompleteParams: () => ({}),
  });

  describe('rendering', () => {
    it('renders correctly', () => {
      const component = shallow(<Search {...getBaseProps()} />);

      expect(toJson(component)).toMatchSnapshot();
    });
  });
});
