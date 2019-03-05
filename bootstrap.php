<?php

// Force name
if (basename(__DIR__) !== 'field-nestable') {
    rename(__DIR__, dirname(__DIR__).DIRECTORY_SEPARATOR.'field-nestable');

    throw new Exception('Addon directory. Renamed. Please reload.');
}

// ADMIN
if (COCKPIT_ADMIN && !COCKPIT_API_REQUEST) {
    include_once(__DIR__.'/admin.php');
}
