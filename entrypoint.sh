#!/bin/sh

echo $HOME
ls -l /dbtproject
ls -l $HOME/.dbt
cd /dbtproject
dbt build