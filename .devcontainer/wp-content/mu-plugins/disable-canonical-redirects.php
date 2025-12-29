<?php
/**
 * Dev-only: disable WordPress canonical redirects to avoid "-443" hops in Codespaces.
 */

add_filter('redirect_canonical', '__return_false', 100);