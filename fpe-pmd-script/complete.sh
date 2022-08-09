#!/bin/bash

target=defra-dev
source=fpe-prod

> rdf/drafter.ttl
echo '
@prefix stardog: <tag:stardog:api:> .
@prefix : <http://api.stardog.com/> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .
@prefix owl: <http://www.w3.org/2002/07/owl#> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
' >> rdf/drafter.ttl


getData () {
#metadata
#clear contents of metadata file
> rdf/$safeName-metadata.ttl

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
<http://environment.data.gov.uk/linked-data/catalog/'$catalogue'> dcat:record <http://environment.data.gov.uk/linked-data/catalog/datasets/entry/'$safeName'> .

# the record of the dataset in the catalog
<http://environment.data.gov.uk/linked-data/catalog/datasets/entry/'$safeName'> a dcat:CatalogRecord ;
    rdfs:label "'$safeName'" ;
    foaf:primaryTopic <http://environment.data.gov.uk/linked-data/data/'$safeName'/observations-entry>;
    dct:issued "2021-05-19T00:00:00"^^xsd:dateTime ; 
    dct:modified "2021-05-19T00:00:00"^^xsd:dateTime ;
    pmdcat:metadataGraph <http://environment.data.gov.uk/linked-data/graph/data/'$safeName'-metadata> .

# dataset catalog entry 
<http://environment.data.gov.uk/linked-data/data/'$safeName'/observations-entry> a pmdcat:Dataset ;
    rdfs:label "'$safeName'" ;
    dct:issued "2021-05-19T00:00:00"^^xsd:dateTime ; 
    dct:modified "2021-05-19T00:00:00"^^xsd:dateTime ;
    pmdcat:graph <http://environment.data.gov.uk/linked-data/graph/data/'$safeName'>;
    pmdcat:datasetContents <http://environment.data.gov.uk/linked-data/graph/data/'$safeName'> .
    
' >> rdf/$safeName-metadata.ttl

#send metadata contents to target
stardog data add --named-graph $graphTo/$safeName-metadata $target rdf/$safeName-metadata.ttl

#update drafter records with metadata graph
echo '
<http://environment.data.gov.uk/linked-data/graph/data/'$safeName'-metadata> rdf:type <http://publishmydata.com/def/drafter/ManagedGraph> ;
<http://purl.org/dc/terms/issued>	"2021-05-19T17:52:12.504+01:00"^^xsd:dateTime ;
<http://purl.org/dc/terms/modified>	"2021-05-19T17:52:10.211+01:00"^^xsd:dateTime ; 
<http://publishmydata.com/def/drafter/isPublic>	"true"^^xsd:boolean.
' >> rdf/drafter.ttl

#dataset
#get dataset contents from source database
stardog data export -g $graphFrom/$name -- $source rdf/$safeName.ttl
#send dataset contents to target
stardog data add --named-graph $graphTo/$safeName $target rdf/$safeName.ttl

#update drafter records with dataset graph
echo '
<http://environment.data.gov.uk/linked-data/graph/data/'$safeName'> rdf:type <http://publishmydata.com/def/drafter/ManagedGraph> ;
<http://purl.org/dc/terms/issued>	"2021-05-19T17:52:12.504+01:00"^^xsd:dateTime ;
<http://purl.org/dc/terms/modified>	"2021-05-19T17:52:10.211+01:00"^^xsd:dateTime ; 
<http://publishmydata.com/def/drafter/isPublic>	"true"^^xsd:boolean.
' >> rdf/drafter.ttl
}

#go through graphs and load to PMD
for name in "flood-risk-areas/cycle-2" measures-cycle-2

    do
    catalogue=datasets
    graphFrom=http://environment.data.gov.uk/flood-risk-planning/graph
    graphTo=http://environment.data.gov.uk/linked-data/graph/data
    safeName=${name//\//-}

    getData

    done

for name in def taxonomy additional-reference "geom/cde-hierarchy" "strategic-areas/cycle-2"

    do
    catalogue=reference
    graphFrom=http://environment.data.gov.uk/flood-risk-planning/graph
    graphTo=http://environment.data.gov.uk/linked-data/graph/data
    safeName=${name//\//-}

    getData

    done

for name in "data/hierarchy" "data/waterbody" def

    do
    catalogue=reference
    graphFrom=http://environment.data.gov.uk/catchment-planning
    graphTo=http://environment.data.gov.uk/linked-data/graph/data
    safeName=${name//\//-}

    getData

    done

for name in statistical-geography statistical-geography-boundaries

    do
    catalogue=reference
    graphFrom=http://environment.data.gov.uk/graph
    graphTo=http://environment.data.gov.uk/linked-data/graph/data
    safeName=${name//\//-}

    getData

    done

for name in ui

    do
    catalogue=vocabularies
    graphFrom=http://environment.data.gov.uk/flood-risk-planning/graph
    graphTo=http://environment.data.gov.uk/linked-data/graph/data
    safeName=${name//\//-}

    getData

    done

#update drafter graphs to make new datasets visable 
stardog data add --named-graph http://publishmydata.com/graphs/drafter/drafts $target rdf/drafter.ttl