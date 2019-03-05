import { _countItems } from './utils.js';

App.Utils.renderer.nestable = function(v) {
  const cnt = Array.isArray(v) ? _countItems(v) : 0;
  return '<span class="uk-badge">' + (cnt + (cnt == 1 ? ' Item' : ' Items')) + '</span>';
};
