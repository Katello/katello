// Setup file for enzyme
// See http://airbnb.io/enzyme/docs/installation/react-16.html
import 'babel-polyfill';
import { configure } from 'enzyme';
import Adapter from 'enzyme-adapter-react-16';
import * as Services from './services/api';

configure({ adapter: new Adapter() });

// Mocking translation function
global.__ = text => text; // eslint-disable-line
Services.orgId = () => 1;
