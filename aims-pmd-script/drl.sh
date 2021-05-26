#!/bin/bash

graphTo=http://environment.data.gov.uk/linked-data/graph/data/asset-management/def/drl/revisions
graphFrom=http://environment.data.gov.uk/asset-management/def/drl/revisions
target=defra-dev
source=defra-aims

> rdf/drl-drafter.ttl
echo '
@prefix stardog: <tag:stardog:api:> .
@prefix : <http://api.stardog.com/> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .
@prefix owl: <http://www.w3.org/2002/07/owl#> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .

<http://environment.data.gov.uk/linked-data/graph/data/drl-metadata> rdf:type <http://publishmydata.com/def/drafter/ManagedGraph> ;
<http://purl.org/dc/terms/issued>	"2021-05-19T17:52:12.504+01:00"^^xsd:dateTime ;
<http://purl.org/dc/terms/modified>	"2021-05-19T17:52:10.211+01:00"^^xsd:dateTime ; 
<http://publishmydata.com/def/drafter/isPublic>	"true"^^xsd:boolean.
' >> rdf/drl-drafter.ttl

#metadata
#clear contents of metadata file
> rdf/drl-metadata.ttl
echo '
@prefix dcat: <http://www.w3.org/ns/dcat#> .
@prefix pmdcat: <http://publishmydata.com/pmdcat#> .
@prefix dct: <http://purl.org/dc/terms/> .
@prefix foaf: <http://xmlns.com/foaf/0.1/> .
@prefix pmdui: <http://publishmydata.com/def/pmdui/> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix ui: <http://www.w3.org/ns/ui#> .
@prefix markdown: <https://www.w3.org/ns/iana/media-types/text/markdown#> .
@prefix dsp: <http://environment.data.gov.uk/linked-data/def/> .
@prefix dspGroupOwner: <http://environment.data.gov.uk/linked-data/def/groupOwner/> .
@prefix dspUpdateFrequency: <http://environment.data.gov.uk/linked-data/def/updateFrequency/> .
# this triple adds the dataset to the catalog
<http://environment.data.gov.uk/linked-data/catalog/datasets> dcat:record <http://environment.data.gov.uk/linked-data/catalog/datasets/entry/drl> .

# the record of the dataset in the catalog
<http://environment.data.gov.uk/linked-data/catalog/datasets/entry/drl> a dcat:CatalogRecord ;
    rdfs:label "drl" ;
    foaf:primaryTopic <http://environment.data.gov.uk/linked-data/data/drl/observations-entry>;
    dct:issued "2021-05-19T00:00:00"^^xsd:dateTime ; 
    dct:modified "2021-05-19T00:00:00"^^xsd:dateTime ;
    pmdcat:metadataGraph <http://environment.data.gov.uk/linked-data/graph/data/drl-metadata> .

<http://environment.data.gov.uk/linked-data/data/drl/observations-entry> a pmdcat:Dataset ;
    rdfs:label "DRL" ;
    dct:issued "2021-05-19T00:00:00"^^xsd:dateTime ; 
    dct:modified "2021-05-19T00:00:00"^^xsd:dateTime .

' >> rdf/drl-metadata.ttl


for name in  1 2

do

echo '
# dataset catalog entry 
<http://environment.data.gov.uk/linked-data/data/drl/observations-entry> pmdcat:graph <http://environment.data.gov.uk/linked-data/graph/data/asset-management/def/drl/revisions/'$name'> .
<http://environment.data.gov.uk/linked-data/data/drl/observations-entry> pmdcat:datasetContents <http://environment.data.gov.uk/linked-data/graph/data/asset-management/def/drl/revisions/'$name'> .
    
' >> rdf/drl-metadata.ttl

#dataset
#get dataset contents from source database
stardog data export -g $graphFrom/$name -- $source rdf/$name.ttl
#send dataset contents to target
stardog data add --named-graph $graphTo/$name $target rdf/$name.ttl

#update drafter records with dataset graph
echo '
<http://environment.data.gov.uk/linked-data/graph/data/asset-management/def/drl/revisions/'$name'> rdf:type <http://publishmydata.com/def/drafter/ManagedGraph> ;
<http://purl.org/dc/terms/issued>	"2021-05-19T17:52:12.504+01:00"^^xsd:dateTime ;
<http://purl.org/dc/terms/modified>	"2021-05-19T17:52:10.211+01:00"^^xsd:dateTime ; 
<http://publishmydata.com/def/drafter/isPublic>	"true"^^xsd:boolean.
' >> rdf/drl-drafter.ttl
done

#send metadata contents to target
stardog data add --named-graph http://environment.data.gov.uk/linked-data/graph/data/drl-metadata $target rdf/drl-metadata.ttl

stardog data add --named-graph http://publishmydata.com/graphs/drafter/drafts $target rdf/drl-drafter.ttl