#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2025, 2026 Eric van der Vlist <vdv@dyomedea.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later OR MIT

# Create a first post
wp post create --post_type=post --post_status=publish \
  --post_title="Hello world!" \
  --post_content="[local_hello_world]" \
  --post_author=1
