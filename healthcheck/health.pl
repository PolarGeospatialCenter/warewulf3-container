#!/usr/bin/perl
#
# Copyright (c) 2001-2003 Gregory M. Kurtzer
#
# Copyright (c) 2003-2011, The Regents of the University of California,
# through Lawrence Berkeley National Laboratory (subject to receipt of any
# required approvals from the U.S. Dept. of Energy).  All rights reserved.
#


use CGI;
use Sys::Syslog;
use Warewulf::DataStore;
use Warewulf::Node;
use Warewulf::Logger;
use Warewulf::Object;
use Warewulf::ObjectSet;
use Warewulf::Vnfs;
use Warewulf::Provision;

&set_log_level("WARNING");

my $db = Warewulf::DataStore->new();
my $q = CGI->new();

if (! $db) {
    warn("wwprovision: Apache Could not connect to data store!\n");
    openlog("wwprovision", "ndelay,pid", LOG_LOCAL0);
    syslog("ERR", "Could not connect to data store!");
    $q->header( -status => '503 Service Unavailable' );
    closelog;
    exit;
}
