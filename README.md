El objetivo de este proyecto es, siguiendo el curso de hyperledger replicar una red en hyperledger y ampliar este, tratando de conectarlo con la red de stellar para realizar pagos. deseenme suerte :)

En este caso va a haber tres clases de participantes en nuestra red:
        Productores:
            son los que producen,
            estan conectados en dos canales diferentes:
                el primer canal privado sera con los Mayoristas para crear ofertas personalizadas.
                el segundo canal privado sera con los consumidores finales y los mayoristas.
        Consumidores finales:
            son los usuarios finales del marketplace,
            estan conectados con los productores por un canal y con los mayoristas.
            esto permite que los consumidores puedan acceder a los productos tanto por parte de los mayoristas como de los productores
        Mayoristas:
            son los que se encargan de comprar a gran escala y vender a pequeña.
                Estan conectados con los consumidores finales para venderles los productos y con los productores  en un mismo canal para que tengan libertad de mercado sin abusos.
                Estan conectados con los productores por un canal privado para recibir mejores ofertas por compras a gran escala.

el primer paso es crear el crypto-config.yaml el cual nos permitira crear los certificados seguros para cada una de las organizaciones.




Una vez configurado el entorno de contenedores y tras levantarlos:



export CHANNEL_NAME=marketplace
export VERBOSE=false
export FABRIC_CFG_PATH=$PWD
echo $CHANNEL_NAME 
docker-compose -f docker-compose-cli-couchdb.yaml up -d
docker ps

docker exec -it cli bash

export CHANNEL_NAME=marketplace
peer channel create -o orderer.acme.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/channel.tx --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/acme.com/orderers/orderer.acme.com/msp/tlscacerts/tlsca.acme.com-cert.pem

-- Join canal

peer channel join -b marketplace.block
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.acme.com/users/Admin@org2.acme.com/msp CORE_PEER_ADDRESS=peer0.org2.acme.com:7051 CORE_PEER_LOCALMSPID="Org2MSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.acme.com/peers/peer0.org2.acme.com/tls/ca.crt peer channel join -b marketplace.block
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.acme.com/users/Admin@org3.acme.com/msp CORE_PEER_ADDRESS=peer0.org3.acme.com:7051 CORE_PEER_LOCALMSPID="Org3MSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.acme.com/peers/peer0.org3.acme.com/tls/ca.crt peer channel join -b marketplace.block

-- Update Anchor peer

peer channel update -o orderer.acme.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/Org1MSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/acme.com/orderers/orderer.acme.com/msp/tlscacerts/tlsca.acme.com-cert.pem

CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.acme.com/users/Admin@org2.acme.com/msp CORE_PEER_ADDRESS=peer0.org2.acme.com:7051 CORE_PEER_LOCALMSPID="Org2MSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.acme.com/peers/peer0.org2.acme.com/tls/ca.crt peer channel update -o orderer.acme.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/Org2MSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/acme.com/orderers/orderer.acme.com/msp/tlscacerts/tlsca.acme.com-cert.pem

CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.acme.com/users/Admin@org3.acme.com/msp CORE_PEER_ADDRESS=peer0.org3.acme.com:7051 CORE_PEER_LOCALMSPID="Org3MSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.acme.com/peers/peer0.org3.acme.com/tls/ca.crt peer channel update -o orderer.acme.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/Org3MSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/acme.com/orderers/orderer.acme.com/msp/tlscacerts/tlsca.acme.com-cert.pem

-- portainer
sudo docker volume create portainer_data
sudo docker run -d -p 8000:8000 -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer