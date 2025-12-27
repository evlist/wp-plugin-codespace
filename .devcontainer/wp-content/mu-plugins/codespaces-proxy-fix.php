<?php
/**
 * Force WordPress to honor the external host and HTTPS behind the Codespaces proxy,
 * and disable canonical redirects that can swap the domain to "-443".
 */

// Normalize runtime server vars from WP_HOME early.
add_action('init', function () {
    if (defined('WP_HOME') && WP_HOME) {
        $u = parse_url(WP_HOME);
        if (!empty($u['host'])) {
            $_SERVER['HTTP_HOST']   = $u['host'];
            $_SERVER['SERVER_NAME'] = $u['host'];
        }
        if (!empty($u['scheme']) && $u['scheme'] === 'https') {
            $_SERVER['HTTPS'] = 'on';
        }
    }
    // Also respect the proxy header if present
    if (!empty($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {
        $_SERVER['HTTPS'] = 'on';
    }
}, 1);

// Disable canonical redirects in dev (prevents 301 to "-443").
add_filter('redirect_canonical', '__return_false', 100);