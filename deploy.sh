#!/bin/sh
puppet module build . && cp -rfv pkg/elsonrodriguez-jira-0.0.1/* ~/git/puppet-sandbox/modules/atlassian/
echo Done!