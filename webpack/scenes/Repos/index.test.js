import React from 'react';
import { configure } from 'enzyme';
import { shallow } from 'enzyme';

import Adapter from 'enzyme-adapter-react-16';

import { Grid, Row, Col, Form, FormGroup } from 'react-bootstrap';

import RedHatRepositoriesPage from './index';
import MultiSelect from '../../components/MultiSelect/index';
import SearchInput from '../../components/SearchInput/index';

configure({ adapter: new Adapter() });
global.__ = () => true

describe('<RedHatRepositoriesPage />', () => {
  it('should show a <Grid>', () => {
    const wrapper = shallow(<RedHatRepositoriesPage />);

    expect(wrapper.find(Grid).length).toBe(1);
  });

  it('should have three <Row>s', () => {
    const wrapper = shallow(<RedHatRepositoriesPage />);

    expect(wrapper.find(Row).length).toBe(3);
  });

  it('should contain a <SearchInput/>', () => {
    const wrapper = shallow(<RedHatRepositoriesPage />);

    expect(wrapper.find(SearchInput).length).toBe(1);
  });

  it('should contain a <MultiSelect/>', () => {
    const wrapper = shallow(<RedHatRepositoriesPage />);

    expect(wrapper.find(MultiSelect).length).toBe(1);
  });
});
