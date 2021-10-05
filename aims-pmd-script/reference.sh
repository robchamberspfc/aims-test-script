#!/bin/bash

graphTo=http://environment.data.gov.uk/linked-data/graph/data
graphFrom=http://environment.data.gov.uk/graph
target=defra-dev
source=defra-aims

> rdf/drafter.ttl
echo '
@prefix stardog: <tag:stardog:api:> .
@prefix : <http://api.stardog.com/> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .
@prefix owl: <http://www.w3.org/2002/07/owl#> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
' >> rdf/drafter.ttl
#all
for name in regional-flood-committees westminster-constituency ea-areas ons-regions capital-projects-ontology districts lead-risk-management-authorities project-types risk-sources asset-management-ontology asset-types asset-types-ontology legacy-ea-areas spatial-qualties maintenance-ontology activity-status activity-types programmes asset-performance-teams five-year-plan-frequent five-year-plan-intermittent bank flood-map-inclusion management-groups protection-types purposes urgencies conditions crest-level-data-qualities sop-data-qualities plan-status inspection-data-qualities

#assets
# for name in ea-areas asset-management-ontology asset-types asset-types-ontology legacy-ea-areas asset-performance-teams conditions purposes protection-types crest-level-data-qualities bank flood-map-inclusion capital-projects-ontology

do
#metadata
#clear contents of metadata file
> rdf/$name-metadata.ttl

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
<http://environment.data.gov.uk/linked-data/catalog/reference> dcat:record <http://environment.data.gov.uk/linked-data/catalog/vocab/entry/'$name'> .

# the record of the dataset in the catalog
<http://environment.data.gov.uk/linked-data/catalog/vocab/entry/'$name'> a dcat:CatalogRecord ;
    rdfs:label "'$name'" ;
    foaf:primaryTopic <http://environment.data.gov.uk/linked-data/data/'$name'/observations-entry>;
    dct:issued "2021-05-19T00:00:00"^^xsd:dateTime ; 
    dct:modified "2021-05-19T00:00:00"^^xsd:dateTime ;
    pmdcat:metadataGraph <http://environment.data.gov.uk/linked-data/graph/data/'$name'-metadata> .

# dataset catalog entry 
<http://environment.data.gov.uk/linked-data/data/'$name'/observations-entry> a pmdcat:Dataset ;
    rdfs:label "'$name'" ;
    dct:issued "2021-05-19T00:00:00"^^xsd:dateTime ; 
    dct:modified "2021-05-19T00:00:00"^^xsd:dateTime ;
    pmdcat:graph <http://environment.data.gov.uk/linked-data/graph/data/'$name'>;
    pmdcat:datasetContents <http://environment.data.gov.uk/linked-data/graph/data/'$name'> .
    
' >> rdf/$name-metadata.ttl

#send metadata contents to target
stardog data add --named-graph $graphTo/$name-metadata $target rdf/$name-metadata.ttl

#update drafter records with metadata graph
echo '
<http://environment.data.gov.uk/linked-data/graph/data/'$name'-metadata> rdf:type <http://publishmydata.com/def/drafter/ManagedGraph> ;
<http://purl.org/dc/terms/issued>	"2021-05-19T17:52:12.504+01:00"^^xsd:dateTime ;
<http://purl.org/dc/terms/modified>	"2021-05-19T17:52:10.211+01:00"^^xsd:dateTime ; 
<http://publishmydata.com/def/drafter/isPublic>	"true"^^xsd:boolean.
' >> rdf/drafter.ttl

#dataset
#get dataset contents from source database
stardog data export -g $graphFrom/$name -- $source rdf/$name.ttl
#send dataset contents to target
stardog data add --named-graph $graphTo/$name $target rdf/$name.ttl

#update drafter records with dataset graph
echo '
<http://environment.data.gov.uk/linked-data/graph/data/'$name'> rdf:type <http://publishmydata.com/def/drafter/ManagedGraph> ;
<http://purl.org/dc/terms/issued>	"2021-05-19T17:52:12.504+01:00"^^xsd:dateTime ;
<http://purl.org/dc/terms/modified>	"2021-05-19T17:52:10.211+01:00"^^xsd:dateTime ; 
<http://publishmydata.com/def/drafter/isPublic>	"true"^^xsd:boolean.
' >> rdf/drafter.ttl
done

stardog data add --named-graph http://publishmydata.com/graphs/drafter/drafts $target rdf/drafter.ttl