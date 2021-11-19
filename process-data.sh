#!/bin/bash
#Author: Joao Simoes

data="$1"

wget "https://static.ivaucher.pt/docs/Lista-de-Postos-de-Abastecimento-de-Combustiveis-Aderentes_$data.pdf" -O lista.pdf ;
pdftotext -layout lista.pdf lista.txt;
cat lista.txt |sed -E s/'  '+/'@'/g|grep -v 'Postos de abastecimento aderentes' \
 |grep -v 'Data de atualiza'|grep -v 'Distrito@Concelho@Marca@'|sed -r '/^\s*$/d'|grep -v "Nota:" \
 |grep -v 'respetivo@ mediante contacto'|sed '/^@/d' \
 > Lista-de-Postos-de-Abastecimento-de-Combustiveis-Aderentes_$data.csv;

# Not sure why I need this! :->
#tail -n +2 "Lista-de-Postos-de-Abastecimento-de-Combustiveis-Aderentes_$data.csv" > "Lista-de-Postos-de-Abastecimento-de-Combustiveis-Aderentes_$data.csv.tmp" && mv "Lista-de-Postos-de-Abastecimento-de-Combustiveis-Aderentes_$data.csv.tmp" "Lista-de-Postos-de-Abastecimento-de-Combustiveis-Aderentes_$data.csv"

 python3 georeference.py $data

 ogr2ogr -f GEOJSON gas_stations_$1.geojson input.vrt

 jq --compact-output ".features" gas_stations_$1.geojson > output2.geojson

 cp output2.geojson /home/joana/git/pygeoapi/docker/examples/mongo/mongo_data/

cd /home/joana/git/pygeoapi/docker/examples/mongo/

git commit -a -m "- updated data file"

git push origin ivaucher-aws

#docker-compose build

#docker tag ivaucher-frontend_app:latest doublebyte/ivaucher-frontend:latest
#docker push doublebyte/ivaucher-frontend:latest

scp -i /home/joana/Documents/aws/earthpulse.pem mongo_data/output2.geojson ubuntu@ec2-18-156-191-178.eu-central-1.compute.amazonaws.com:/home/ubuntu/pygeoapi/docker/examples/mongo/mongo_data/
ssh -i /home/joana/Documents/aws/earthpulse.pem ubuntu@ec2-18-156-191-178.eu-central-1.compute.amazonaws.com "cd pygeoapi/docker/examples/mongo/; docker-compose down -v; docker-compose up -d;"

echo "ok"
