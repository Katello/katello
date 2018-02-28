import React from 'react';
import { shallow } from 'enzyme';
import toJson from 'enzyme-to-json';

import PaginationRow from '../PaginationRow';

describe('PaginationRow component', () => {
  const getBaseProps = () => ({
    pagination: {
      page: 2,
      perPage: 5,
      perPageOptions: [5, 10, 25],
    },
    itemCount: 52,
    viewType: 'list',
  });

  describe('rendering', () => {
    it('renders correctly', () => {
      const component = shallow(<PaginationRow {...getBaseProps()} />);

      expect(toJson(component)).toMatchSnapshot();
    });
  });
});
