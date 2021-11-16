import moment from 'moment';

// Example: "2021-11-08 12:01:23 -0700" => November 08, 2021, 12:01 PM
export const makeReadableDate = dateString =>
  moment(dateString, 'YYYY-MM-DD hh:mm:ss Z').format('MMMM DD, YYYY, h:mm A');

export default { makeReadableDate };
