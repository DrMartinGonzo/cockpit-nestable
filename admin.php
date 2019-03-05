<?php

$app->on('admin.init', function () use ($app) {
    $this->helper('admin')->addAssets([
      'assets:lib/uikit/js/components/nestable.min.js',
      'field-nestable:dist/field-nestable-components.js',
      ]);
});
