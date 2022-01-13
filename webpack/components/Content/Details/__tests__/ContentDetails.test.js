import React from 'react';
import { shallow } from 'enzyme';
import toJson from 'enzyme-to-json';
// import { testComponentSnapshotsWithFixtures } from 'react-redux-test-utils';
import ContentDetailInfo from '../ContentDetailInfo';
import ContentDetailRepositories from '../ContentDetailRepositories';
import ContentDetails from '../ContentDetails';

describe('Content Details Info', () => {
  it('should render and contain appropriate components', async () => {
    const detail = {
      loading: true,
      name: 'dummy name',
    };

    const detailInfo = {
      dummy_name: 'dummy name',
      dummy_details_field: 'dummy details',
    };

    const displayMap = new Map([
      ['dummy_name', 'Name'],
      ['dummy_details_field', 'Details Field'],
    ]);

    const repositories = [
      {
        id: 155,
        name: 'dummy_name',
        product_id: 1,
        product_name: 'dummy_product',
      },
    ];

    const schema = [
      {
        key: 1,
        tabHeader: 'Details',
        tabContent: (
          <ContentDetailInfo contentDetails={detailInfo} displayMap={displayMap} />
        ),
      },
      {
        key: 2,
        tabHeader: 'Repositories',
        tabContent: (repositories && repositories.length ?
          <ContentDetailRepositories repositories={repositories} /> :
          'No repositories to show'
        ),
      },
    ];

    const wrapper = shallow(<ContentDetails
      contentDetails={detail}
      schema={schema}
    />);

    expect(toJson(wrapper)).toMatchSnapshot();
    expect(wrapper.find(ContentDetailInfo)).toHaveLength(1);
    expect(wrapper.find(ContentDetailRepositories)).toHaveLength(1);
  });
});
