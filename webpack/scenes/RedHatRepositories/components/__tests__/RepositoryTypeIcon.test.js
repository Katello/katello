import React from 'react';
import { shallow } from 'enzyme';
import toJson from 'enzyme-to-json';

import RepositoryTypeIcon from '../RepositoryTypeIcon';

describe('RepositoryTypeIcon component', () => {
  const getBaseProps = () => ({
    id: 123,
    type: 'unknown-type',
  });

  describe('rendering', () => {
    test('it should get rendered correctly', () => {
      const component = shallow(<RepositoryTypeIcon {...getBaseProps()} />);

      expect(toJson(component)).toMatchSnapshot();
    });

    test('it should get rendered correctly when type is provided', () => {
      const props = getBaseProps();
      props.type = 'yum';
      const component = shallow(<RepositoryTypeIcon {...props} />);

      expect(toJson(component)).toMatchSnapshot();
    });
  });
});
