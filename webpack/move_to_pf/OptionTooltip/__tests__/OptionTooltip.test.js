import OptionTooltip from '../';
import { testComponentSnapshotsWithFixtures } from '../../test-utils/testHelpers';

const onClose = () => {};
const options = [
  {
    key: 'option1',
    value: true,
    label: 'One',
  },
  {
    key: 'option2',
    value: false,
    label: 'Two',
  },
];

const fixtures = {
  'renders ': {
    icon: 'test',
    id: 'test',
    options: [],
    onClose,
  },
  'renders a list of options with default values ': {
    icon: 'test',
    id: 'test',
    options,
    onClose,
  },
};
describe('OptionTooltip', () => testComponentSnapshotsWithFixtures(OptionTooltip, fixtures));
