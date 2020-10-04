#!/bin/bash

# MIT License
#
# Copyright (c) 2016 Roman Lebedev
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

set -e

AUTHORS="$1"
H_FILE="$2"

echo "#pragma once" > "$H_FILE"
echo "" >> "$H_FILE"

# category counter
SECTIONS=0

print_section() {
	# only add if non empty
	if [ -n "${CONTENT}" ]; then
		echo "static const char *section${SECTIONS}[] = {" >> "$H_FILE"
		echo "$CONTENT" >> "$H_FILE"
		echo "  NULL };" >> "$H_FILE"
	  	echo "gtk_about_dialog_add_credit_section (GTK_ABOUT_DIALOG(dialog), \"${SECTION}\", section${SECTIONS});" >> "$H_FILE"
	    echo "" >> "$H_FILE"
    fi
}

# extract section name
section="\* (.*):"

while IFS="" read -r p || [ -n "$p" ]
do
  if [[ $p =~ $section ]]; then
  	if [ $SECTIONS -gt 0 ]; then
  		print_section
  	fi

  	SECTIONS=$((SECTIONS+1))
  	# only select short name
  	SECTION=$(echo "${BASH_REMATCH[1]}" | sed 's/Sub-module //' | sed 's/ (.*)//')
  	CONTENT=""
  else
  	# general thanks for previous contributors are hardcoded
  	if [ "$p" = "" ] || [ "${p:0:13}" = "And all those" ]; then
  		continue
  	fi
  	CONTENT="\"$p\",$CONTENT"
  fi
done < "$AUTHORS"

print_section

# vim: tabstop=2 expandtab shiftwidth=2 softtabstop=2
# kate: tab-width: 2; replace-tabs on; indent-width 2; tab-indents: off;
# kate: indent-mode sh; remove-trailing-spaces modified;
