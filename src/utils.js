export function _countItems(items) {
  let count = 0;
  function r(item) {
    count += 1;
    if (item.children) item.children.forEach(r);
  }
  items.forEach(r);
  return count;
}
