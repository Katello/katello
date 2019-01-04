import React from '@theforeman/vendor/react';
import { mount } from 'enzyme';
import toJson from 'enzyme-to-json';

import RepositoryTypeIcon from '../RepositoryTypeIcon';

describe('RepositoryTypeIcon component', () => {
  const getBaseProps = () => ({
    id: 123,
    type: 'unknown-type',
  });

  describe('rendering', () => {
    test('it should get rendered correctly', () => {
      const component = mount(<RepositoryTypeIcon {...getBaseProps()} />);

      expect(toJson(component)).toMatchSnapshot();
    });

    test('it should get rendered correctly when type is provided', () => {
      const props = getBaseProps();
      props.type = 'yum';
      const component = mount(<RepositoryTypeIcon {...props} />);

      expect(toJson(component)).toMatchSnapshot();
    });
  });
});
