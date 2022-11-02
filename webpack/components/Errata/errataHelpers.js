export const errataStatusContemplation = (errataStatus) => {
  // from backend errata_status.rb:
  // NEEDED_SECURITY_ERRATA = 3
  // NEEDED_ERRATA = 2
  // UNKNOWN = 1
  // UP_TO_DATE = 0
  const neededErrata = ([2, 3].includes(Number(errataStatus)));
  const allUpToDate = (errataStatus === 0);
  const otherErrataStatus = (!allUpToDate && !neededErrata);

  return {
    neededErrata,
    allUpToDate,
    otherErrataStatus,
  };
};

export const friendlyErrataStatus = (errataStatus) => {
  switch (errataStatus) {
  case 0:
    return 'All up to date';
  case 1:
    return 'Unknown';
  // eslint-disable-next-line no-sequences
  case 2:
  case 3:
    return 'Needed';
  default:
    return 'Unknown';
  }
};

export default errataStatusContemplation;
