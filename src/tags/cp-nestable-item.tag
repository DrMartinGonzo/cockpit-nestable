<cp-nestable-item>
  <style>
    /* ─────────────┐
       Connectors
    ┌───────────────┘ */
    :scope .uk-nestable-list,
    :scope .uk-nestable-list .uk-nestable-item {
      position: relative;
    }

    :scope .uk-nestable-list:before,
    :scope .uk-nestable-list .uk-nestable-item:before {
      content: '';
      position: absolute;
      z-index: -1;
      border: 0 solid #ddd;
      pointer-events: none;
    }

    /* vertical connector upper part */
    :scope > .uk-nestable-list:before {
      border-left-width: 1px;
      left: 2px;
      top: -6px;
      height: 36px;
    }

    /* horizontal connector + vertical connector bottom part */
    :scope .uk-nestable-list .uk-nestable-item:before {
      border-top-width: 1px;
      border-left-width: 1px;
      top: 30px;
      left: -18px;
      bottom: -40px;
      right: 100%;
      width: 13px;
      margin-right: 4px;
    }

    /* Hide vertical connector bottom part */
    :scope > .uk-nestable-list > .uk-nestable-item:last-child:before {
      border-left-color: transparent !important;
    }

    /* Active connectors color */
    :scope.uk-parent--active > .uk-nestable-list:before,
    :scope.uk-parent--active > .uk-nestable-list > .uk-nestable-item:before {
      border-color: #1abc9c;
    }

    /* ───────────────────────────┐
       Sort mode icon animation
    ┌─────────────────────────────┘ */
    :scope .uk-icon-ellipsis-v:before {
      display: inline-block;
      transform-origin: 100% 50%;
      transition: transform 100ms;
    }

    :scope[mode='sort'] .uk-icon-ellipsis-v:before {
      transform: scaleX(5);
    }

    /* ────────────────────────┐
       Sort mode panel hover
    ┌──────────────────────────┘ */
    :scope[mode='sort'] > .uk-panel-card {
      cursor: move;
      transition: transform 100ms, box-shadow 100ms;
    }

    html:not(.uk-nestable-moving) :scope[mode='sort'] > .uk-panel-card:hover {
      box-shadow: 0 2px 5px 0 rgba(0, 0, 0, 0.22);
      transform: translateY(-1px);
    }

    /* ────────────────────────────┐
       Sort mode item animations
    ┌──────────────────────────────┘ */
    :scope.uk-nestable-item[mode='sort']:not(.uk-nestable-placeholder) {
      animation: lol 200ms ease-out both;
    }

    ul.uk-nestable-dragged :scope.uk-nestable-item[mode='sort'] {
      animation: none;
    }

    :scope ul .uk-nestable-item[mode='sort'] {
      /* animation: lol 300ms both; */
      animation-delay: 75ms;
    }
    :scope ul ul .uk-nestable-item[mode='sort'] {
      animation-delay: 150ms;
    }
    :scope ul ul ul .uk-nestable-item[mode='sort'] {
      animation-delay: 225ms;
    }
    :scope ul ul ul ul .uk-nestable-item[mode='sort'] {
      animation-delay: 300ms;
    }

    /* No delay on drop */
    .uk-parent--active .uk-nestable-item[mode='sort'] {
      animation-delay: 0s !important;
    }

    @keyframes lol {
      0% {
        transform: translate(-2px, -2px);
        opacity: 0.5;
        /* avoid hover animation while playing drop animation */
        pointer-events: none;
      }
    }
  </style>

  <div class="uk-panel-box uk-panel-card" onmouseover="{onmousehover}" onmouseout="{onmousehover}">
    <div class="uk-flex uk-flex-middle">
      <!-- Title -->
      <a
        onclick="{ toggleVisibility }"
        class="uk-badge uk-display-block uk-text-left uk-flex-item-1 {!visibility && opts.mode === 'edit' && 'uk-text-muted'} {!visibility && 'uk-badge-outline'}"
        riot-style="{opts.mode === 'sort' && 'color:currentColor;'}{!visibility && 'border-color: rgba(0,0,0,0)'}"
      >
        <i class="uk-icon-ellipsis-v uk-margin-small-left uk-margin-small-right"></i>
        { App.Utils.ucfirst(typeof(item.field) == 'string' ? item.field : (item.field.label || item.field.type)) }
        {_getDisplay('display')}
      </a>

      <!-- EDIT mode: Toggle entry visibility -->
      <a show="{ opts.mode === 'edit' }" onclick="{ toggleVisibility }" class="uk-margin-left"
        ><i class="uk-icon-eye{ visibility && '-slash uk-text-muted' }"></i
      ></a>

      <!-- EDIT mode: Remove entry -->
      <a show="{ opts.mode === 'edit' }" onclick="{ remove }" class="uk-margin-left"
        ><i class="uk-icon-trash-o uk-text-danger"></i
      ></a>

      <!-- SORT mode: Alt Title -->
      <span show="{ opts.mode === 'sort' }" class="uk-text-muted uk-text-small uk-text-truncate">
        { _getDisplay('display_alt') }
      </span>
    </div>

    <!-- EDIT mode: Field details -->
    <div if="{ visibility }" class="uk-margin">
      <cp-field type="{ item.field.type || 'text' }" bind="item.value" opts="{ item.field.options || {} }"></cp-field>
    </div>
  </div>

  <!-- Nested children -->
  <ul if="{ item.children }" class="uk-nestable-list">
    <li
      each="{ item, idx in item.children }"
      ref="items"
      data-is="cp-nestable-item"
      data-id="item_{ parent.opts.dataId.slice(5) + '-' + idx }"
      mode="{ parent.opts.mode }"
      class="uk-nestable-item"
    ></li>
  </ul>

  <script>
    this.isActiveParent = false;
    this.visibility = this.item.value === null; // no value === we just created it
    this.item.value = this.item.value || {};
    this.remove = this.parent.remove;

    riot.util.bind(this);

    this.on('mount', () => this._toggleRootClasses());
    this.on('update', () => this._toggleRootClasses());

    this.onmousehover = e => {
      e.preventUpdate = true;
      if (document.documentElement.classList.contains('uk-nestable-moving')) return;

      const parentTag = this._getParentTagFromDOM();
      if (parentTag) parentTag.setActive(e.type === 'mouseover');
    };

    this.toggleVisibility = () => {
      if (opts.mode === 'sort') return;
      this.visibility = !this.visibility;
    };

    this.setActive = bool => {
      this.isActiveParent = bool;
      this.update();
    };

    this._getDisplay = type => {
      const item = this.item;
      const rootParent = this._getRootParentTag();
      const defaultValue = this.opts.dataId.replace('_', ' ');

      if (item.field && item.field.type && item.field.options && (rootParent.opts[type] || item.field.options[type])) {
        let value;
        const display = rootParent.opts[type] || item.field.options[type];

        if (item.field.options[type] == '$value') {
          value = item.value;
        } else {
          value = _.get(item.value, display);
        }

        return value ? App.Utils.renderValue(item.field.type, value) : defaultValue;
      }

      return defaultValue;
    };

    // We must rely on dom and not riot nested tags relationships
    // since it may have been changed by UIkit nestable
    this._getParentTagFromDOM = () => {
      const parentEl = this.root.parentElement.parentElement;
      if (parentEl.getAttribute('data-is') === 'cp-nestable-item') return parentEl._tag;
    };

    this._getRootParentTag = () => {
      let n = this;
      while ((n = n.parent)) {
        if (n.root.getAttribute('data-is') == 'field-nestable') break;
      }
      return n;
    };

    this._toggleRootClasses = () => {
      this.root.classList.toggle('uk-parent--active', this.isActiveParent === true);
      this.root.classList.toggle('uk-nestable-nodrag', opts.mode === 'edit');
    };
  </script>
</cp-nestable-item>
