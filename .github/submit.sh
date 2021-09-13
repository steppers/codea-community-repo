#!/bin/bash

sub_name=$(echo $1 | jq -R '.[]')

echo Processing ${sub_name}...