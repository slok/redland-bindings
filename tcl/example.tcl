#
# Example code for Redland Tcl interface
#
# $Id$
#
# Copyright (C) 2000-2001 David Beckett - http://purl.org/net/dajobe/
# Institute for Learning and Research Technology - http://www.ilrt.org/
# University of Bristol - http://www.bristol.ac.uk/
# 
# This package is Free Software or Open Source available under the
# following licenses (these are alternatives):
#   1. GNU Lesser General Public License (LGPL)
#   2. GNU General Public License (GPL)
#   3. Mozilla Public License (MPL)
# 
# See LICENSE.html or LICENSE.txt at the top of this package for the
# full license terms.
# 
# 
#


lappend auto_path .

package require redland


set uri_string [lindex $argv 0]

set parser [lindex $argv 1]



librdf_init_world "" NULL

set storage [librdf_new_storage "hashes" "test" {new='yes',hash-type='bdb',dir='.'}]
if {"$storage" == "NULL"} then {
  error "Failed to create RDF storage"
}

set model [librdf_new_model $storage ""]
if {"$model" == "NULL"} then {
  librdf_free_storage $storage
  error "Failed to create RDF model"
}

set parser [librdf_new_parser $parser "" NULL]
if {"$parser" == "NULL"} then {
  librdf_free_model $model
  librdf_free_storage $storage
  error "Failed to create RDF parser"
}


set uri [librdf_new_uri $uri_string]

set stream [librdf_parser_parse_as_stream $parser $uri $uri]

set count 0
while {! [librdf_stream_end $stream]} {
  set statement [librdf_stream_next $stream]
  librdf_model_add_statement $model $statement
  puts [concat "found statement:" [librdf_statement_to_string $statement]]
  incr count
}
librdf_free_stream $stream

puts "Parsing added $count statements"

librdf_free_parser $parser


puts "Printing all statements"
set stream [librdf_model_serialise $model]
while {! [librdf_stream_end $stream]} {
  set statement [librdf_stream_next $stream]
  puts [concat "Statement:" [librdf_statement_to_string $statement]]
}
librdf_free_stream $stream


librdf_free_model $model
librdf_free_storage $storage

librdf_destroy_world