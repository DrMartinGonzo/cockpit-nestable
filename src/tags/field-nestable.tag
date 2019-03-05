<field-nestable>
  <style>
    /* ──────────────────────┐
       Placeholder styling
    ┌────────────────────────┘ */
    :scope .uk-nestable-placeholder:after {
      border-color: #7ed7c4 !important;
      background: #edf6f4;
    }
  </style>

  <!-- Alert: Info -->
  <div class="uk-alert" show="{ !items.length }">
    { App.i18n.get('No items') }.
  </div>

  <ul ref="itemscontainer" class="uk-nestable" show="{ items.length }">
    <li
      each="{ item, idx in items }"
      ref="items"
      data-is="cp-nestable-item"
      data-id="item_{ idx }"
      mode="{ mode }"
      class="uk-nestable-item"
    ></li>
  </ul>

  <!-- ACTIONS -->
  <div class="uk-margin">
    <a class="uk-button" onclick="{ add }" show="{ mode === 'edit' }"
      ><i class="uk-icon-plus-circle"></i> { App.i18n.get('Add item') }</a
    >
    <a class="uk-button uk-button-success" onclick="{ updateorder }" show="{ mode === 'sort' }"
      ><i class="uk-icon-check"></i> { App.i18n.get('Update order') }</a
    >
    <a class="uk-button uk-button-link uk-link-reset" onclick="{ switchmode }" show="{ totalItems > 1 }">
      <span show="{ mode === 'edit' }"><i class="uk-icon-arrows"></i> { App.i18n.get('Reorder') }</span>
      <span show="{ mode === 'sort' }">{ App.i18n.get('Cancel') }</span>
    </a>
  </div>

  <script>
    import { _countItems } from '../utils.js';

    const tag = this;

    this.mode = 'edit';
    this.items = [];
    this.totalItems = 0;
    this.field = { type: 'text' };

    riot.util.bind(this);

    this.on('mount', () => {
      this.field = opts.field || { type: 'text' };
      this.nestable = _initNestable(App.$(this.refs.itemscontainer));
      this.update();
    });

    this.on('update', () => {
      this.totalItems = _countItems(this.items);
    });

    this.$updateValue = (value, field) => {
      if (!Array.isArray(value)) {
        value = [];
      }
      if (JSON.stringify(this.items) !== JSON.stringify(value)) {
        this.items = value;
        this.update();
      }
    };

    this.add = e => {
      if (opts.limit && this.totalItems >= opts.limit) {
        return App.ui.notify('Maximum amount of items reached');
      }

      this.items.push({
        field: this.field,
        value: null,
      });

      this.$setValue(this.items);
    };

    this.remove = e => {
      const itemToRemove = e.item.item;
      let currentKey = 0;
      let found = false;
      let foundKey = 0;
      let foundRoot = this.items;

      // find root and key of item to delete
      function findKeyAndRoot(item) {
        if (item === itemToRemove) {
          foundKey = currentKey;
          found = true;
        }

        if (found) return true; // break Array.some loop

        if (item.children) {
          foundKey = currentKey;
          currentKey = 0;
          foundRoot = item;
          item.children.some(findKeyAndRoot);
        } else {
          foundRoot = tag.items;
          currentKey += 1;
        }
      }

      this.items.some(findKeyAndRoot);

      if (foundRoot.children) {
        foundRoot.children.splice(foundKey, 1);
        if (!foundRoot.children.length) delete foundRoot.children;
      } else {
        foundRoot.splice(foundKey, 1);
      }

      this.update();
    };

    // rebuild this.items from DOM
    this.updateorder = () => {
      function step(node) {
        const item = document.querySelector(`.uk-nestable-item[data-id='${node.id}']`)._tag.item;
        if (node.children) {
          item.children = node.children.map(step);
        } else if (item.children) {
          delete item.children;
        }
        return item;
      }
      const list = this.nestable.serialize().map(step);

      this._forceRenderItemsWith(list);
      this.mode = 'edit';
      this.$setValue(list);
    };

    this.switchmode = e => {
      this.mode = this.mode == 'edit' ? 'sort' : 'edit';
      _collapseAllItems(tag);

      // Force re-rendering list when changing items order and canceling,
      // => items will be reset to their initial position
      if (this.mode == 'edit') {
        this._forceRenderItemsWith(this.items);
      }
    };

    // Force re-rendering list after messing with DOM
    // https://github.com/riot/riot/issues/2112#issuecomment-263275944
    this._forceRenderItemsWith = items_tmp => {
      this.update({ items: [] });
      this.items = items_tmp;
    };

    function _initNestable($container) {
      const nestable = UIkit.nestable($container, {});

      let prevDragElParentTag;
      let currentDragElParentTag;

      $container.on('move.uk.nestable', () => {
        // find placeholder's parent...
        const currentDragElParentTag = nestable.placeEl[0]._tag._getParentTagFromDOM();

        // ...and apply active parent class to it + remove active parent class it from previous parent
        if (prevDragElParentTag) prevDragElParentTag.setActive(false);
        if (currentDragElParentTag) {
          currentDragElParentTag.setActive(true);
          prevDragElParentTag = currentDragElParentTag;
        }
      });

      return nestable;
    }

    function _collapseAllItems(rootComponent) {
      App.$(rootComponent.refs.items).each((index, item) => {
        item.visibility = false;
        _collapseAllItems(item);
      });
    }
  </script>
</field-nestable>
