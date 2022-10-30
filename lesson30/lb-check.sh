#!/bin/bash
URL='myloadbalancer-1211606296.eu-central-1.elb.amazonaws.com'
for i in {1..9} ; do
    echo "Attempt $i: $(curl -s ${URL})"
    sleep 1
done
