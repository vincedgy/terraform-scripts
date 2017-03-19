#!/bin/bash
aws ec2 describe-network-interfaces --query 'NetworkInterfaces[].[Status, AvailabilityZone, Association.PublicIp]' --filters "Name=description,Values=ELB webinfra-ELB" --output text | sort