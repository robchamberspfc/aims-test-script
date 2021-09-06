#!/bin/bash

graphTo=http://environment.data.gov.uk/linked-data/graph/data
target=defra-dev


> rdf/drafter.ttl
echo '
@prefix stardog: <tag:stardog:api:> .
@prefix : <http://api.stardog.com/> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .
@prefix owl: <http://www.w3.org/2002/07/owl#> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
' >> rdf/drafter.ttl

# for name in capital-projects completed-capital-projects maintenance-tasks maintenance-activities assets
# for name in assets

#metadata
#clear contents of metadata file
> rdf/wims-metadata.ttl

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
<http://environment.data.gov.uk/linked-data/catalog/datasets> dcat:record <http://environment.data.gov.uk/linked-data/catalog/datasets/entry/wims> .

# the record of the dataset in the catalog
<http://environment.data.gov.uk/linked-data/catalog/datasets/entry/wims> a dcat:CatalogRecord ;
    rdfs:label "wims" ;
    foaf:primaryTopic <http://environment.data.gov.uk/linked-data/catalog/datasets/entry/wims>;
    dct:issued "2021-05-19T00:00:00"^^xsd:dateTime ; 
    dct:modified "2021-05-19T00:00:00"^^xsd:dateTime ;
    pmdcat:metadataGraph <http://environment.data.gov.uk/linked-data/graph/data/wims-metadata> .

# dataset catalog entry 
<http://environment.data.gov.uk/linked-data/catalog/datasets/entry/wims> a pmdcat:Dataset ;
    rdfs:label "Water quality data archive" ;
    pmdui:hasModule <http://environment.data.gov.uk/about/employment-dataset> ;
    dct:issued "2021-05-19T00:00:00"^^xsd:dateTime ; 
    dct:modified "2021-05-19T00:00:00"^^xsd:dateTime ;
    pmdcat:graph <http://environment.data.gov.uk/linked-data/graph/data/wims>;
    pmdcat:datasetContents <http://environment.data.gov.uk/linked-data/graph/data/wims> .
    
' >> rdf/wims-metadata.ttl

#send metadata contents to target
stardog data add --named-graph $graphTo/wims-metadata $target rdf/wims-metadata.ttl

#update drafter records with metadata graph
echo '
<http://environment.data.gov.uk/linked-data/graph/data/wims-metadata> rdf:type <http://publishmydata.com/def/drafter/ManagedGraph> ;
<http://purl.org/dc/terms/issued>	"2021-05-19T17:52:12.504+01:00"^^xsd:dateTime ;
<http://purl.org/dc/terms/modified>	"2021-05-19T17:52:10.211+01:00"^^xsd:dateTime ; 
<http://publishmydata.com/def/drafter/isPublic>	"true"^^xsd:boolean.
' >> rdf/drafter.ttl

#dataset

#send dataset contents to target
# stardog data add --named-graph $graphTo/wims $target /usr/local/var/fuseki/backups/wims_2021-08-11_16-31-11.nq.gz

#update drafter records with dataset graph
echo '
<http://environment.data.gov.uk/linked-data/graph/data/wims> rdf:type <http://publishmydata.com/def/drafter/ManagedGraph> ;
<http://purl.org/dc/terms/issued>	"2021-05-19T17:52:12.504+01:00"^^xsd:dateTime ;
<http://purl.org/dc/terms/modified>	"2021-05-19T17:52:10.211+01:00"^^xsd:dateTime ; 
<http://publishmydata.com/def/drafter/isPublic>	"true"^^xsd:boolean.
' >> rdf/drafter.ttl


stardog data add --named-graph http://publishmydata.com/graphs/drafter/drafts $target rdf/drafter.ttl