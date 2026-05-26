#!/bin/sh

parallel --ungroup --halt now,done=1 ::: \
    "./start_caddy.sh" \
    "./start_typesense.sh"

false