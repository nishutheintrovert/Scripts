#!/bin/bash

rm -rf '/c/$RECYCLE.BIN'
rm -rf '/d/$RECYCLE.BIN'
history -c && history -w
