# Local Hello World Plugin

A sample WordPress plugin demonstrating various WordPress development features.

## Features

This plugin demonstrates the following WordPress functionality:

### 1. Shortcode
- **Usage**: `[local_hello_world]` or `[local_hello_world name="Developer"]`
- **Description**: Displays a customizable local hello world message with styling
- **Parameters**:
  - `name` (optional): The name to display in the greeting (default: "World")
  - `class` (optional): Custom CSS class for the message container

### 2. REST API Endpoint
- **Endpoint**: `/wp-json/hello/v1/ping`
- **Method**: GET
- **Parameters**:
  - `name` (optional): The name to include in the response
- **Response**: JSON object with success status, message, and timestamp

### 3. Admin Notice
- Displays a success notice on the WordPress dashboard
- Shows when the plugin was activated

### 4. Admin Bar Node
- Adds a "👋 Local Hello World" node to the WordPress admin bar (for administrators)
- Includes a submenu item to test the REST API endpoint

### 5. Footer Marker
- Adds an HTML comment to both frontend and admin footers
- Useful for confirming the plugin is active

### 6. WP-CLI Commands
Custom WP-CLI commands for testing and plugin interaction:

```bash
# Greet command
.devcontainer/bin/wp.sh local-hello-world greet
.devcontainer/bin/wp.sh local-hello-world greet "Developer"

# Info command - shows plugin information
.devcontainer/bin/wp.sh local-hello-world info

# Test API command - tests the REST API endpoint
.devcontainer/bin/wp.sh local-hello-world test-api
.devcontainer/bin/wp.sh local-hello-world test-api --name="Developer"
```

### 7. Activation/Deactivation Hooks
- Stores activation timestamp in options table
- Flushes rewrite rules on activation and deactivation
- Cleans up options on deactivation

## Validation Steps

### Test the Shortcode
1. Create a new post or page in WordPress
2. Add the shortcode: `[local_hello_world]` or `[local_hello_world name="YourName"]`
3. View the post/page to see the styled message

### Test the REST API
1. Open your browser to: `http://localhost:8080/wp-json/hello/v1/ping`
2. You should see a JSON response like:
   ```json
   {
     "success": true,
     "message": "Hello, World!",
     "timestamp": "2025-01-01 12:00:00"
   }
   ```
3. Test with a parameter: `http://localhost:8080/wp-json/hello/v1/ping?name=Developer`

### Test Admin Features
1. Log in to WordPress admin (`http://localhost:8080/wp-admin`)
2. Go to the Dashboard to see the admin notice
3. Look at the admin bar (top of the screen) for the "👋 Local Hello World" item

### Test WP-CLI Commands
From the codespace terminal:

```bash
# Test the greet command
.devcontainer/bin/wp.sh local-hello-world greet "Developer"

# Get plugin information
.devcontainer/bin/wp.sh local-hello-world info

# Test the REST API via CLI
.devcontainer/bin/wp.sh local-hello-world test-api --name="CLI Test"
```

### Test Footer Marker
1. View the page source of any frontend page or admin page
2. Look for the HTML comment: `<!-- Local Hello World Plugin Active (v1.0.0) -->`

## Development Notes

- The plugin follows WordPress coding standards
- All user input is properly sanitized and escaped
- The plugin is fully documented with PHPDoc comments
- REST API endpoint uses proper permission callbacks
- WP-CLI commands include help documentation

## License

GPL-2.0+
