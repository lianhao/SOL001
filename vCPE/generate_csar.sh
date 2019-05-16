#!/bin/bash

#*******************************************************************************
# Copyright (c) 2018 Intel Corp and/or its affiliates.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#*******************************************************************************


ROOT_DIR=`dirname $(readlink -f $0)`
DEST=`pwd`
PREFIX="vcpe_"

DIRS="infra vbrgemu vbng vgmux vgw"

for dir in $DIRS; do

    # prepare temporary csar build subdirectory
    cd $ROOT_DIR/$dir
    mkdir $ROOT_DIR/$dir/tmp
    cp MainServiceTemplate.mf tmp/
    if [ $1 ] && [ $1 == "sriov" ]; then
        cp MainServiceTemplate_sriov.yaml tmp/MainServiceTemplate.yaml
    else
        cp MainServiceTemplate.yaml tmp/
    fi
    cp -r $ROOT_DIR/Artifacts tmp/
    cp -r $ROOT_DIR/Definitions tmp/
    cp -r $ROOT_DIR/TOSCA-Metadata tmp/
    cp tmp/MainServiceTemplate.yaml tmp/Definitions/
    cd $ROOT_DIR/$dir/tmp

    # create the csar file
    zip -r $ROOT_DIR/$dir/$dir.csar Artifacts/ TOSCA-Metadata/ Definitions/ MainServiceTemplate.mf MainServiceTemplate.yaml
    rm -f $DEST/$dir.csar
    mv $ROOT_DIR/$dir/$dir.csar $DEST/

    # clean up temporary csar build subdirectory
    cd $ROOT_DIR/$dir
    rm -r $ROOT_DIR/$dir/tmp
done

# Create ns csar
ns_types="ns_vgw ns"

for ns_type in $ns_types; do
    # prepare temporary csar build subdirectory
    cd $ROOT_DIR/ns
    mkdir $ROOT_DIR/ns/tmp
    cp type_definition.yaml tmp/
    cp -r TOSCA-Metadata tmp/
    cp -r artifacts tmp/
    rm -rf tmp/artifacts/image
    if [ $ns_type == "ns_vgw" ]; then
        cp vcpe_ns_vgw.yaml tmp/vcpe.yaml
    else
        cp vcpe.yaml tmp/vcpe.yaml
    fi
    cd $ROOT_DIR/ns/tmp
    zip -r $ROOT_DIR/ns/$ns_type.csar TOSCA-Metadata/ artifacts/ type_definition.yaml vcpe.yaml
    rm -rf $DEST/$ns_type.csar
    mv $ROOT_DIR/ns/$ns_type.csar $DEST
    rm -r $ROOT_DIR/ns/tmp
done
