<?php
/**
 * Plugin Name: Hello World
 * Plugin URI: https://github.com/evlist/wp-plugin-codespace
 * Description: A sample plugin demonstrating WordPress plugin development features including shortcodes, REST API, admin features, and WP-CLI commands.
 * Version: 1.0.0
 * Author: Your Name
 * Author URI: https://github.com/evlist
 * License: GPL-2.0+
 * License URI: http://www.gnu.org/licenses/gpl-2.0.txt
 * Text Domain: hello-world
 */

// If this file is called directly, abort.
if (!defined('WPINC')) {
    die;
}

// Plugin version constant
define('HELLO_WORLD_VERSION', '1.0.0');

/**
 * Plugin activation hook
 */
function hello_world_activate() {
    // Set a transient to show activation notice
    set_transient('hello_world_activated', true, 30);
    
    // Log activation
    error_log('Hello World plugin activated');
}
register_activation_hook(__FILE__, 'hello_world_activate');

/**
 * Plugin deactivation hook
 */
function hello_world_deactivate() {
    // Log deactivation
    error_log('Hello World plugin deactivated');
}
register_deactivation_hook(__FILE__, 'hello_world_deactivate');

/**
 * Register [hello_world] shortcode
 */
function hello_world_shortcode($atts) {
    $atts = shortcode_atts(
        array(
            'name' => 'World',
            'style' => 'default',
        ),
        $atts,
        'hello_world'
    );
    
    $name = esc_html($atts['name']);
    $style = esc_attr($atts['style']);
    
    $output = sprintf(
        '<div class="hello-world-shortcode" data-style="%s"><p>Hello, %s! 👋</p></div>',
        $style,
        $name
    );
    
    return $output;
}
add_shortcode('hello_world', 'hello_world_shortcode');

/**
 * Register REST API endpoint
 * Note: This endpoint is intentionally public (__return_true permission_callback)
 * for demonstration purposes. In production, implement proper authentication.
 */
function hello_world_register_rest_routes() {
    register_rest_route('hello/v1', '/ping', array(
        'methods' => 'GET',
        'callback' => 'hello_world_rest_ping',
        'permission_callback' => '__return_true', // Public endpoint for demo purposes
    ));
}
add_action('rest_api_init', 'hello_world_register_rest_routes');

/**
 * REST API ping endpoint callback
 */
function hello_world_rest_ping($request) {
    return new WP_REST_Response(array(
        'message' => 'Hello World! Plugin is working.',
        'timestamp' => current_time('mysql'),
        'version' => HELLO_WORLD_VERSION,
    ), 200);
}

/**
 * Display admin notice
 */
function hello_world_admin_notice() {
    // Show activation notice
    if (get_transient('hello_world_activated')) {
        echo '<div class="notice notice-success is-dismissible">';
        echo '<p><strong>Hello World plugin activated!</strong> The plugin is ready to use.</p>';
        echo '</div>';
        delete_transient('hello_world_activated');
    }
    
    // Show persistent info notice on plugin pages
    $screen = get_current_screen();
    if ($screen && strpos($screen->id, 'plugins') !== false) {
        echo '<div class="notice notice-info">';
        echo '<p><strong>Hello World:</strong> Use shortcode [hello_world] or visit <code>/wp-json/hello/v1/ping</code> to test the plugin.</p>';
        echo '</div>';
    }
}
add_action('admin_notices', 'hello_world_admin_notice');

/**
 * Add custom node to admin bar
 */
function hello_world_admin_bar_node($wp_admin_bar) {
    if (!current_user_can('manage_options')) {
        return;
    }
    
    $args = array(
        'id'    => 'hello-world',
        'title' => '👋 Hello World',
        'href'  => admin_url('plugins.php'),
        'meta'  => array(
            'class' => 'hello-world-toolbar',
            'title' => 'Hello World Plugin'
        )
    );
    $wp_admin_bar->add_node($args);
    
    // Add submenu item
    $wp_admin_bar->add_node(array(
        'id'     => 'hello-world-test',
        'parent' => 'hello-world',
        'title'  => 'Test REST API',
        'href'   => rest_url('hello/v1/ping'),
        'meta'   => array(
            'target' => '_blank',
        )
    ));
}
add_action('admin_bar_menu', 'hello_world_admin_bar_node', 100);

/**
 * Add footer marker
 */
function hello_world_footer_marker() {
    echo '<!-- Hello World Plugin v' . HELLO_WORLD_VERSION . ' - Active -->';
}
add_action('wp_footer', 'hello_world_footer_marker');
add_action('admin_footer', 'hello_world_footer_marker');

/**
 * Register WP-CLI command
 */
if (defined('WP_CLI') && WP_CLI) {
    /**
     * Hello World WP-CLI command
     */
    class Hello_World_CLI_Command {
        /**
         * Prints a greeting message
         *
         * ## OPTIONS
         *
         * [<name>]
         * : The name to greet
         * ---
         * default: World
         * ---
         *
         * ## EXAMPLES
         *
         *     wp hello-world greet
         *     wp hello-world greet Alice
         *
         * @when after_wp_load
         */
        public function greet($args, $assoc_args) {
            $name = isset($args[0]) ? $args[0] : 'World';
            WP_CLI::success(sprintf('Hello, %s! 👋', $name));
        }
        
        /**
         * Shows plugin status
         *
         * ## EXAMPLES
         *
         *     wp hello-world status
         *
         * @when after_wp_load
         */
        public function status($args, $assoc_args) {
            WP_CLI::line('Hello World Plugin Status:');
            WP_CLI::line('-------------------------');
            WP_CLI::line('Version: ' . HELLO_WORLD_VERSION);
            WP_CLI::line('Status: Active');
            
            // Check if shortcode is registered
            $shortcode_exists = shortcode_exists('hello_world');
            WP_CLI::line(sprintf('Shortcode [hello_world]: %s', $shortcode_exists ? '✓ Registered' : '✗ Not found'));
            
            // Check REST endpoint
            $rest_server = rest_get_server();
            $routes = $rest_server->get_routes();
            $rest_exists = isset($routes['/hello/v1/ping']);
            WP_CLI::line(sprintf('REST endpoint /hello/v1/ping: %s', $rest_exists ? '✓ Registered' : '✗ Not found'));
            
            WP_CLI::success('Plugin is working correctly!');
        }
    }
    
    WP_CLI::add_command('hello-world', 'Hello_World_CLI_Command');
}
