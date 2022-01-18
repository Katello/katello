import React from 'react';
import { shallow } from 'enzyme';
import toJson from 'enzyme-to-json';
import { Table } from 'react-bootstrap';
import ContentDetailInfo from '../ContentDetailInfo';

describe('Content Details Info', () => {
  it('should render and contain appropriate components', async () => {
    const displayMap = new Map([
      ['dummy_name', 'Name'],
      ['dummy_details_field', 'Details Field'],
    ]);
    const detailInfo = {
      dummy_name: 'dummy name',
      dummy_details_field: 'dummy details',
    };

    const wrapper = shallow(<ContentDetailInfo
      contentDetails={detailInfo}
      displayMap={displayMap}
    />);

    expect(toJson(wrapper)).toMatchSnapshot();
    expect(wrapper.find(Table)).toHaveLength(1);
  });
});
