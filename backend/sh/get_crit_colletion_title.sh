#!/bin/sh
curl $1 | grep "top_ten_number" | awk -F 'class="top_ten_number">' {'print $2'} | awk -F '</a>' {'print $1'}