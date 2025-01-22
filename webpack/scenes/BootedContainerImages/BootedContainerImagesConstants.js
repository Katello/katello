import { foremanApi } from '../../services/api';

const BOOTED_CONTAINER_IMAGES_KEY = 'BOOTED_CONTAINER_IMAGES';
export const BOOTED_CONTAINER_IMAGES_API_PATH = foremanApi.getApiUrl('/hosts/bootc_images');
export default BOOTED_CONTAINER_IMAGES_KEY;
