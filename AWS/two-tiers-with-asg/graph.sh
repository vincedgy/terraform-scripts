#!/bin/bash
terraform graph | dot -Tjpg > graph.jpg; open graph.jpg
